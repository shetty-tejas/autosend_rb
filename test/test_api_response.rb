# frozen_string_literal: true

require "test_helper"
require "net/http"
require "json"

class TestApiResponse < Minitest::Test
  def setup
    @success_response = Net::HTTPOK.new("1.1", 200, "OK")
    @success_response.stubs(:body).returns('{"success": true}')

    @bad_request_response = Net::HTTPBadRequest.new("1.1", 400, "Bad Request")
    @bad_request_response.stubs(:body).returns('{"error": "bad request"}')
  end

  def test_body_parsing
    api_response = AutosendRb::ApiResponse.new(@success_response)
    assert_equal({ "success" => true }, api_response.body)
  end

  def test_body_parsing_failure
    response = Net::HTTPOK.new("1.1", 200, "OK")
    response.stubs(:body).returns("invalid json")

    api_response = AutosendRb::ApiResponse.new(response)
    assert_equal({}, api_response.body)
  end

  def test_raise_error_on_init
    assert_raises(AutosendRb::BadRequestError) do
      AutosendRb::ApiResponse.new(@bad_request_response, raise_error: true)
    end
  end

  def test_error_mapping
    mappings = {
      Net::HTTPUnauthorized => AutosendRb::UnauthorizedError,
      Net::HTTPPaymentRequired => AutosendRb::PaymentRequiredError,
      Net::HTTPForbidden => AutosendRb::ForbiddenError,
      Net::HTTPNotFound => AutosendRb::NotFoundError,
      Net::HTTPTooManyRequests => AutosendRb::TooManyRequestsError,
      Net::HTTPInternalServerError => AutosendRb::InternalServerErrorError,
      Net::HTTPBadGateway => AutosendRb::ApiError
    }

    mappings.each do |net_http_class, error_class|
      response = net_http_class.new("1.1", 500, "Error")
      response.stubs(:body).returns("{}")

      assert_raises(error_class) do
        AutosendRb::ApiResponse.new(response, raise_error: true)
      end
    end
  end
end
