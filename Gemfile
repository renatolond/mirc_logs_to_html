# frozen_string_literal: true

source "https://rubygems.org"

gem "activesupport", require: false # To have blank? and present?
gem "charlock_holmes", "~> 0.7" # Used to detect file encodings

group :development, :test do
  gem "lefthook", require: false
  gem "pronto", require: false, github: "prontolabs/pronto"
  gem "pronto-rubocop", require: false
  gem "pry-byebug", require: false
  gem "rubocop", "~> 0.85", require: false
  gem "rubocop-performance", "~> 1.6.0", require: false
end

group :test do
  gem "minitest"
  gem "minitest-implicit-subject"
end
