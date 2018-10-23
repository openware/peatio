# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService::Nxt do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'BlockchainClient::Nxt' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'nxt-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['height'] }
    let(:latest_block)  { block_data.last['height'] }

    let(:blockchain) do
      Blockchain.find_by_key('nxt-testnet')
        .tap { |b| b.update(height: start_block) }
    end

    let(:client) { BlockchainClient[blockchain.key] }

    def request_block_hash_body(block_height)
      { requestType: 'getBlockId', height: block_height }
    end

    def request_block_body(block_hash)
      { requestType: 'getBlock', block: block_hash, includeTransactions: true }
    end

    context 'one NXT deposit was created during blockchain proccessing' do
      # File with real json rpc data for two blocks.
      let(:block_file_name) { '2025970-2025972.json' }

      let(:expected_deposits) do
        [
          {
            amount:   4,
            address:  'NXT-KDS7-674A-CF8W-8KSLY',
            txid:     '2906430788939504474'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:nxt) }

      let!(:payment_address) do
        create(:nxt_payment_address, address: 'NXT-KDS7-674A-CF8W-8KSLY')
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

    context 'one TESTP deposits was created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { 'currency_transaction/2033494-2033495.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_deposits) do
        [
            {
                amount:   1,
                address:  'NXT-ZY2N-RZ2S-3APQ-7T3V8',
                txid:     '14128375984629853109'
            }
        ]
      end

      let(:currency) { Currency.find_by_id(:testp) }

      let!(:payment_address) do
        create(:testp_payment_address, address: 'NXT-ZY2N-RZ2S-3APQ-7T3V8')
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

    context 'one TESTA deposits was created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { 'asset_transaction/2034907-2034908.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_deposits) do
        [
            {
                amount:   2,
                address:  'NXT-WN8Y-DFYG-LRXN-8UW4H',
                txid:     '9693269226043563776'
            }
        ]
      end

      let(:currency) { Currency.find_by_id(:testa) }

      let!(:payment_address) do
        create(:testa_payment_address, address: 'NXT-WN8Y-DFYG-LRXN-8UW4H')
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

    context 'one NXT withdrawals were processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '2025987-2025989.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_withdrawals) do
        [
          {
            sum:  2 + currency.withdraw_fee,
            rid:  'NXT-Y9NM-7HBT-7A8B-3YUHS',
            txid: '16071770205608533047'
          }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:nxt_account) { member.get_account(:nxt).tap { |a| a.update!(locked: 10, balance: 50) } }

      let!(:withdrawals) do
        expected_withdrawals.each_with_object([]) do |withdrawal_hash, withdrawals|
          withdrawal_hash.merge!\
            member: member,
            account: nxt_account,
            aasm_state: :confirming,
            currency: currency
          withdrawals << create(:nxt_withdraw, withdrawal_hash)
        end
      end

      let(:currency) { Currency.find_by_id(:nxt) }

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

    context 'one TESTP withdrawal is processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { 'currency_transaction/2033572-2033575.json' }

      let(:expected_withdrawals) do
        [
            {
                sum:  4 + currency.withdraw_fee,
                rid:  'NXT-ZVB7-LKF2-CR9R-DDXZX',
                txid: '7317031141372600625'
            }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:testp_account) { member.get_account(:testp).tap { |a| a.update!(locked: 10, balance: 50) } }

      let(:currency) { Currency.find_by_id(:testp) }

      let!(:success_withdraw) do
        withdraw_hash = expected_withdrawals[0].merge!\
            member: member,
            account: testp_account,
            aasm_state: :confirming,
            currency: currency

        create(:trst_withdraw, withdraw_hash)
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

    context 'one TESTA withdrawal is processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { 'asset_transaction/2034910-2034911.json' }

      let(:expected_withdrawals) do
        [
            {
                sum:  2 + currency.withdraw_fee,
                rid:  'NXT-Y9NM-7HBT-7A8B-3YUHS',
                txid: '13156355433153480806'
            }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:testa_account) { member.get_account(:testa).tap { |a| a.update!(locked: 10, balance: 50) } }

      let(:currency) { Currency.find_by_id(:testa) }

      let!(:success_withdraw) do
        withdraw_hash = expected_withdrawals[0].merge!\
            member: member,
            account: testa_account,
            aasm_state: :confirming,
            currency: currency

        create(:trst_withdraw, withdraw_hash)
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
