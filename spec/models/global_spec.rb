describe Global do
  let(:global) { Global["btc#{Peatio.base_fiat_ccy.downcase}"] }
end
