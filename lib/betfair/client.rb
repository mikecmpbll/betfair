require "betfair/api/json"
require "betfair/api/rpc"
require "betfair/utils"
require "httpi"

module Betfair
  class Client
    include ::Utils

    DEFAULT_SETTINGS = { retries: 5 }

    attr_accessor :app_key, :settings, :persistent_headers, :endpoint

    def intialize(app_key = nil, api_type = :rest, settings = {})
      @app_key = app_key
      @settings = DEFAULT_SETTINGS.merge(settings)
      @persistent_headers = {}
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

      def configure_request(path, opts)
        url = path.begins_with?("/") ? "#{endpoint}#{path}" : path

        opts[:headers] = (opts[:headers] || {}).merge(persistent_headers)

        HTTPI::Request.new(url, *args)
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