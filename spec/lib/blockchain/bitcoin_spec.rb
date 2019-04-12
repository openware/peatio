describe Bitcoin::Blockchain do
  it :initialize do
    blockchain1 = Bitcoin::Blockchain.new
    expect(blockchain1.settings).to eq Bitcoin::Blockchain::DEFAULT_SETTINGS

    blockchain2 = Bitcoin::Blockchain.new(supports_cash_addr_format: true)
    expect(blockchain2.settings[:supports_cash_addr_format]).to be_truthy

    blockchain3 = Bitcoin::Blockchain.new(unexisting_setting: :custom)
    expect(blockchain3.settings.keys).to contain_exactly(:supports_cash_addr_format, :case_sensitive)
  end

  it :settings do
    blockchain1 = Bitcoin::Blockchain.new
    expect{ blockchain1.send(:settings_key, :supports_cash_addr_format) }.to_not raise_error

  end
end
