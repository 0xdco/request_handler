# frozen_string_literal: true
module Dry
  module RequestHandler
    class BaseError < StandardError
      attr_reader :errors
      def initialize(errors)
        @errors = errors
        super(message)
      end

      def message
        @errors.each_with_object("") do |(key, value), memo|
          memo + key.to_s + ": " + value.to_s + ", "
        end
      end
    end
    class InternalBaseError < BaseError
    end
    class ExternalBaseError < BaseError
    end
    class MissingArgumentError < InternalBaseError
    end
    class ExternalArgumentError < ExternalBaseError
    end
    class InternalArgumentError < InternalBaseError
    end
    class SchemaValidationError < ExternalBaseError
    end
    class OptionNotAllowedError < ExternalBaseError
    end
    class NoConfigAvailableError < InternalBaseError
    end
  end
end
