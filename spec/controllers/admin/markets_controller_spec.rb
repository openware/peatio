describe Admin::MarketsController, type: :controller do
  let(:member) { create(:admin_member) }
  let(:valid_market_attributes) do
    { bid_unit: :usd,
      bid_fee: 0.1,
      bid_precision: 4,
      ask_unit: :eth,
      ask_fee: 0.2,
      ask_precision: 4,
      visible: true,
      position: 100 }
  end
  before { session[:member_id] = member.id }

  describe 'POST create' do
    it 'creates market with valid attributes' do
      params = { market_params: valid_market_attributes }
      expect do
        post :create, params
        expect(response).to redirect_to admin_markets_path
      end.to change(Market, :count)
    end

    it 'doesn\'t create market if commodity pair already exists' do
      existing = Market.first
      params = { market_params: valid_market_attributes.merge(bid_unit: existing.bid_unit, ask_unit: existing.ask_unit) }
      expect do
        post :create, params
        expect(response).not_to redirect_to admin_markets_path
      end.not_to change(Market, :count)
    end
  end

  describe 'PUT update' do
    let(:existing_market) { Market.first }
    let(:updatable_market_attributes) { valid_market_attributes.except(:bid_unit, :ask_unit) }
    before { request.env['HTTP_REFERER'] = '/admin/markets' }

    it 'updates market attributes' do
      params = { market_params: updatable_market_attributes, id: existing_market.id }
      post :update, params
      expect(response).to redirect_to admin_markets_path
      updatable_market_attributes.each do |k, v|
        expect(existing_market.reload.method(k).call).to eq v
      end
    end

    it 'doesn\'t update market units and id' do
      params = { market_params: { bid_unit: :btc }, id: existing_market.id }
      post :update, params
      old_id = existing_market.id
      expect(response).to redirect_to '/admin/markets'
      expect(existing_market.reload.bid_unit).not_to eq :btc
      expect(existing_market.reload.id).to eq old_id
    end
  end
end
