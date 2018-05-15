load 'db/migrate/20180325001829_migrate_markets.rb'

describe MigrateMarkets do

  describe '#up' do

    subject { described_class.new.up }

    it 'should check yml file exists' do
      File.expects(:file?).with(Rails.root.join('config/markets.yml'))
      subject
    end

    it 'should find trades' do
      trades = []
      trades.stubs(:update_all)
      MigrateMarkets::Trade20180325001829.expects(:where).at_least(0).returns(trades)
      subject
    end

    it 'should update trades' do
      trades = []
      MigrateMarkets::Trade20180325001829.stubs(:where).returns(trades)
      trades.expects(:update_all).at_least(0)
      subject
    end

    context 'config/markets.yml does not exist' do

      before { File.stubs(:file?).returns(false) }

      it 'should not load yml' do
        YAML.expects(:load_file).never
        subject
      end

      it 'should not check for existing markets' do
        MigrateMarkets::Market20180325001829.expects(:exists?).never
        subject
      end

      it 'should not create any markets' do
        MigrateMarkets::Market20180325001829.expects(:create!).never
        subject
      end

    end

    context 'config/markets.yml exists' do

      before { File.stubs(:file?).returns(true) }

      it 'should load yml' do
        YAML.expects(:load_file).returns([])
        subject
      end

      context 'with yml data' do

        let(:yml_market) do
          {
            'id' => 'btcusd',
            'code' => '101',
            'base_unit' => 'btc',
            'quote_unit' => 'usd',
            'sort_order' => '1',
            'bid' => {
              'fee' => '0.0015', 'currency' => 'usd', 'fixed' => '2'
            },
            'ask' => {
              'fee' => '0.0015', 'currency' => 'btc', 'fixed' => '4'
            }
          }
        end
        let(:yml_markets) { [yml_market] }

        before { YAML.stubs(:load_file).returns(yml_markets) }

        it 'should skip if market exists' do
          MigrateMarkets::Market20180325001829.expects(:exists?).with(id: 'btcusd').returns('anything not nil')
          MigrateMarkets::Market20180325001829.expects(:create!).never
          subject
        end

        context 'not already existing in database' do

          before { MigrateMarkets::Market20180325001829.stubs(:exists?).returns(nil) }

          it 'should create market' do
            MigrateMarkets::Market20180325001829.expects(:create!).with(
              {
                id: 'btcusd',
                ask_unit: 'btc',
                bid_unit: 'usd',
                position: '1',
                bid_fee: '0.0015',
                bid_precision: '2',
                ask_fee: '0.0015',
                ask_precision: '4'
              }
            )
            subject
          end
        end # context 'not already existing in database'
      end # context 'with yml data'
    end # context 'config/markets.yml exists'
  end # describe '#up'
end
