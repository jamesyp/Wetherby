# frozen_string_literal: true

class BaseInteractor
  Result = Struct.new(:value, :success?, :error)

  attr_reader :error

  def success? = error.blank?

  def self.run(**args)
    new(**args).run
  end

  def run
    Result.new(value, success?, error)
  end
end
