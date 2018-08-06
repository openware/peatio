# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Bitgo < Base

    def initialize(*)
      super
      currency_code_prefix = wallet.gateway.dig('options','bitgo_test_net') ? 't' : ''
      @endpoint            = wallet.gateway.dig('options','bitgo_rest_api_root').gsub(/\/+\z/, '') + '/' + currency_code_prefix + wallet.currency.code
      @access_token        = wallet.gateway.dig('options','bitgo_rest_api_access_token')
    end

    def load_balance!
      convert_from_base_unit(wallet_details(true).fetch('balanceString'))
    end

    def create_address!(options = {})
      if options[:address_id].present?
        path = '/wallet/' + urlsafe_wallet_id + '/address/' + escape_path_component(options[:address_id])
        rest_api(:get, path).slice('address').symbolize_keys
      else
        response = rest_api(:post, '/wallet/' + urlsafe_wallet_id + '/address', options.slice(:label))
        address  = response['address']
        { address: address.present? ? normalize_address(address) : nil, bitgo_address_id: response['id'] }
      end
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      fee = options.key?(:fee) ? convert_to_base_unit!(options[:fee]) : nil
      rest_api(:post, '/wallet/' + urlsafe_wallet_id + '/sendcoins', {
          address:          normalize_address(recipient.fetch(:address)),
          amount:           convert_to_base_unit!(amount).to_s,
          feeRate:          fee,
          walletPassphrase: bitgo_wallet_passphrase
      }.compact).fetch('txid').yield_self(&method(:normalize_txid))
    end

    def estimate_txn_fee
      {fee: convert_from_base_unit(rest_api(:get, '/tx/fee').fetch('feePerKb'))}
    end

    protected

    def rest_api(verb, path, data = nil)
      args = [@endpoint + path]

      if data
        if verb.in?(%i[ post put patch ])
          args << data.compact.to_json
          args << { 'Content-Type' => 'application/json' }
        else
          args << data.compact
          args << {}
        end
      else
        args << nil
        args << {}
      end

      args.last['Accept']        = 'application/json'
      args.last['Authorization'] = 'Bearer ' + @access_token

      response = Faraday.send(verb, *args)
      Rails.logger.debug { response.describe }
      response.assert_success!
      JSON.parse(response.body)
    end

    def wallet_details
      rest_api(:get, '/wallet/' + urlsafe_wallet_id)
    end

    def urlsafe_wallet_address
      CGI.escape(normalize_address(wallet.gateway.dig('options','bitgo_wallet_address')))
    end

    def wallet_id
      wallet.gateway.dig('options','bitgo_wallet_id')
    end

    def bitgo_wallet_passphrase
      wallet.gateway.dig('options','bitgo_wallet_passphrase')
    end

    def urlsafe_wallet_id
      escape_path_component(wallet_id)
    end

    def escape_path_component(id)
      CGI.escape(id)
    end

  end
end
