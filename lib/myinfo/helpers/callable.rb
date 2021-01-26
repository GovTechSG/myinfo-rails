# frozen_string_literal: true

module MyInfo
  # Service Object
  module Callable
    def call(**kwargs)
      new(**kwargs).call
    end
  end
end
