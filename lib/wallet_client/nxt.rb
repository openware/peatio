# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Nxt < Base

    def initialize(*)
      super
      @json_rpc_endpoint = URI.parse(wallet.uri + "/nxt?")
    end

    def create_address!(options = {})
      secret = options.fetch(:secret) { Passgen.generate(length: 64, symbols: true) }
      {
        address: normalize_address(json_rpc({requestType: 'getAccountId', secretPhrase: secret}).fetch('accountRS')),
        secret:  secret
      }
    end

    def create_coin_withdrawal!(issuer, recipient, amount, options = {})
      withdrawal_request(issuer, recipient, amount, options).fetch('transactionJSON').yield_self do |txn|
        normalize_txid(txn['transaction'])
      end
    end

    def create_currency_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(
          {
              requestType:  'transferCurrency',
              currency:     wallet.currency.token_currency_id,
              secretPhrase: issuer.fetch(:secret),
              recipient:    normalize_address(recipient.fetch(:address)),
              units:        convert_to_base_unit!(amount),
              deadline:     60,
              feeNQT:       options.has_key?(:feeNQT) ? options[:feeNQT] : 0,
              broadcast:    options.has_key?(:broadcast) ? options[:broadcast] : true
          }
      ).yield_self do |txn|
        normalize_txid(txn['transaction'])
      end
    end

    def create_asset_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(
          {
              requestType:  'transferAsset',
              asset:        wallet.currency.token_asset_id,
              secretPhrase: issuer.fetch(:secret),
              recipient:    normalize_address(recipient.fetch(:address)),
              quantityQNT:  convert_to_base_unit!(amount),
              deadline:     60,
              feeNQT:       options.has_key?(:feeNQT) ? options[:feeNQT] : 0,
              broadcast:    options.has_key?(:broadcast) ? options[:broadcast] : true
          }
      ).yield_self do |txn|
        normalize_txid(txn['transaction'])
      end
    end

    def get_txn_fee(issuer, recipient, amount, options = {})
      withdrawal_request(issuer, recipient, amount, options).fetch('transactionJSON').yield_self do |txn|
        convert_from_base_unit(txn['feeNQT'])
      end
    end

    def inspect_address!(address)
      { address:  normalize_address(address),
        is_valid: true }
    end

    def normalize_address(address)
      address.upcase
    end

    def normalize_txid(txid)
      txid.downcase
    end


    protected

    def connection
      Faraday.new(@json_rpc_endpoint).tap do |connection|
        unless @json_rpc_endpoint.user.blank?
          connection.basic_auth(@json_rpc_endpoint.user, @json_rpc_endpoint.password)
        end
      end
    end
    memoize :connection

    def json_rpc(params = {})
      response = connection.post do |req|
        req.body = params
      end
      response.assert_success!
      response = JSON.parse(response.body)
      response['errorDescription'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def withdrawal_request(issuer, recipient, amount, options = {})
      json_rpc(
          {
              requestType:  'sendMoney',
              secretPhrase: issuer.fetch(:secret),
              recipient:    normalize_address(recipient.fetch(:address)),
              amountNQT:    convert_to_base_unit!(amount),
              deadline:     60,
              feeNQT:       options.has_key?(:feeNQT) ? options[:feeNQT] : 0,
              broadcast:    options.has_key?(:broadcast) ? options[:broadcast] : true
          }
      )
    end
  end
end
