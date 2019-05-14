# Currency plugin development and integration.

Peatio Plugin API v2 gives ability to extend Peatio with any coin
which fits into basic [Blockchain](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract) and [Wallet](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract)
interfaces described inside [peatio-core](https://github.com/rubykube/peatio-core) gem.

## Development.

### Start from reading Blockchain and Wallet doc.

You need to be familiar with [Blockchain](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract)
and [Wallet](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract) interfaces.

*Note that you can skip optional methods if they are not supported by your coin*

### Start with coin API research.

First of all need to start your coin node locally or inside VM and try to access it via HTTP e.g using `curl` or `http`.
You need to study your coin API to get list of calls for implementing [Blockchain](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract) and
[Wallet](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract) interfaces. 

*Note that single method may require multiple API calls*.

We next list of JSON RPC methods for Bitcoin integration:
  * getbalance
  * getblock  
  * getblockcount
  * getblockhash
  * getnewaddress
  * listaddressgroupings
  * sendtoaddress
  
For Ethereum Blockchain (ETH, ERC20) we use next list of methods:
  * eth_blockNumber
  * eth_getBalance
  * eth_call
  * eth_getTransactionReceipt
  * eth_getBlockByNumber
  * personal_newAccount
  * personal_sendTransaction
  
### Start your gem implementation.

During this step you will create your own ruby gem for implementing your coin Blockchain and Wallet classes.

We will use peatio-litecoin as example. You could find gem source [here](https://github.com/rubukybe/peatio-litecoin)

1. Create a new gem. And update .gemspec.
```bash
bundle gem peatio-litecoin
```

2. Add peatio dependency.



