module Worker
  class DepositCoin

    def process(payload)
      payload.symbolize_keys!

      channel_key = payload[:channel_key]
      txid = payload[:txid]

      channel = DepositChannel.find_by_key(channel_key)
      if channel.currency_obj.code == 'eth'
        raw  = get_raw_eth txid
        raw.symbolize_keys!
        deposit_eth!(channel, txid, 1, raw)
      else
        raw  = get_raw channel, txid
        raw[:details].each_with_index do |detail, i|
          detail.symbolize_keys!
          deposit!(channel, txid, i, raw, detail)
        end
      end
    end

    def deposit_eth!(channel, txid, txout, raw)
      ActiveRecord::Base.transaction do
        unless PaymentAddress.where(currency: channel.currency_obj.id, address: ('0x' + raw[:addresses][0])).first
          Rails.logger.info "Deposit address not found, skip. txid: #{txid}, txout: #{txout}, address: #{('0x' + raw[:addresses][0])}, amount: #{((raw[:total].to_d - raw[:fees].to_d) / 1e18)}"
          return
        end
        return if PaymentTransaction::Normal.where(txid: txid, txout: txout).first
        tx = PaymentTransaction::Normal.create! \
        txid: txid,
        txout: txout,
        address: ('0x' + raw[:addresses][0]),
        amount: (raw[:total].to_d / 1e18).to_d,
        confirmations: raw[:confirmations],
        receive_at: Time.parse(raw[:received]).to_datetime,
        currency: channel.currency

        deposit = channel.kls.create! \
        payment_transaction_id: tx.id,
        txid: tx.txid,
        txout: tx.txout,
        amount: tx.amount,
        member: tx.member,
        account: tx.account,
        currency: tx.currency,
        confirmations: tx.confirmations

        deposit.submit!
        deposit.accept! # because the filter only sends the confirmed TXs
      end
    rescue => e
      Rails.logger.error "Failed to deposit: #{$!}"
      Rails.logger.error "txid: #{txid}, txout: #{txout}, detail: #{raw.inspect}"
      report_exception(e)
    end

    def deposit!(channel, txid, txout, raw, detail)
      return if detail[:account] != 'payment' || detail[:category] != 'receive'
      return unless PaymentAddress.where(currency: channel.currency_obj.id, address: detail[:address]).exists?
      return if PaymentTransaction::Normal.where(txid: txid, txout: txout).exists?

      ActiveRecord::Base.transaction do

        tx = PaymentTransaction::Normal.create! \
          txid: txid,
          txout: txout,
          address: detail[:address],
          amount: detail[:amount].to_s.to_d,
          confirmations: raw[:confirmations],
          receive_at: Time.at(raw[:timereceived]).to_datetime,
          currency: channel.currency

        deposit = channel.kls.create! \
          payment_transaction_id: tx.id,
          txid: tx.txid,
          txout: tx.txout,
          amount: tx.amount,
          member: tx.member,
          account: tx.account,
          currency: tx.currency,
          confirmations: tx.confirmations

        deposit.submit!
      end
    rescue => e
      Rails.logger.error 'Failed to deposit.'
      Rails.logger.error "txid: #{txid}, txout: #{txout}, detail: #{detail.inspect}."
      report_exception(e)
    end

    def get_raw(channel, txid)
      channel.currency_obj.api.gettransaction(txid)
    end

    def get_raw_eth(txid)
      url = "https://api.blockcypher.com/v1/eth/main/txs/#{txid}"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end

  end
end
