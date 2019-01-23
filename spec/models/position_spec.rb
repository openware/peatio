# encoding: UTF-8
# frozen_string_literal: true

describe Position do
  context 'positions auto generated' do
	let(:member) { create(:member, :level_3) }

    it 'user has positions on all markets' do
	  expect(member.positions.count).to eq(1)
    end
  end
end