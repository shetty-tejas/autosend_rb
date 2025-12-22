# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"

SimpleCov.start do
  add_filter "/test/"

  enable_coverage :branch

  minimum_coverage 90
  minimum_coverage_by_file 75

  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                       SimpleCov::Formatter::HTMLFormatter,
                                                       SimpleCov::Formatter::JSONFormatter
                                                     ])
end

require "autosend_rb"

require "minitest/autorun"
require "mocha/minitest"
