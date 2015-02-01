require "betfair/api/rest"
require "betfair/api/rpc"
require "utils"
require "httpi"

module Betfair
  class Client
    include ::Utils

    DEFAULT_SETTINGS = { retries: 5 }
    API_OPERATIONS = [:list_event_types, :list_events, :list_market_catalogue]

    attr_accessor :settings, :persistent_headers, :endpoint

    def initialize(headers = {}, api_type = :rest, settings = {})
      @settings = DEFAULT_SETTINGS.merge(settings)
      @persistent_headers = {}
      @persistent_headers.merge!(headers)
      extend_api(api_type)
    end

    private

      [:get, :post].each do |verb|
        define_method(verb) do |*args|
          request = configure_request(*args)
          response = attempt((settings[:retries] || 1).times) do
            HTTPI.request(verb, request, settings[:adapter])
          end
          response.body
        end
      end

      def configure_request(path, opts = {})
        url = path.start_with?("/") ? "#{endpoint}#{path}" : path

        opts[:headers] = persistent_headers.merge(opts[:headers] || {})
        opts.merge!(url: url)

        HTTPI::Request.new(opts)
      end

      def extend_api(type)
        case type
        when :rest
          extend API::REST
        when :rpc
          extend API::RPC
        else
          extend type
        end
      end
  end
end