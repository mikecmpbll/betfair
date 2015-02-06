require 'json'
require 'active_support/core_ext/string'

module Betfair
  module API
    module REST
      def self.extended(obj)
        obj.persistent_headers.merge!({
          "Accept" => "application/json",
          "Content-Type" => "application/json"
        })

        apis = {
          betting: "https://api.betfair.com/exchange/betting/rest/v1.0",
          account: "https://api.betfair.com/exchange/account/rest/v1.0"
        }

        obj.class::OPERATIONS.each do |api, operations|
          operations.each do |operation|
            define_method(operation) do |body = nil|
              raise "Not signed in" unless ["X-Authentication", "X-Application"].all? { |k| persistent_headers.key?(k) }

              post(url: "#{apis[api]}/#{operation.to_s.camelize(:lower)}/", body: body.to_json)
            end
          end
        end
      end

      def interactive_login(username, password)
        json = post({
          url: "https://identitysso.betfair.com/api/login",
          body: { username: username, password: password },
          headers: { "Content-Type" => "application/x-www-form-urlencoded" }
        })

        session_token = json["token"]

        persistent_headers.merge!({
          "X-Authentication" => session_token
        })
      end

      def logout
        get(url: "https://identitysso.betfair.com/api/logout")
      end

      private
        [:get, :post].each do |verb|
          define_method(verb) do |*args|
            response = super(*args)
            parse_response(response)
          end
        end

        def parse_response(response)
          JSON.parse(response).tap { |r| handle_errors(r) }
        end

        def handle_errors(response)
        end
    end
  end
end