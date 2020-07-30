# frozen_string_literal: true

require "rubygems"
require "bundler"
APP_ENV = ENV["APP_ENV"] || "development"
Bundler.require(:default, APP_ENV)

require_relative "lib/log_reader"
require_relative "lib/log_converter"

LogConverter.convert_to_html(LogReader.read("file.log"))
