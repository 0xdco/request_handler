# frozen_string_literal: true
require "dry/request_handler/filter_handler"
require "dry/request_handler/page_handler"
require "dry/request_handler/include_option_handler"
require "dry/request_handler/sort_option_handler"
require "dry/request_handler/authorization_handler"
require "dry/request_handler/body_handler"
require "confstruct"
module Dry
  module RequestHandler
    # rubocop:disable Metrics/ClassLength
    class Base
      class << self
        def options(&block)
          @config ||= ::Confstruct::Configuration.new
          @config.configure(&block)
        end

        def inherited(subclass)
          return if @config.nil?
          subclass.config = @config.deep_copy
        end

        attr_accessor :config
      end
      def initialize(request:)
        raise MissingArgumentError.new(request: "is missing") if request.nil?
        @request = request
      end

      def filter_params
        @filter_params ||= handle_filter_params
      end

      def page_params
        @page_params ||= PageHandler.new(
          params:      params,
          page_config: config.lookup!("page")
        ).run
      end

      def include_params
        @include_params ||= handle_include_params
      end

      def sort_params
        @sort_params ||= handle_sort_params
      end

      def authorization_headers
        @authorization_headers ||= AuthorizationHandler.new(env: request.env).run
      end

      def body_params
        @body_params ||= handle_body_params
      end

      # @abstract Subclass is expected to implement #to_dto
      # !method to_dto
      #   take the parsed values and return as application specific data transfer object

      private

      attr_reader :request

      def handle_filter_params
        defaults = fetch_defaults("filter.defaults", {})
        defaults.merge(FilterHandler.new(
          params:                params,
          schema:                config.lookup!("filter.schema"),
          additional_url_filter: config.lookup!("filter.additional_url_filter"),
          schema_options:        execute_options(config.lookup!("filter.options"))
        ).run)
      end

      def handle_include_params
        defaults = fetch_defaults("include_options.defaults", [])
        defaults | IncludeOptionHandler.new(
          params:               params,
          allowed_options_type: config.lookup!("include_options.allowed")
        ).run
      end

      def handle_sort_params
        defaults = fetch_defaults("sort_options.defaults", [])
        result = SortOptionHandler.new(
          params:               params,
          allowed_options_type: config.lookup!("sort_options.allowed")
        ).run
        defaults | result
      end

      def handle_body_params
        defaults = fetch_defaults("body.defaults", {})
        defaults.merge(BodyHandler.new(
          request:        request,
          schema:         config.lookup!("body.schema"),
          schema_options: execute_options(config.lookup!("body.options"))
        ).run)
      end

      def fetch_defaults(key, default)
        value = config.lookup!(key)
        return default if value.nil?
        return value unless value.respond_to?(:call)
        value.call(request)
      end

      def execute_options(options)
        return {} if options.nil?
        return options unless options.respond_to?(:call)
        # https://issues.example.com/browse/NFCO-297
        options.call(self, request)
      end

      def params
        raise MissingArgumentError.new(params: "is missing") if request.params.nil?
        raise WrongArgumentTypeError.new(params: "must be a Hash") unless request.params.is_a?(Hash)
        @params ||= _deep_transform_keys_in_object(request.params) { |k| k.tr(".", "_") }
      end

      def config
        self.class.instance_variable_get("@config")
      end

      # extracted out of active_support
      # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/keys.rb#L143
      def _deep_transform_keys_in_object(object, &block)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[yield(key)] = _deep_transform_keys_in_object(value, &block)
          end
        when Array
          object.map { |e| _deep_transform_keys_in_object(e, &block) }
        else
          object
        end
      end
    end
  end
end
