# frozen_string_literal: true

require_relative "autosend_rb/version"
require_relative "autosend_rb/config"
require_relative "autosend_rb/api_response"
require_relative "autosend_rb/railtie" if defined?(Rails) && defined?(ActionMailer)
require_relative "autosend_rb/utils"

require_relative "autosend_rb/concerns/client"

require_relative "autosend_rb/entities/recipient"
require_relative "autosend_rb/entities/attachment"
require_relative "autosend_rb/entities/body"

require_relative "autosend_rb/requests/base"
require_relative "autosend_rb/requests/send_email"
require_relative "autosend_rb/requests/bulk_email"

require_relative "autosend_rb/responses/send_email"
require_relative "autosend_rb/responses/bulk_email"

require_relative "autosend_rb/clients/mail"
require_relative "autosend_rb/mail"

module AutosendRb
  # Base error class for all AutosendRb errors
  class Error < StandardError; end
  # Raised when there is a configuration error
  class ConfigurationError < Error; end
  # Base error class for all API errors
  class ApiError < Error; end
  # Raised when the API returns a 400 Bad Request
  class BadRequestError < ApiError; end
  # Raised when the API returns a 401 Unauthorized
  class UnauthorizedError < ApiError; end
  # Raised when the API returns a 402 Payment Required
  class PaymentRequiredError < ApiError; end
  # Raised when the API returns a 403 Forbidden
  class ForbiddenError < ApiError; end
  # Raised when the API returns a 404 Not Found
  class NotFoundError < ApiError; end
  # Raised when the API returns a 429 Too Many Requests
  class TooManyRequestsError < ApiError; end
  # Raised when the API returns a 500 Internal Server Error
  class InternalServerErrorError < ApiError; end

  class << self
    # Configures the AutosendRb gem.
    #
    # @yield [config] The configuration object
    # @yieldparam config [AutosendRb::Config] The configuration object
    # @return [AutosendRb::Config] The configuration object
    #
    # @example
    #   AutosendRb.configure do |config|
    #     config.api_key = "your_api_key"
    #   end
    def configure(&)
      config.tap(&)
    end

    # Returns the configuration object.
    #
    # @return [AutosendRb::Config] The configuration object
    def config
      Config.instance
    end
  end
end
