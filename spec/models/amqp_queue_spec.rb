# encoding: UTF-8
# frozen_string_literal: true

describe AMQP::Queue do
  let(:config) do
    Hashie::Mash.new(connect:   { host: '127.0.0.1' },
                     exchange:  { testx: { name: 'testx', type: 'fanout' } },
                     queue:     { testq: { name: 'testq', durable: true },
                                  testd: { name: 'testd' } },
                     binding:   {
                       test:    { queue: 'testq', exchange: 'testx' },
                       testd:   { queue: 'testd' },
                       default: { queue: 'testq' }
                     })
  end

  let(:default_exchange) { double('default_exchange') }
  let(:channel) { double('channel', default_exchange: default_exchange) }

  before do
    allow(AMQP::Config).to receive(:data).and_return(config)

    allow(AMQP::Queue).to receive(:publish).and_call_original
    allow(AMQP::Queue).to receive(:exchanges).and_return(default: default_exchange)
    allow(AMQP::Queue).to receive(:channel).and_return(channel)
  end

  it 'should instantiate exchange use exchange config' do
    expect(channel).to receive(:fanout).with('testx')
    AMQP::Queue.exchange(:testx)
  end

  it 'should publish message on selected exchange' do
    exchange = double('test exchange')
    expect(channel).to receive(:fanout).with('testx').and_return(exchange)
    expect(exchange).to receive(:publish).with(JSON.dump(data: 'hello'), {})
    AMQP::Queue.publish(:testx, data: 'hello')
  end

  it 'should publish message on default exchange' do
    expect(default_exchange).to receive(:publish).with(JSON.dump(data: 'hello'), routing_key: 'testd')
    AMQP::Queue.enqueue(:testd, data: 'hello')
  end
end
