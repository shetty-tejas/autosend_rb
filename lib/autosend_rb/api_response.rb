module AutosendRb
  class ApiResponse
    attr_reader :response

    def initialize(response, raise_error: false)
      @response = response
      validate! if raise_error
    end

    def body
      @body ||= JSON.parse(response.body)
    rescue JSON::ParserError
      {}
    end

    private

    def validate!
      return if response.is_a?(Net::HTTPSuccess)

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
