describe Private::MarketsController, type: :controller do
  let(:member) { create :member }
  before { session[:member_id] = member.id }

  context 'logged in user' do
    describe "GET /markets/btc#{Peatio.base_fiat_ccy.downcase}" do
      before { get :show, data }

      it { expect(response.status).to eq 200 }
    end
  end

  context 'non-login user' do
    before { session[:member_id] = nil }

    describe "GET /markets/btc#{Peatio.base_fiat_ccy.downcase}" do
      before { get :show, data }

      it { expect(response.status).to eq 200 }
      it { expect(assigns(:member)).to be_nil }
    end
  end

  private

  def data
    {
      id: "btc#{Peatio.base_fiat_ccy.downcase}",
      market: "btc#{Peatio.base_fiat_ccy.downcase}",
      ask: 'btc',
      bid: Peatio.base_fiat_ccy.downcase
    }
  end
end
