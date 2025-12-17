# frozen_string_literal: true

module AutosendRb
  module Clients
    # Client for the Mail API endpoints.
    module Mail
      extend Concerns::Client

      class << self
        # Sends a single email via the API.
        #
        # @param payload [AutosendRb::Requests::SendEmail, Hash] The request payload.
        # @param raise_error [Boolean] Whether to raise an error if the API request fails.
        # @return [AutosendRb::Responses::SendEmail] The API response.
        def send(payload, raise_error: false)
          payload.validate! if payload.respond_to?(:validate!)
          payload = payload.to_h if payload.respond_to?(:to_h)

          response = ApiResponse.new(post(path: "/mails/send", body: payload), raise_error: raise_error)
          AutosendRb::Responses::SendEmail.new(response.body["data"])
        end

        # Sends a bulk email via the API.
        #
        # @param payload [AutosendRb::Requests::BulkEmail, Hash] The request payload.
        # @param raise_error [Boolean] Whether to raise an error if the API request fails.
        # @return [AutosendRb::Responses::BulkEmail] The API response.
        def bulk(payload, raise_error: false)
          payload.validate! if payload.respond_to?(:validate!)
          payload = payload.to_h if payload.respond_to?(:to_h)

          response = ApiResponse.new(post(path: "/mails/bulk", body: payload), raise_error: raise_error)
          AutosendRb::Responses::BulkEmail.new(response.body["data"])
        end
      end
    end
  end
end
