# frozen_string_literal: true
require "dry/request_handler/option_handler"
require "dry/request_handler/error"
module Dry
  module RequestHandler
    class IncludeOptionHandler < OptionHandler
      def run
        return [] unless params.key?("include")
        options = fetch_options
        raise ExternalArgumentError.new(include: "must not contain a space") if options.include? " "
        allowed_options(options.split(","))
      end

      def allowed_options(options)
        options.map do |option|
          begin
            allowed_options_type.call(option) if allowed_options_type
          rescue Types::ConstraintError
            raise OptionNotAllowedError.new(option.to_sym => "is not an allowed include option")
          end
          option.to_sym
        end
      end

      def fetch_options
        raise ExternalArgumentError.new(include_options: "query paramter must not be empty") if empty_param?("include")
        params.fetch("include") { "" }
      end
    end
  end
end
