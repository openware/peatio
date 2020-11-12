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

1. If the user hasn't reached any withdrawal limits, the system process the withdrawal request automatically from 'Hot wallet'. If 'Hot wallet' doesn't have enough funds to process the withdrawal request the system throw error. In this situation, the admin needs to replenish 'Hot wallet'.

2. If the user reached at least one of withdrawal limits (24 hours or 1 months) the system accepting that request, lock user funds but doesn't process it automatically. Admin can manually reject or process that withdrawal request from 'Hot wallet' or process manually by the admin from warm the wallet. More info about [Financial Flow](https://www.openware.com/sdk/guides/operator/financial-flow.html) and [Wallet Guidelines](https://www.openware.com/sdk/guides/operator/wallet-guidelines.html).