describe Admin::CurrenciesController, type: :controller do
  let(:member) { create(:admin_member) }
  let(:valid_currency_attributes) do
    { code:   'new',
      type:   'coin',
      symbol: 'N' }
  end
  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates market with valid attributes' do
      expect do
        post :create, currency: valid_currency_attributes
        expect(response).to redirect_to admin_currencies_path
      end.to change(Currency, :count)
    end
  end

  describe '#update' do
    let(:existing_currency) { Currency.first }
    before do
      valid_currency_attributes.merge! \
        quick_withdraw_limit:         1000,
        visible:                      true,
        base_factor:                  10**6,
        precision:                    6,
        api_client:                   'NEW',
        json_rpc_endpoint:            'http://new.coin',
        rest_api_endpoint:            'http://api.new.coin',
        bitgo_test_net:               true,
        bitgo_wallet_id:              'id',
        bitgo_wallet_address:         'address',
        bitgo_wallet_passphrase:      'passphrase',
        bitgo_rest_api_root:          'http://api.new.coin',
        bitgo_rest_api_access_token:  'token',
        wallet_url_template:          'http://new.coin/ad',
        transaction_url_template:     'http://new.coin/tx'
    end

    before { request.env['HTTP_REFERER'] = '/admin/currencies' }

    it 'updates currency attributes' do
      post :update, currency: valid_currency_attributes, id: existing_currency.id
      expect(response).to redirect_to admin_currencies_path
      valid_currency_attributes.each do |k, v|
        expect(existing_currency.reload.method(k).call).to eq v
      end
    end
  end

  describe '#destroy' do
    let(:existing_currency) { Currency.first }

    it 'doesn\'t support deletion of currencies' do
      expect { delete :destroy, id: existing_currency.id }.to raise_error(ActionController::UrlGenerationError)
    end
  end
end

