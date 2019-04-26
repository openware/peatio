Peatio::BlockchainAPI.register(:bitcoin, Bitcoin::Blockchain.new)
Peatio::BlockchainAPI.register(:geth, Ethereum1::Blockchain.new)
Peatio::BlockchainAPI.register(:parity, Ethereum1::Blockchain.new)
