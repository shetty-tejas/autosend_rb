# frozen_string_literal: true

module AutosendRb
  module Responses
    # Response object for a single email request.
    class SendEmail
      # @return [String] The ID of the sent email.
      attr_reader :email_id

      # Initializes a new SendEmail response.
      #
      # @param data [Hash] The response data from the API.
      def initialize(data)
        @email_id = data["emailId"]
      end
    end
  end
end
