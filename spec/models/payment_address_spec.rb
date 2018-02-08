describe PaymentAddress do
  context '.create' do
    before do
      PaymentAddress.any_instance.stubs(:id).returns(1)
    end

    it 'generate address after commit' do
      AMQPQueue.expects(:enqueue)
               .with(:deposit_coin_address,
                     { payment_address_id: 1, currency_id: Currency.find_by(code: :btc).id },
                     persistent: true)

      PaymentAddress.create currency_id: Currency.find_by(code: :btc).id
    end
  end
end
