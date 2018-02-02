describe APIv2::Markets, type: :request do
  describe 'GET /api/v2/markets' do
    it 'should all available markets' do
      get '/api/v2/markets'
      expect(response).to be_success
      # FIXME: when running specs with BASE_FIAT_CCY=usd Peatio.base_fiat_ccy returns 'usd' instead of 'USD' in this context
      expect(response.body).to eq "[{\"id\":\"btc#{Peatio.base_fiat_ccy.downcase}\",\"name\":\"BTC/#{Peatio.base_fiat_ccy.upcase}\"}]"
    end
  end
end
