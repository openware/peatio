# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Bitgo < Base

    def initialize(*)
      super
      currency_code_prefix = wallet.bitgo_test_net ? 't' : ''
      @endpoint            = wallet.bitgo_rest_api_root.gsub(/\/+\z/, '') + '/' + currency_code_prefix + wallet.currency.code
      @access_token        = wallet.bitgo_rest_api_access_token
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

    def build_raw_transaction(recipient, amount)
      rest_api(:post, '/wallet/' + urlsafe_wallet_id + '/tx/build', {
          recipients: [{address: normalize_address(recipient.fetch(:address)), amount: convert_to_base_unit!(amount).to_s }]
      }.compact, false).fetch('feeInfo').fetch('fee').yield_self(&method(:convert_from_base_unit))
    end

    def inspect_address!(address)
      { address: normalize_address(address), is_valid: :unsupported }
    end

    # Note: bitgo doesn't accept cash address format
    def normalize_address(address)
      wallet.blockchain_api&.supports_cash_addr_format? ? CashAddr::Converter.to_legacy_address(super) : super
    end

    def load_balance!(_address, _currency)
      convert_from_base_unit(wallet_details(true).fetch('balanceString'))
    end

    def get_transfers(query)
      rest_api(:get, '/wallet/' + urlsafe_wallet_id + '/transfer', query)
    end

    def latest_block_number
      response = rest_api(:get, '/wallet/' + urlsafe_wallet_id + '/transfer', limit: 1, state: 'confirmed')
      transfer = response.fetch('transfers').first
      confirmations = transfer.fetch('confirmations')
      height = transfer.fetch('height')
      block_number = height + confirmations - 1
      Rails.cache.write("latest_#{wallet.blockchain_key}_block_number", block_number)
      block_number
    end

    def build_deposits(transfers)
      transfers.each_with_object([]) do |tx, deposits|
        next if wallet.blockchain.height - tx.fetch('height') > wallet.blockchain.min_confirmations
        next unless tx.fetch('type') == 'recieve' && tx.fetch('state') == 'confirmed' 
        entries = build_deposit_entries(tx)
        next if entries.blank?
        entries.each_with_index do |entry, i|
          Rails.logger.debug { "Processing deposit received at #{Time.parse(tx.fetch('date'))}." }
          deposits << { txid:          normalize_txid(tx.fetch('txid')),
                        address:       entry.fetch(:address),
                        block_number:  tx.fetch('height').to_i,
                        amount:        entry.fetch(:amount),
                        member:        entry.fetch(:member),
                        currency:      wallet.currency,
                        txout:         i,
                        created_at:    Time.parse(tx.fetch('date')) }
        end
      end
    end

    def build_withdraws(transfers)
      transfers.each_with_object([]) do |tx, withdraws|
        next if wallet.blockchain.height - tx.fetch('height') > wallet.blockchain.min_confirmations
        next unless tx.fetch('type') == 'send' && tx.fetch('state') == 'confirmed'

        Withdraws::Coin
          .where(currency: wallet.currency)
          .where(txid: normalize_txid(tx.fetch('txid')))
          .each do |withdraw|
            entries = build_withdraw_entries(tx, withdraw)
            next if entries.blank?
            entries.each_with_index do |entry, i|
              Rails.logger.debug { "Processing deposit received at #{Time.parse(tx.fetch('date'))}." }
              withdraws << { txid:          normalize_txid(tx.fetch('txid')),
                            rid:            entry.fetch(:address),
                            block_number:   tx.fetch('height').to_i,
                            amount:         entry.fetch(:amount) }
            end
          end
      end
    end

    protected

    def rest_api(verb, path, data = nil, raise_error = true)
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
      response.assert_success! if raise_error
      JSON.parse(response.body)
    end

    def build_deposit_entries(tx)
      tx.fetch('entries').each_with_object([]) do |entry, entries|
        next unless entry['wallet'] == wallet.bitgo_wallet_id
        next unless entry['valueString'].to_d > 0
        # next if entry.key?('outputs') && entry['outputs'] != 1
        payment_address = PaymentAddress.find_by(currency_id: wallet.currency, address: entry['address'])
        next unless payment_address
        entries << {
          address: payment_address.address,
          member:  payment_address.account.member,
          amount:  convert_from_base_unit(entry.fetch('valueString'))
        }
      end
    end

    def build_withdraw_entries(tx, withdraw)
      tx.fetch('entries').each_with_object([]) do |entry, entries|
        # next unless entry['wallet'] == wallet.bitgo_wallet_id
        next unless entry['valueString'].to_d > 0
        next unless withdraw.rid == entry.fetch('address')
        # next if entry.key?('outputs') && entry['outputs'] != 1
        # payment_address = PaymentAddress.find_by(currency_id: wallet.currency, address: entry['address'])
        # next unless payment_address
        entries << {
          address: entry.fetch('address'),
          amount:  convert_from_base_unit(entry.fetch('valueString'))
        }
      end
    end


    def wallet_details(_state)
      rest_api(:get, '/wallet/' + urlsafe_wallet_id)
    end

    def urlsafe_wallet_address
      CGI.escape(normalize_address(wallet.address))
    end

    def wallet_id
      wallet.bitgo_wallet_id
    end

    def bitgo_wallet_passphrase
      wallet.bitgo_wallet_passphrase
    end

    def urlsafe_wallet_id
      escape_path_component(wallet_id)
    end

    def escape_path_component(id)
      CGI.escape(id)
    end

  end
end
