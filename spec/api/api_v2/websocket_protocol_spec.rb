# encoding: UTF-8
# frozen_string_literal: true

require 'api_v2/websocket_protocol'

describe 'WebSocketAPI' do
  include EM::SpecHelper

  let(:conn) { BunnyMock.new.start }
  let(:channel) { conn.channel }
  let(:logger) { Rails.logger }
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:ws_client) { EventMachine::WebSocketClient.connect("ws://#{ENV['WEBSOCKET_HOST']}:#{ENV['WEBSOCKET_PORT']}/") }

  context 'valid token' do
    before do
      APIv2::WebSocketProtocol.any_instance.stubs(:subscribe_orders)
      APIv2::WebSocketProtocol.any_instance.stubs(:subscribe_trades)
    end
    it "user successfully authenticated" do
      em {
        start_server do |ws|
          protocol = APIv2::WebSocketProtocol.new(ws, channel, logger)
          ws.onmessage { |msg| protocol.handle msg }
          ws.onclose{ |status|
            status[:code].should == 1006 # Unclean
            status[:was_clean].should be false
          }
        end

        EM.add_timer(0.1) do
          auth_msg = {jwt: "Bearer #{token}"} # valid token
          ws_client.callback { ws_client.send_msg auth_msg.to_json}
          ws_client.disconnect { done }
          ws_client.stream { |msg|
            expect(msg.data).to eq "{\"success\":{\"message\":\"Authenticated.\"}}"
            done
          }
        end
      }
    end
  end

  context 'invalid token' do
    it "user authentication failed" do
      em {
        start_server do |ws|
          protocol = APIv2::WebSocketProtocol.new(ws, channel, logger)
          ws.onmessage { |msg| protocol.handle msg }
          ws.onclose{ |status|
            status[:code].should == 1006 # Unclean
            status[:was_clean].should be false
          }
        end

        EM.add_timer(0.1) do
          auth_msg = {jwt: "Bearer #{token}y"} #invalid token
          ws_client.callback { ws_client.send_msg auth_msg.to_json}
          ws_client.disconnect { done }
          ws_client.stream { |msg|
            expect(msg.data).to eq "{\"error\":{\"message\":\"Authentication failed.\"}}"
            done
          }
        end
      }
    end
  end

end

