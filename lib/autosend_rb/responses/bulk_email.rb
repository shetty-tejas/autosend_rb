# frozen_string_literal: true

module AutosendRb
  module Responses
    # Response object for a bulk email request.
    class BulkEmail
      # @return [String] The ID of the batch.
      attr_reader :batch_id
      # @return [Integer] The total number of recipients.
      attr_reader :total_recipients
      # @return [Integer] The number of successful sends.
      attr_reader :success_count
      # @return [Integer] The number of failed sends.
      attr_reader :failed_count

      # Initializes a new BulkEmail response.
      #
      # @param data [Hash] The response data from the API.
      def initialize(data)
        @batch_id = data["batchId"]
        @total_recipients = data["totalRecipients"]
        @success_count = data["successCount"]
        @failed_count = data["failedCount"]
      end
    end
  end
end
