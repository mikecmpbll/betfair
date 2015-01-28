require 'json'

module Betfair
  module API
    module REST
      def self.extended(obj)
        obj.endpoint = "https://api.betfair.com/exchange/betting/rest/v1.0"
        obj.persistent_headers.merge!({
          "Accept" => "application/json",
          "Content-Type" => "application/json"
        })

        obj.class::API_OPERATIONS.each do |operation|
          define_method(operation) do |*args|
            raise "Not signed in" unless ["X-Authentication", "X-Application"].all? { |k| persistent_headers.key?(k) }

            response = post("/#{operation.camelize}", *args)

            JSON.parse(response)
          end
        end
      end

      def interactive_login(username, password)
        response = post("https://identitysso.betfair.com/api/login", {
          body: { username: username, password: password },
          headers: { "Content-Type" => "application/x-www-form-urlencoded" }
        })

        session_token = JSON.parse(response)["token"]

        persistent_headers.merge!({
          "X-Authentication" => session_token
        })
      end

      def logout
        get("https://identitysso.betfair.com/api/logout")
      end

      private
        def error_handling
        end
    end
  end
end