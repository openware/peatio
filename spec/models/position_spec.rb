# encoding: UTF-8
# frozen_string_literal: true

describe Position do
  context 'positions auto generated' do
    let(:member) { create(:member, :level_3) }

    it 'user has positions on all markets' do
      expect(member.positions.count).to eq(1)
    end

    it 'position dmargin ' do
      pos = member.positions.find_by(market_id: 'btc_usd_1903')
      pos.update(volume: 1, credit: 3991, margin: 388)
      expect(pos.dmargin(0)).not_to eq 0
    end
  end
end
