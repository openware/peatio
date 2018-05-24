# encoding: UTF-8
# frozen_string_literal: true

describe HealthChecker do
  describe '.ready' do
    before do
      Market.delete_all
    end

    subject { described_class.ready }

    it 'returns false if market is blank' do
      is_expected.to eq false
    end

    it 'returns true if market is present' do
      create(:market, :btcusd)
      is_expected.to eq true
    end

    it 'returns false if check_db raises an exception' do
      expect { described_class.check_db }.to raise_error(Exception)
      is_expected.to eq false
    end
  end

  describe '.alive' do
    let(:check_db) { true }
    let(:check_redis) { true }
    let(:check_rabbitmq) { true }

    def mock_health_checks(except:)
      (described_class::LIVE_CHECKS - [except]).each do |check_method|
        let_result = send(check_method)
        described_class.stubs(check_method).returns(let_result)
      end
    end

    context 'check redis' do
      subject { described_class.alive }
      let(:fake_redis) { mock }
      before do
        mock_health_checks(except: :check_redis)
        KlineDB.stubs(:redis).returns(fake_redis)
      end

      context 'when no connection to redis' do
        before { fake_redis.stubs(:ping).raises(Exception) }
        it { is_expected.to eq false }
      end

      context 'when redis returns an invalid message' do
        before { fake_redis.stubs(:ping).returns('error') }
        it { is_expected.to eq false }
      end

      context 'when redis retuns a valid message' do
        before { fake_redis.stubs(:ping).returns('PONG') }
        it { is_expected.to eq true }
      end
    end

    context 'check rabbitmq' do
      subject { described_class.alive }
      let(:fake_rabbitmq) do
        stub(close: close_status,
             connected?: connection_status,
             start: stub)
      end
      let(:close_status) { true }
      before do
        mock_health_checks(except: :check_rabbitmq)
        Bunny.stubs(:new).returns(fake_rabbitmq)
      end

      context 'when no connection to rabbitmq' do
        let(:connection_status) { false }
        it { is_expected.to eq false }
      end

      context 'when has connection to rabbitmq' do
        let(:connection_status) { true }
        it { is_expected.to eq true }
      end

      context 'when can not close rabbitmq' do
        let(:connection_status) { true }
        let(:close_status) { false }
        it { is_expected.to eq false }
      end
    end
  end
end
