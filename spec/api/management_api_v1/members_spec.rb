# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Members, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
    scopes: {
      write_members: { permitted_signers: %i[jeff], mandatory_signers: %i[jeff] },
    }
  end

  describe 'Create members' do
    let(:data) { { email: 'member@gmail.com', level: 1, uid: 'IDE33A3786E4', state: 'active' } }
    let(:signers) { %i[jeff] }

    def request
      post_json '/management_api/v1/create/member',
        multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    context 'Success created member' do
      it 'Success created member' do
        request
        expect(response).to be_success
        expect(response.body).to match(/Member was created successfully/i)
      end
    end

    context 'E-Mail is empty' do
      let(:data) { { email: '', level: 1, uid: 'IDE33A3786E4', state: 'active' } }
      it 'Failed request with empty email' do
        request
        expect(response.body).to match(/E-Mail is blank/i)
      end
    end

    context 'E-Mail is invalid' do
      let(:data) { { email: 'email@gmailcom', level: 1, uid: 'IDE33A3786E4', state: 'active' } }
      it 'Failed request with invalid email' do
        request
        expect(response.body).to match(/E-Mail is invalid/i)
      end
    end

    context 'UID is empty' do
      let(:data) { { email: 'email@gmail.com', level: 1, uid: '', state: 'active' } }
      it 'Failed request with empty UID' do
        request
        expect(response.body).to match(/UID is blank/i)
      end
    end

    context 'Without right signatures' do
      let(:signers) { %i[james] }
      it 'Not enough signatures' do
        request
        expect(response.body).to match(/Not enough signatures for the action./i)
      end
    end
  end
end
