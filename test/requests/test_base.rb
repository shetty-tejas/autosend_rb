# frozen_string_literal: true

require "test_helper"

class TestBaseRequest < Minitest::Test
  class ConcreteRequest < AutosendRb::Requests::Base
    attr_accessor :foo

    def to_h
      { foo: foo }
    end
  end

  class IncompleteRequest < AutosendRb::Requests::Base
  end

  def test_build_method
    request = ConcreteRequest.build(foo: "bar") do |r|
      r.foo = "baz"
    end

    assert_equal "baz", request.foo
  end

  def test_initialize_with_kwargs
    request = ConcreteRequest.new(foo: "bar")
    assert_equal "bar", request.foo
  end

  def test_to_h_not_implemented
    request = IncompleteRequest.new
    assert_raises(NotImplementedError) { request.to_h }
  end

  def test_validate_default
    request = ConcreteRequest.new
    assert request.validate!
  end
end
