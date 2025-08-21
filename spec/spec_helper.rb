# frozen_string_literal: true

require 'bundler/setup'
require 'rspec'
require 'webmock/rspec'
require 'httparty'

# Add lib/ to LOAD_PATH
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# Disable external HTTP requests except localhost
WebMock.disable_net_connect!(allow_localhost: true)
