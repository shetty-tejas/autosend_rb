# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require "autosend_rb"

require "minitest/autorun"
require "mocha/minitest"
