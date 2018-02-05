describe Bank do
  context '#with_currency' do
    it { expect(Bank.with_currency(Peatio.base_fiat_ccy_sym.downcase)).not_to be_empty }
  end

  context '#currency_obj' do
    subject { Bank.with_currency(Peatio.base_fiat_ccy_sym.downcase).first.currency_obj }
    it { is_expected.to be_present }
  end
end
