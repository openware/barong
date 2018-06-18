# -*- ruby -*-
require 'simplecov-bamboo'
require 'simplecov-json'
require 'simplecov-rcov'

SimpleCov.start do
  add_filter '/spec/'
end

SimpleCov.formatters = [
  SimpleCov::Formatter::BambooFormatter,
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]
