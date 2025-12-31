# frozen_string_literal: true

module AutosendRb
  # Wraps the raw HTTP response from the API.
  class ApiResponse
    # @return [Net::HTTPResponse] The raw HTTP response object.
    attr_reader :response

    # Initializes a new ApiResponse.
    #
    # @param response [Net::HTTPResponse] The raw HTTP response.
    # @param raise_error [Boolean] Whether to raise an error for non-success responses.
    # @raise [ApiError] If raise_error is true and the response is not successful.
    def initialize(response, raise_error: false)
      @response = response
      validate! if raise_error
    end

    # Parses the response body as JSON.
    #
    # @return [Hash] The parsed JSON body, or an empty hash if parsing fails.
    def body
      @body ||= JSON.parse(response.body)
    rescue JSON::ParserError
      {}
    end

    def success?
      response.is_a?(Net::HTTPSuccess)
    end

    private

    def validate!
      return if success?

      error_class = case response
                    when Net::HTTPBadRequest then BadRequestError
                    when Net::HTTPUnauthorized then UnauthorizedError
                    when Net::HTTPPaymentRequired then PaymentRequiredError
                    when Net::HTTPForbidden then ForbiddenError
                    when Net::HTTPNotFound then NotFoundError
                    when Net::HTTPTooManyRequests then TooManyRequestsError
                    when Net::HTTPInternalServerError then InternalServerErrorError
                    else ApiError
                    end

      raise error_class, "Autosend API error: #{response.body}"
    end
  end
end
