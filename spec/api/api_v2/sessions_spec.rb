# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Sessions, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:session_utils) { Class.new { include SessionUtils }.new }
  after { session_utils.destroy_member_sessions(member.id) }

  describe 'POST /sessions' do
    context 'when no token provided' do
      it 'requires authentication' do
        api_post '/api/v2/sessions'
        expect(response.code).to eq '401'
      end
    end

    context 'invalid JWT' do
      let(:token) { jwt_for(member, exp: 10.minutes.ago.to_i) }

      it 'validates JWT and denies access as usual' do
        api_post '/api/v2/sessions'
        expect(response.code).to eq '401'
      end
    end

    it 'saves session in Redis' do
      api_post '/api/v2/sessions', token: token
      expect(response.code).to eq '201'
      expect(session_utils.fetch_member_session_ids(member.id).count).to be 1
    end

    it 'resets any previous sessions' do
      api_post '/api/v2/sessions', token: token
      expect(response.code).to eq '201'
      expect(session_utils.fetch_member_session_ids(member.id).count).to be 1

      api_post '/api/v2/sessions', token: token
      expect(response.code).to eq '201'
      expect(session_utils.fetch_member_session_ids(member.id).count).to be 1
    end

    it 'created session which is usable with Rails controllers' do
      api_post '/api/v2/sessions', token: token
      expect(response.code).to eq '201'
      expect(session_utils.fetch_member_session_ids(member.id).count).to be 1
      get '/markets/' + Market.enabled.first.id + '.json', nil, 'Cookie' => response.headers['Set-Cookie']
      expect(response.code).to eq '200'
      expect { JSON.parse(response.body) }.to_not raise_error
    end

    context 'token expiring in 60 seconds' do
      let(:token) { jwt_for(member, exp: 60.seconds.from_now.to_i) }

      before do
        Redis::Store.any_instance.expects(:set).at_least_once.with do |key, value, options|
          options[:expire_after] >= 55 && options[:expire_after] <= 60 # Add a little leeway.
        end
      end

      it 'saves session in Redis with TTL of 60 seconds' do
        api_post '/api/v2/sessions', token: token
        expect(response.code).to eq '201'
      end
    end
  end

  describe 'DELETE /sessions' do
    context 'without token' do
      it 'requires authentication' do
        api_delete '/api/v2/sessions'
        expect(response.code).to eq '401'
      end
    end

    context 'without session established' do
      it 'doesn\'t not fail' do
        api_delete '/api/v2/sessions', token: token
        expect(response.code).to eq '200'
      end
    end
  end

  it 'allows to create and destroy session' do
    api_post '/api/v2/sessions', token: token
    expect(response.code).to eq '201'
    expect(session_utils.fetch_member_session_ids(member.id).count).to be 1
    api_delete '/api/v2/sessions', token: token
    expect(response.code).to eq '200'
    expect(session_utils.fetch_member_session_ids(member.id).count).to be 0
  end
end
