describe Bitcoin::Blockchain do
  it :initialize do
    blockchain1 = Bitcoin::Blockchain.new
    expect(blockchain1.features).to eq Bitcoin::Blockchain::DEFAULT_FEATURES

    blockchain2 = Bitcoin::Blockchain.new(supports_cash_addr_format: true)
    expect(blockchain2.features[:supports_cash_addr_format]).to be_truthy

    blockchain3 = Bitcoin::Blockchain.new(custom_feature: :custom)
    expect(blockchain3.features.keys).to contain_exactly(:supports_cash_addr_format, :case_sensitive)
  end

  it :configure do
    blockchain = Bitcoin::Blockchain.new
    expect(blockchain.settings).to eq({})

    currencies = Currency.where(type: :coin).first(2).map(&:to_blockchain_api_settings)
    settings = { server: 'http://user:password@127.0.0.1:18332',
                 currencies: currencies,
                 something: :custom }
    blockchain.configure(settings)

    expect(blockchain.settings).to eq(settings.slice(*Peatio::Blockchain::Abstract::SUPPORTED_SETTINGS))
  end
end
