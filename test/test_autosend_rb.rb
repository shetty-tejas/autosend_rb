# frozen_string_literal: true

require "test_helper"

class TestAutosendRb < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AutosendRb::VERSION
  end

  def test_configuration
    AutosendRb.configure do |config|
      config.api_key = "test_key"
    end

    assert_equal "test_key", AutosendRb.config.api_key
  end

  def test_configuration_missing_key
    AutosendRb.configure do |config|
      config.api_key = nil
    end

    assert_raises(ArgumentError) { AutosendRb.config.api_key }
  end
end
