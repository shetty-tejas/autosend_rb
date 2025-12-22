# frozen_string_literal: true

require "test_helper"

class TestClientsMail < Minitest::Test
  def setup
    AutosendRb.configure do |config|
      config.api_key = "test_key"
      config.api_host = "https://api.autosend.com"
    end

    @mock = mock("success")
    @mock.responds_like_instance_of(Net::HTTPSuccess)
    @mock.stubs(:is_a?).with(Net::HTTPSuccess).returns(true)
  end

  def test_send_email
    payload = { to: "test@example.com" }
    response_body = { "success" => true, "data" => { "emailId" => "123" } }.to_json

    @mock.stubs(:body).returns(response_body)
    @mock.stubs(:code).returns("200")

    # Mock the post method which comes from Concerns::Client
    Net::HTTP.expects(:start).returns(@mock)
    URI::HTTPS.expects(:build).with(host: AutosendRb.config.api_host, path: "/v1/mails/send").once.returns(URI("https://api.autosend.com/v1/mails/send"))

    response = AutosendRb::Clients::Mail.send(payload)

    assert_instance_of AutosendRb::Responses::SendEmail, response
    assert_equal "123", response.email_id
  end

  def test_bulk_email
    payload = { recipients: [] }
    response_body = {
      "success" => true,
      "data" => {
        "batchId" => "batch_123",
        "totalRecipients" => 10,
        "successCount" => 8,
        "failedCount" => 2
      }
    }.to_json

    @mock.stubs(:body).returns(response_body)
    @mock.stubs(:code).returns("200")

    # Mock the post method which comes from Concerns::Client
    Net::HTTP.expects(:start).returns(@mock)
    URI::HTTPS.expects(:build).with(host: AutosendRb.config.api_host, path: "/v1/mails/bulk").once.returns(URI("https://api.autosend.com/v1/mails/bulk"))

    response = AutosendRb::Clients::Mail.bulk(payload)

    assert_instance_of AutosendRb::Responses::BulkEmail, response
    assert_equal "batch_123", response.batch_id
    assert_equal 10, response.total_recipients
    assert_equal 8, response.success_count
    assert_equal 2, response.failed_count
  end
end
