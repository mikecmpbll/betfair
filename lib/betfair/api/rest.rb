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
          betting: "https://#{obj.endpoint}.betfair.com/exchange/betting/rest/v1.0",
          account: "https://#{obj.endpoint}.betfair.com/exchange/account/rest/v1.0",
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

        add_session_token_to_persistent_headers(json["token"])
      end

      # Performs the login procedure recommended for applications which run autonomously
      #   username: Betfair account username string
      #   password: Betfair account password string
      #   cert_key_file_path: Path to Betfair client certificate private key file
      #   cert_key_path: Path to Betfair client certificate public key file associated with Betfair account
      def non_interactive_login(username, password, cert_key_file_path, cert_file_path)
        json = post({
          url: "https://identitysso.betfair.com/api/certlogin",
          body: { username: username, password: password },
          headers: { "Content-Type"  => "application/x-www-form-urlencoded" },
          cert_key_file_path: cert_key_file_path,
          cert_file_path: cert_file_path
        })

        add_session_token_to_persistent_headers(json["sessionToken"])
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

        def add_session_token_to_persistent_headers(session_token)
          persistent_headers.merge!({
            "X-Authentication" => session_token
          })
        end

        def parse_response(response)
          JSON.parse(response).tap { |r| handle_errors(r) }
        end

        def handle_errors(response)
        end
    end
  end
end