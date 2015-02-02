module Betfair
  module Utils
    def attempt(enum)
      exception = nil
      enum.each do
        begin
          return yield
        rescue Exception => e
          exception = e
          next
        end
      end
      raise exception
    end
  end
end