require 'spec_helper'

module Authentications
  describe EmailsController, type: :controller do
    let(:member) { create(:member, email: nil, activated: false) }
    before { session[:member_id] = member.id }

    describe 'GET new' do
      subject { get :new }

      it { is_expected.to be_success }

      it  do
        get :new
        expect(flash[:info]).to eq t('authentications.emails.new.setup_email')
      end
    end

    describe 'POST create' do
      let(:data) {
        { email: { address: 'xman@xman.com', user_id: '2' } }
      }

      it 'should update current_user\'s email' do
        post :create, data
        member.reload
        expect(member.email).to eq 'xman@xman.com'
        expect(member.activated).to be false
      end
    end
  end
end
