# encoding: UTF-8
# frozen_string_literal: true

describe Admin::UpstreamsController, type: :controller do
  let(:member) { create(:admin_member) }
  let :attributes do
    { provider:     'binance-test',
      api_key:      Faker::Lorem.characters(24),
      api_secret:   Faker::Lorem.characters(24),
      timeout:      0,
      enabled:      true
    }
  end

  let(:existing_upstream) { Upstream.first }

  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates upstream with valid attributes' do
      expect do
        post :create, upstream: attributes
        expect(response).to redirect_to admin_upstreams_path
      end.to change(Upstream, :count).by(1)
      upstream = Upstream.last
      attributes.each { |k, v| expect(upstream.method(k).call).to eq v }
    end
  end

  describe '#update' do
    let :new_attributes do
      { provider:     'dummy',
        api_key:      Faker::Lorem.characters(24),
        api_secret:   Faker::Lorem.characters(24),
        timeout:      10,
        enabled:      false
      }
    end

    before { request.env['HTTP_REFERER'] = '/admin/upstreams' }

    it 'updates upstream attributes' do
      upstream = Upstream.last
      post :update, upstream: new_attributes, id: upstream.id
      expect(response).to redirect_to admin_upstreams_path
      upstream.reload
      expect(upstream.attributes.symbolize_keys.except(:id, :created_at, :updated_at)).to eq new_attributes
    end
  end

  describe '#destroy' do
    it 'doesn\'t support deletion of upstream' do
      expect { delete :destroy, id: existing_upstream.id }.to raise_error(ActionController::UrlGenerationError)
    end
  end

end
