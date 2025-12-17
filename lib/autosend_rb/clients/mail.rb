# frozen_string_literal: true

module AutosendRb
  module Clients
    module Mail
      extend Concerns::Client

      class << self
        def send(payload, raise_error: false)
          payload.validate! if payload.respond_to?(:validate!)
          payload = payload.to_h if payload.respond_to?(:to_h)

          response = ApiResponse.new(post(path: "/mails/send", body: payload), raise_error: raise_error)
          AutosendRb::Responses::SendEmail.new(response.body["data"])
        end

        def bulk
        end
      end
    end
  end
end
