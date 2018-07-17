# encoding: UTF-8
# frozen_string_literal: true

describe Blockchain do
  context 'validations' do
    let(:valid_attributes) do
      {
        key:                  'eth-mainet',
        name:                 'Ethereum Mainet',
        client:               'ethereum',
        server:               'http://127.0.0.1:8545',
        height:                5000000,
        min_confirmations:     4,
        explorer_address:      '',
        explorer_transaction:  '',
        status:                'disabled'
      }
    end

    it 'creates valid record' do
      record = Blockchain.new(valid_attributes)
      expect(record.save).to eq true
    end

    it 'validates presence of key' do
      record = Blockchain.new(valid_attributes.except(:key))
      record.save
      expect(record.errors.full_messages).to eq ["Key can't be blank"]
    end

    it 'validates presence of name' do
      record = Blockchain.new(valid_attributes.except(:name))
      record.save
      expect(record.errors.full_messages).to eq ["Name can't be blank"]
    end

    it 'validates presence of client' do
      record = Blockchain.new(valid_attributes.except(:client))
      record.save
      expect(record.errors.full_messages).to eq ["Client can't be blank"]
    end

    it 'validates inclusion of status' do
      record = Blockchain.new(valid_attributes.merge(status: 'active1'))
      record.save
      expect(record.errors.full_messages).to eq ["Status is not included in the list"]
    end

    it 'validates height should be greater than or equal to 1' do
      record = Blockchain.new(valid_attributes.merge(height: 0))
      record.save
      expect(record.errors.full_messages).to eq ["Height must be greater than or equal to 1"]
    end

    it 'validates min_confirmations should be greater than or equal to 1' do
      record = Blockchain.new(valid_attributes.merge(min_confirmations: 0))
      record.save
      expect(record.errors.full_messages).to eq ["Min confirmations must be greater than or equal to 1"]
    end
  end
end
