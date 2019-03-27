# encoding: UTF-8
# frozen_string_literal: true

describe LiabilityHistoryService do
  let(:member) { create(:member, :level_3) }

  let(:deposit_btc)   { create(:deposit_btc, member: member) }
  let(:deposit_usd)   { create(:deposit_usd, member: member) }
  let(:deposit_usd_2) { create(:deposit_usd, member: member, txid: 1, amount: 520) }
  let(:deposit_btc_2) { create(:deposit_usd, member: member) }

  let(:btc_withdraw)  { create(:btc_withdraw, member: member, created_at: 1.day.ago, note: 'TEST') }
  let(:usd_withdraw)  { create(:usd_withdraw, member: member, note: 'TEST1') }

  let(:btcusd_ask)  { create(:order_ask, :btcusd, price: '12.326'.to_d, volume: '123.123456789', member: member) }
  let(:dashbtc_ask) { create(:order_ask, :dashbtc, price: '12.326'.to_d, volume: '123.123456789', member: member) }
  let(:btcusd_bid)  { create(:order_bid, :btcusd, price: '12.326'.to_d, volume: '123.123456789', member: member) }
  let(:dashbtc_bid) { create(:order_bid, :dashbtc, price: '12.326'.to_d, volume: '123.123456789', member: member) }

  let(:btcusd_ask_trade) { create(:trade, :btcusd, ask: btcusd_ask, created_at: 2.days.ago) }
  let(:dashbtc_ask_trade) { create(:trade, :dashbtc, ask: dashbtc_ask, created_at: 2.days.ago) }
  let(:btcusd_bid_trade) { create(:trade, :btcusd, bid: btcusd_bid, created_at: 1.day.ago) }
  let(:dashbtc_bid_trade) { create(:trade, :dashbtc, bid: dashbtc_bid, created_at: 1.day.ago) }

  describe 'fetch_new_history' do
    before do
      create(:liability, member: member, reference: deposit_btc)
      create(:liability, member: member, reference: deposit_usd)
      create(:liability, member: member, reference: btc_withdraw)
      create(:liability, member: member, reference: usd_withdraw)
      create(:liability, member: member, reference: btcusd_ask_trade)
      create(:liability, member: member, reference: dashbtc_ask_trade)
      create(:liability, member: member, reference: btcusd_bid_trade)
      create(:liability, member: member, reference: dashbtc_bid_trade)
    end

    it 'fetches new history' do
      LiabilityHistoryService.fetch_new_history

      expect(LiabilityHistory.all.count).to eq Operations::Liability.all.count
    end

    it 'does not create duplicated history' do
      LiabilityHistoryService.fetch_new_history
      create(:liability, member: member, reference: deposit_usd_2)
      LiabilityHistoryService.fetch_new_history

      expect(LiabilityHistory.all.count).to eq Operations::Liability.all.count
    end

    it 'creates history for trade with correct fields' do
      trade     = Trade.last
      liability = Operations::Liability.find_by(reference: trade)
      fee       = create(:revenue, member: liability.member, reference: trade, currency: liability.currency)
      liability.update(revenue_id: fee.id)

      LiabilityHistoryService.fetch_new_history

      liability_history = LiabilityHistory.find_by(liability_id: liability.id)

      expect(liability_history.member_id).to eq liability.member_id
      expect(liability_history.market_id).to eq trade.market_id
      expect(liability_history.currency_id).to eq liability.currency_id
      expect(liability_history.debit).to eq liability.debit
      expect(liability_history.credit).to eq liability.credit
      expect(liability_history.price).to eq trade.price
      expect(liability_history.side).to eq trade.side(liability.member)
      expect(liability_history.operation_date).to eq trade.created_at
      expect(liability_history.fee).to eq fee.credit
      expect(liability_history.fee_currency_id).to eq fee.currency_id
    end

    it 'creates history for deposit with correct fields' do
      LiabilityHistoryService.fetch_new_history

      liability_history = LiabilityHistory.find_by(operation_type: 'Deposit')
      liability = Operations::Liability.find_by(id: liability_history.liability_id)
      deposit = Deposit.find_by(id: liability_history.operation_id)
      currency = Currency.find(liability.currency_id)

      expect(liability_history.member_id).to eq liability.member_id
      expect(liability_history.currency_id).to eq liability.currency_id
      expect(liability_history.debit).to eq liability.debit
      expect(liability_history.credit).to eq liability.credit
      expect(liability_history.txid).to eq deposit.txid
      expect(liability_history.fee).to eq deposit.fee
      expect(liability_history.operation_date).to eq deposit.created_at
      expect(liability_history.tx_height).to eq currency.blockchain.try(:min_confirmations)
    end

    it 'creates history for withdraw with correct fields' do
      LiabilityHistoryService.fetch_new_history

      liability_history = LiabilityHistory.find_by(operation_type: 'Withdraw')
      liability = Operations::Liability.find_by(id: liability_history.liability_id)
      withdraw = Withdraw.find_by(id: liability_history.operation_id)
      currency = Currency.find(liability.currency_id)

      expect(liability_history.member_id).to eq liability.member_id
      expect(liability_history.currency_id).to eq liability.currency_id
      expect(liability_history.debit).to eq liability.debit
      expect(liability_history.credit).to eq liability.credit
      expect(liability_history.txid).to eq withdraw.txid
      expect(liability_history.rid).to eq withdraw.rid
      expect(liability_history.fee).to eq withdraw.fee
      expect(liability_history.note).to eq withdraw.note
      expect(liability_history.operation_date).to eq withdraw.created_at
      expect(liability_history.tx_height).to eq currency.blockchain.try(:min_confirmations)
    end

    it 'updates history if deposit state was changed' do
      LiabilityHistoryService.fetch_new_history

      deposit = Deposit.last
      deposit.update!(aasm_state: 'collected')

      LiabilityHistoryService.fetch_new_history

      expect(LiabilityHistory.find_by(operation_type: 'deposit', operation_id: deposit.id).state).to eq 'collected'
    end


    it 'updates history if withdraw state was changed' do
      LiabilityHistoryService.fetch_new_history

      withdraw = Withdraw.last
      withdraw.update!(aasm_state: 'failed')

      LiabilityHistoryService.fetch_new_history

      expect(LiabilityHistory.find_by(operation_type: 'withdraw', operation_id: withdraw.id).state).to eq 'failed'
    end

  end

  describe 'balance' do
    let(:btc_currency) { Currency.find_by(id: 'btc') }
    let(:usd_currency) { Currency.find_by(id: 'usd') }

    let(:btc_credit) { 0.123 }
    let(:btc_debit)  { 0.001 }

    it 'calculates balance correctly' do
      l1 = create(:liability, member: member, reference: deposit_btc, currency: btc_currency, debit: 0.0, credit: btc_credit)
      l2 = create(:liability, member: member, reference: deposit_usd, currency: usd_currency)
      l3 = create(:liability, member: member, reference: btc_withdraw, currency: btc_currency, debit: btc_debit, credit: 0.0)
      l4 = create(:liability, member: member, reference: deposit_btc_2, currency: btc_currency, debit: 0.0, credit: btc_credit)

      LiabilityHistoryService.fetch_new_history

      expect(LiabilityHistory.find_by(liability_id: l1.id).balance.to_f).to eq btc_credit
      expect(LiabilityHistory.find_by(liability_id: l3.id).balance.to_f).to eq (btc_credit - btc_debit)
      expect(LiabilityHistory.find_by(liability_id: l4.id).balance.to_f).to eq (2 * btc_credit - btc_debit)
    end
  end
end
