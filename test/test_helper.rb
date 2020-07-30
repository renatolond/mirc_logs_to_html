# frozen_string_literal: true

require "rubygems"
require "bundler"

APP_ENV = :test
Bundler.require(:default, APP_ENV)

require "minitest/autorun"
