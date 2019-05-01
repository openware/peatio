Peatio::WalletAPI.register(:bitcoind, Bitcoin::Wallet.new)
Peatio::WalletAPI.register(:geth, Ethereum1::Wallet)
Peatio::WalletAPI.register(:peth, Ethereum1::Wallet)
