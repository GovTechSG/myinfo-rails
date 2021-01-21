# frozen_string_literal: true

# Service Object
module Callable
  def call(**kwargs)
    new(**kwargs).call
  end
end
