# frozen_string_literal: true

require 'faye/websocket'
require 'eventmachine'

pid = Process.spawn('bundle exec ruby lib/daemons/websocket_api.rb')

describe 'WebSocketAPI' do
  let(:member) { create(:member, :verified_identity) }
  let(:token) { jwt_for(member) }
  let(:ws) { ws_conn }

  it 'Should authenticate with jwt token' do
    TestThread = Thread.new do
      EventMachine.run do
        auth = { auth: 'Auth', jwt: token }
        @result = ws.send auth
        @ready = true
      end
    end

    p 'Waiting...' until @ready

    binding.pry

    expect(@result).to eq true
  end
end

Process.kill 'STOP', pid