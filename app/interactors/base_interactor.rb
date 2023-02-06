# frozen_string_literal: true

class BaseInteractor
  Result = Struct.new(:result, :success?, :error)

  def self.run(**args)
    new(**args).run
  end

  def run
    Result.new(result, true, nil)
  rescue StandardError => e
    Result.new(nil, false, e.message)
  end
end
