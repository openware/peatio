Peatio::Blockchain.registry[:bitcoin] = Bitcoin::Blockchain.new
Peatio::Blockchain.registry[:geth] = Ethereum1::Blockchain.new
Peatio::Blockchain.registry[:parity] = Ethereum1::Blockchain.new
