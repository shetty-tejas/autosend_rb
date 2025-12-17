# frozen_string_literal: true

module AutosendRb
  module Responses
    class BulkEmail
      attr_reader :batch_id, :total_recipients, :success_count, :failed_count

      def initialize(data)
        @batch_id = data["batchId"]
        @total_recipients = data["totalRecipients"]
        @success_count = data["successCount"]
        @failed_count = data["failedCount"]
      end
    end
  end
end
