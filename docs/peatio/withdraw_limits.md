## Global Withdraw Limits

This doc describes how Peatio Withdraw Limits works

Withdraw Limits schema:

| Term           | Definition                                       |
| -------------- | ------------------------------------------------ |
| Group          | Member group. Will be used to select limit       |
| KYC Level      | Member KYC level. Will be used to select limit   |
| 24 hour limit  | 24 hour limit in platform currency e.g. USD      |
| 1 month limit  | 1 month limit in platform currency e.g. USD      |

Withdraw limit suitability expressed in weight. KYC level has greater weight then group match.

E.g. Withdrawal for member with kyc_level 2, group 'vip-0'

(kyc_level == 2 && group == 'vip-0') >>

(kyc_level == 2 && group == 'any') >>

(kyc_level == 'any' && group == 'vip-0') >>

(kyc_level == 'any' && group == 'any')

Withdraw limits check flow:

1. If the user hasn't reached any withdrawal limits, the system process the withdrawal request automatically from the currency 'Hot wallet'. If the 'Hot wallet' doesn't have enough funds to process the withdrawal request the system will throw an error. In this situation, the admin needs to replenish the 'Hot wallet'.

2. If the user reached at least one of withdrawal limits (24 hours or 1 month) the system accepts the request, locks the user funds but doesn't process the withdraw automatically. Admin can manually reject or process this withdrawal request from the 'Hot wallet' or process it manually from the warm wallet.

More info about [Peatio Financial Flow](https://www.openware.com/sdk/guides/operator/financial-flow.html) and [Peatio Wallet Guidelines](https://www.openware.com/sdk/guides/operator/wallet-guidelines.html).
