describe CoinAPI::BCH do
  let(:client) { CoinAPI[:bch] }

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe '#normalize_address' do
    context 'Normalize to legacy address' do
      let(:address) { '2NFrwq5URJriK9MqamjpBx2xLF8WLTEDD7W' }

      subject { client.normalize_address(address) }
      it { is_expected.to eq('2NFrwq5URJriK9MqamjpBx2xLF8WLTEDD7W') }
    end

    context 'Normalize from a CashAddr address to legacy address' do
      let(:address) { 'bchtest:qpqtmmfpw79thzq5z7s0spcd87uhn6d34uqqem83hf' }

      subject { client.normalize_address(address) }
      it { is_expected.to eq('mmRH4e9WW4ekZUP5HvBScfUyaSUjfQRyvD') }
    end
  end
end