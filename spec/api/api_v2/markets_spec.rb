describe APIv2::Markets, type: :request do
  describe 'GET /api/v2/markets' do
    it 'should all available markets' do
      get '/api/v2/markets'
      expect(response).to be_success
      expect(response.body).to eq "[{\"id\":\"btc#{Peatio.base_fiat_ccy.downcase}\",\"name\":\"BTC/#{Peatio.base_fiat_ccy}\"}]"
    end
  end
end
