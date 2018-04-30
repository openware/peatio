# Adding ERC20 Token Support

## Configuration

First, you will need to update your configuration files (`config/currencies.yml` and `config/markets.yml`).

In `config/currencies.yml` copy the configurations of ETH (Ethereum) and under options add the `erc20_contract_address`  and set API Client `ERC20`.

Change `precision` and `base_factor` accordingly as per the ERC20 Token Requirement. 
