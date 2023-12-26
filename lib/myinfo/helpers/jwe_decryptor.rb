# frozen_string_literal: true

# This class is used to decrypt the JWE token received from MyInfo.
# Codes are actually extracted from JOSE gem
class JweDecryptor
  DEFAULT_IV = OpenSSL::BN.new(0xA6A6A6A6A6A6A6A6).to_s(2).freeze

  def initialize(key:, jwe:)
    @jwe = jwe
    @private_encryption_key = key
  end

  def decrypt
    jwe_parts = @jwe.split('.')

    raise ArgumentError, 'bad jwe' if jwe_parts.size != 5

    protected, encoded_encrypted_key, encoded_iv, encoded_ciphertext, encoded_tag = jwe_parts

    header = JSON.parse(Base64.urlsafe_decode64(protected), { symbolize_names: true })
    encrypted_key = Base64.urlsafe_decode64(encoded_encrypted_key)
    iv = Base64.urlsafe_decode64(encoded_iv)
    ciphertext = Base64.urlsafe_decode64(encoded_ciphertext)
    tag = Base64.urlsafe_decode64(encoded_tag)

    key = compute_public_key(header)
    cek = decrypt_key(key, encrypted_key)
    plain_text = decrypt_ciphertext(cek, iv, ciphertext, tag, protected)

    JWT.decode(plain_text, nil, false).first
  end

  private

  def compute_public_key(header)
    crv = 'prime256v1'
    x = Base64.urlsafe_decode64(header[:epk][:x])
    y = Base64.urlsafe_decode64(header[:epk][:y])

    point = OpenSSL::PKey::EC::Point.new(
      OpenSSL::PKey::EC::Group.new(crv),
      OpenSSL::BN.new([0x04, x, y].pack('Ca*a*'), 2)
    )

    sequence = OpenSSL::ASN1::Sequence([
                                         OpenSSL::ASN1::Sequence([
                                                                   OpenSSL::ASN1::ObjectId('id-ecPublicKey'),
                                                                   OpenSSL::ASN1::ObjectId(crv)
                                                                 ]),
                                         OpenSSL::ASN1::BitString(point.to_octet_string(:uncompressed))
                                       ])
    ec = OpenSSL::PKey::EC.new(sequence.to_der)

    @private_encryption_key.dh_compute_key(ec.public_key)
  end

  # this method decrypts the key which is encypted using ECDH-ES+A256KW algorithm, 256 bits
  def decrypt_key(key, encrypted_key)
    algorithm_id = 'ECDH-ES+A256KW'
    hash = OpenSSL::Digest::SHA256
    key_data_len = 256
    supp_pub_info = [key_data_len].pack('N')

    other_info = [
      algorithm_id.bytesize, algorithm_id,
      ''.bytesize, '',
      ''.bytesize, '',
      supp_pub_info,
      ''
    ].pack('Na*Na*Na*a*a*')
    hash_len = hash.digest('').bytesize * 8
    (key_data_len / hash_len.to_f).ceil

    concatenation = [0, 0, 0, 1, key, other_info].pack('C4a*a*')
    derived_key = [hash.digest(concatenation).unpack1('B*')[0...key_data_len]].pack('B*')

    unwrap(encrypted_key, derived_key)
  end

  def decrypt_ciphertext(cek, iv, ciphertext, tag, protected)
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.decrypt
    cipher.key = cek
    cipher.iv = iv
    cipher.padding = 0
    cipher.auth_data = protected
    cipher.auth_tag = tag
    cipher.update(ciphertext) + cipher.final
  end

  def unwrap(cipher_text, kek, iv = nil)
    iv ||= DEFAULT_IV
    bits = kek.bytesize * 8
    unless (cipher_text.bytesize % 8).zero? && ((bits == 128) || (bits == 192) || (bits == 256))
      raise ArgumentError, 'bad cipher_text, kek, or iv'
    end

    block_count = cipher_text.bytesize.div(8) - 1
    buffer = do_unwrap(cipher_text, 5, block_count, kek, bits)
    buffer_s = StringIO.new(buffer)
    raise ArgumentError, 'iv does not match' unless buffer_s.read(iv.bytesize) == iv

    buffer_s.read
  end

  def do_unwrap(buffer, j, block_count, kek, bits)
    if j.negative?
      buffer
    else
      do_unwrap(do_unwrap_step(buffer, j, block_count, block_count, kek, bits), j - 1, block_count, kek, bits)
    end
  end

  def do_unwrap_step(buffer, j, i, block_count, kek, bits)
    return buffer if i < 1

    buffer_s = StringIO.new(buffer)
    a0, = buffer_s.read(8).unpack('Q>')
    head_size = (i - 1) * 8
    head = buffer_s.read(head_size)
    b0 = buffer_s.read(8)
    tail = buffer_s.read
    round = (block_count * j) + i
    a1 = a0 ^ round
    data = [a1, b0].pack('Q>a*')
    a2, b1 = aes_ecb_decrypt(bits, kek, data).unpack('Q>a*')
    do_unwrap_step([a2, head, b1, tail].pack('Q>a*a*a*'), j, i - 1, block_count, kek, bits)
  end

  def aes_ecb_decrypt(bits, key, cipher_text)
    cipher = OpenSSL::Cipher::AES.new(bits, :ECB)
    cipher.decrypt
    cipher.key = key
    cipher.padding = 0
    cipher.update(cipher_text) + cipher.final
  end
end
