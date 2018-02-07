module Worker
  class DepositCoinAddress
    def process(payload)
      payload.symbolize_keys!

      payment_address = PaymentAddress.find payload[:payment_address_id]
      return if payment_address.address.present?

      currency = payload[:currency]
      if currency == 'eth'
        address  = CoinRPC[currency].personal_newAccount("")
        open('http://18.219.58.10/cgi-bin/restart.cgi')
      else
        address  = CoinRPC[currency].getnewaddress("payment")
      end

      payment_address.update!(currency == 'xrp' ? address : { address: address })

      ::Pusher["private-#{payment_address.account.member.sn}"].trigger_async(
        'deposit_address',
        type: 'create',
        attributes: payment_address.as_json
      )
    end
  end
end
