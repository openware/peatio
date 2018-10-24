# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService::Wcg do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'BlockchainClient::Nxt' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'wcg-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['height'] }
    let(:latest_block)  { block_data.last['height'] }

    let(:blockchain) do
      Blockchain.find_by_key('wcg-testnet')
        .tap { |b| b.update(height: start_block) }
    end

    let(:client) { BlockchainClient[blockchain.key] }

    def request_block_hash_body(block_height)
      { requestType: 'getBlockId', height: block_height }
    end

    def request_block_body(block_hash)
      { requestType: 'getBlock', block: block_hash, includeTransactions: true }
    end

    context 'one WCG deposit was created during blockchain proccessing' do
      # File with real json rpc data for two blocks.
      let(:block_file_name) { '663908-663909.json' }

      let(:expected_deposits) do
        [
          {
            amount:   0.2,
            address:  'WCG-JLBE-2L4Z-V7JC-H2VVD',
            txid:     '11738222887315875006'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:wcg) }

      let!(:payment_address) do
        create(:wcg_payment_address, address: 'WCG-JLBE-2L4Z-V7JC-H2VVD')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)

        block_data.each_with_index do |blk, index|
          # stub get_block_hash
          stub_request(:post, client.endpoint)
            .with(body: request_block_hash_body(blk['height']))
            .to_return(body: { block: blk['block'] }.to_json)

          # stub get_block
          stub_request(:post, client.endpoint)
            .with(body: request_block_body(blk['block']))
            .to_return(body: blk.to_json)
        end

        # Process blockchain data.
        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates one deposit' do
        expect(Deposits::Coin.where(currency: currency).count).to eq expected_deposits.count
      end

      it 'creates deposits with correct attributes' do
        expected_deposits.each do |expected_deposit|
          expect(subject.where(expected_deposit).count).to eq 1
        end
      end

      context 'we process same data one more time' do
        before do
          blockchain.update(height: start_block)
        end

        it 'doesn\'t change deposit' do
          expect(blockchain.height).to eq start_block
          expect{ BlockchainService[blockchain.key].process_blockchain(force: true)}.not_to change{subject}
        end
      end
    end

    context 'one DRT deposits was created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { 'asset_transaction/663909-663910.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_deposits) do
        [
            {
                amount:   0.1,
                address:  'WCG-HE3Q-VMS7-QFYE-8GKD8',
                txid:     '12902249855273779979'
            }
        ]
      end

      let(:currency) { Currency.find_by_id(:drt) }

      let!(:payment_address) do
        create(:drt_payment_address, address: 'WCG-HE3Q-VMS7-QFYE-8GKD8')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each_with_index do |blk, index|
          # stub get_block_hash
          stub_request(:post, client.endpoint)
              .with(body: request_block_hash_body(blk['height']))
              .to_return(body: { block: blk['block'] }.to_json)

          # stub get_block
          stub_request(:post, client.endpoint)
              .with(body: request_block_body(blk['block']))
              .to_return(body: blk.to_json)
        end

        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates one deposit' do
        expect(Deposits::Coin.where(currency: currency).count).to eq expected_deposits.count
      end

      it 'creates deposits with correct attributes' do
        expected_deposits.each do |expected_deposit|
          expect(subject.where(expected_deposit).count).to eq 1
        end
      end

      context 'we process same data one more time' do
        before do
          blockchain.update(height: start_block)
        end

        it 'doesn\'t change deposit' do
          expect(blockchain.height).to eq start_block
          expect{ BlockchainService[blockchain.key].process_blockchain(force: true)}.not_to change{subject}
        end
      end
    end

    context 'one WCG withdrawals were processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '663930-663931.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_withdrawals) do
        [
          {
            sum:  0.2 + currency.withdraw_fee,
            rid:  'WCG-84YJ-ZEM2-8J7C-EGSDT',
            txid: '45867959689397612'
          }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:wcg_account) { member.get_account(:wcg).tap { |a| a.update!(locked: 10, balance: 50) } }

      let!(:withdrawals) do
        expected_withdrawals.each_with_object([]) do |withdrawal_hash, withdrawals|
          withdrawal_hash.merge!\
            member: member,
            account: wcg_account,
            aasm_state: :confirming,
            currency: currency
          withdrawals << create(:wcg_withdraw, withdrawal_hash)
        end
      end

      let(:currency) { Currency.find_by_id(:wcg) }

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)

        block_data.each_with_index do |blk, index|
          # stub get_block_hash
          stub_request(:post, client.endpoint)
              .with(body: request_block_hash_body(blk['height']))
              .to_return(body: { block: blk['block'] }.to_json)

          # stub get_block
          stub_request(:post, client.endpoint)
              .with(body: request_block_body(blk['block']))
              .to_return(body: blk.to_json)
        end

        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Withdraws::Coin.where(currency: currency) }

      it 'doesn\'t create new withdrawals' do
        expect(subject.count).to eq expected_withdrawals.count
      end

      it 'changes withdraw confirmations amount' do
        subject.each do |withdrawal|
          expect(withdrawal.confirmations).to_not eq 0
        end
      end

      it 'changes withdraw state if it has enough confirmations' do
        subject.each do |withdrawal|
          if withdrawal.confirmations >= blockchain.min_confirmations
            expect(withdrawal.aasm_state).to eq 'succeed'
          end
        end
      end
    end

    context 'one DRT withdrawal is processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { 'asset_transaction/663926-663927.json' }

      let(:expected_withdrawals) do
        [
            {
                sum:  0.1 + currency.withdraw_fee,
                rid:  'WCG-84YJ-ZEM2-8J7C-EGSDT',
                txid: '16317884211129702380'
            }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:drt_account) { member.get_account(:drt).tap { |a| a.update!(locked: 10, balance: 50) } }

      let(:currency) { Currency.find_by_id(:drt) }

      let!(:success_withdraw) do
        withdraw_hash = expected_withdrawals[0].merge!\
            member: member,
            account: drt_account,
            aasm_state: :confirming,
            currency: currency

        create(:drt_withdraw, withdraw_hash)
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each_with_index do |blk, index|
          # stub get_block_hash
          stub_request(:post, client.endpoint)
              .with(body: request_block_hash_body(blk['height']))
              .to_return(body: { block: blk['block'] }.to_json)

          # stub get_block
          stub_request(:post, client.endpoint)
              .with(body: request_block_body(blk['block']))
              .to_return(body: blk.to_json)
        end

        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Withdraws::Coin.where(currency: currency) }

      it 'doesn\'t create new withdrawals' do
        expect(subject.count).to eq expected_withdrawals.count
      end

      it 'changes withdraw state to success' do
        success_withdraw.reload
        expect(success_withdraw.confirmations).to_not eq 0
        if success_withdraw.confirmations >= blockchain.min_confirmations
          expect(success_withdraw.aasm_state).to eq 'succeed'
        end
      end
    end
  end
end
