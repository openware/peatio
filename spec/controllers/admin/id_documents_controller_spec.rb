require 'spec_helper'

describe Admin::IdDocumentsController, type: :controller do
  let(:member) { create(:admin_member) }
  before {
    session[:member_id] = member.id
    two_factor_unlocked
  }

  describe 'GET index' do
    before { get :index }

    it { expect(response.status).to eq 200 }
    it { is_expected.to render_template(:index) }
  end
end
