# frozen_string_literal: true
require "dry/request_handler/option_handler"
module Dry
  module RequestHandler
    class SortOptionHandler < OptionHandler
      def run
        params.fetch("sort") { "" }.split(",").map do |option|
          name, order = if option.start_with?("-")
                          [option[1..-1], :desc]
                        else
                          [option, :asc]
                        end
          allowed_options_type.call(name) if allowed_options_type
          { name.to_sym => order }
        end
      end
    end
  end
end
