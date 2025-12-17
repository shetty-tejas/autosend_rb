# frozen_string_literal: true

require_relative "autosend_rb/version"
require_relative "autosend_rb/config"

require_relative "autosend_rb/concerns/client"

require_relative "autosend_rb/entities/recipient"
require_relative "autosend_rb/entities/attachment"
require_relative "autosend_rb/entities/body"

require_relative "autosend_rb/requests/base"
require_relative "autosend_rb/requests/send_email"

require_relative "autosend_rb/responses/send_email"

require_relative "autosend_rb/clients/mail"

module AutosendRb
  class ApiError < StandardError; end
  class BadRequestError < ApiError; end
  class UnauthorizedError < ApiError; end
  class PaymentRequiredError < ApiError; end
  class ForbiddenError < ApiError; end
  class NotFoundError < ApiError; end
  class TooManyRequestsError < ApiError; end
  class InternalServerErrorError < ApiError; end

  class << self
    def configure(&)
      config.tap(&)
    end

    def config
      Config.instance
    end
  end
end
