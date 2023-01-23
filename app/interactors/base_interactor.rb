# frozen_string_literal: true

class BaseInteractor
  Result = Struct.new(:success?, :error, :value)

  def self.run(**args)
    new(**args).run
  end

  def run
    Result.new(success, error, value)
  end
end
