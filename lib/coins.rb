require 'net/http'
require 'uri'
require 'json'

class CoinRPC
  class JSONRPCError < RuntimeError; end
  class ConnectionRefusedError < StandardError; end

  def initialize(uri)
    @uri = URI.parse(uri)
  end

  def self.[](currency)
    p currency
    c = Currency.find_by_code(currency.to_s)
    p c
    unless c.nil? || c.rpc.empty? && c.code.empty?
      "::CoinRPC::#{c.code.upcase}".constantize.new(c.rpc)
    else
      raise "RPC url for #{name} not found! Please fix that in `config/currencies.yml`"
    end
  end

  def method_missing(name, *args)
    handle name, *args
  end

  def handle
    raise 'Not implemented'
  end
end
