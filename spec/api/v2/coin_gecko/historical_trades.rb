# frozen_string_literal: true

describe API::V2::CoinGecko::HistoricalTrades, type: :request do
  describe 'GET /api/v2/coingecko/historical_trades' do
    before(:each) { delete_measurments('trades') }
    after(:each) { delete_measurments('trades') }

    context 'there is no market pair' do
      it 'should return error' do
        get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'TEST_TEST' }

        expect(response).to have_http_status 404
        expect(response).to include_api_error('record.not_found')
      end
    end

    context 'there is no trades in influx' do
      let(:expected_response) do
        {
          'buy' => [],
          'sell' => []
        }
      end

      it 'should return recent trades' do
        get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD'}

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result).to eq expected_response
      end
    end

    context 'there are trades in influx' do
      let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d) }
      let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}

      before do
        trade1.write_to_influx
        trade2.write_to_influx
      end

      let(:expected_response) do
        {
          'buy' => [
            {'base_volume' => 0.9,
             'price' => 6,
             'target_volume' => 5.4,
             'trade_id' => 2,
             'trade_timestamp' => trade2.created_at.to_i * 1000,
             'type' => 'buy'},

            {'base_volume' => 1.1,
             'price' => 5,
             'target_volume' => 5.5,
             'trade_id' => 1,
             'trade_timestamp' => trade1.created_at.to_i * 1000,
             'type' => 'buy'}
          ],
          'sell' => []
        }
      end

      it 'should return recent trades' do
        get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD'}
        expect(response).to be_successful

        expect(response_body).to eq expected_response
      end
    end
  end
end
