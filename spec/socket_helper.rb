# encoding: UTF-8
# frozen_string_literal: true

require 'em-spec/rspec'
require 'em-websocket'
require 'em-websocket-client'
require 'bunny-mock'


def start_server(opts = {})
  EM::WebSocket.run({:host => ENV['WEBSOCKET_HOST'], :port => ENV['WEBSOCKET_PORT']}.merge(opts)) { |ws|
    yield ws if block_given?
  }
end