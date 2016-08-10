module Betfair
  module API
    module RPC
      def self.extended(obj)
        obj.endpoint = "https://#{obj.endpoint}.betfair.com/exchange/betting/json-rpc/v1"
        obj.persistent_headers.merge!({
          "Accept" => "application/json",
          "Content-Type" => "application/json"
        })
      end
    end
  end
end