# encoding: UTF-8
# frozen_string_literal: true

describe Wallet do
  context 'validations' do
    let(:valid_attributes) do
      {
        name:                 'Ethereum Hot Wallet',
        currency_id:          'eth',
        address:              '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C',
        kind:                 'hot',
        nsig:                  1,
        status:               'active'
      }
    end

    it 'creates valid record' do
      record = Wallet.new(valid_attributes)
      expect(record.save).to eq true
    end

    it 'validates presence of address' do
      record = Wallet.new(valid_attributes.except(:address))
      record.save
      expect(record.errors.full_messages).to eq ["Address can't be blank"]
    end

    it 'validates presence of name' do
      record = Wallet.new(valid_attributes.except(:name))
      record.save
      expect(record.errors.full_messages).to eq ["Name can't be blank"]
    end

    it 'validates inclusion of status' do
      record = Wallet.new(valid_attributes.merge(status: 'active1'))
      record.save
      expect(record.errors.full_messages).to eq ["Status is not included in the list"]
    end

    it 'validates inclusion of kind' do
      record = Wallet.new(valid_attributes.merge(kind: 'abc'))
      record.save
      expect(record.errors.full_messages).to eq ["Kind is not included in the list"]
    end

    it 'validates nsig should be greater than or equal to 1' do
      record = Wallet.new(valid_attributes.merge(nsig: 0))
      record.save
      expect(record.errors.full_messages).to eq ["Nsig must be greater than or equal to 1"]
    end
  end
end
