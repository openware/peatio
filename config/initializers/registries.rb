# Wallets

Peatio::Wallet.registry[:bitcoind] = Bitcoin::Wallet
Peatio::Wallet.registry[:geth] = Ethereum::Wallet
Peatio::Wallet.registry[:parity] = Ethereum::Wallet
Peatio::Wallet.registry[:gnosis] = Gnosis::Wallet
Peatio::Wallet.registry[:ow_hdwallet] = OWHDWallet::Wallet
Peatio::Wallet.registry[:opendax] = OWHDWallet::Wallet
Peatio::Wallet.registry[:opendax_cloud] = OpendaxCloud::Wallet

# Blockchains

Peatio::Blockchain.registry[:bitcoin] = Bitcoin::Blockchain
Peatio::Blockchain.registry[:geth] = Ethereum::Blockchain
Peatio::Blockchain.registry[:parity] = Ethereum::Blockchain


# Upstreams
require 'peatio/upstream/opendax'
Peatio::Upstream.registry[:opendax] = Peatio::Upstream::Opendax
