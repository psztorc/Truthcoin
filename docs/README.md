Documents
------------------------------------------

[Truthcoin_1.1.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/Truthcoin_1.1.pdf) - My whitepaper describing a software protocol which creates and manages decentralized prediction markets (PMs).  

Other papers which describe the overall purposes and goals of this endeavour:  

1. [What PMs are and why they're important.](https://github.com/psztorc/Truthcoin/raw/master/docs/1_Purpose.pdf)  
2. [How PMs can be assembled into different types (for maximum impact).](https://github.com/psztorc/Truthcoin/raw/master/docs/2_PM_Types.pdf)  
3. [How PMs can be used in ways other than simply predicting the future.](https://github.com/psztorc/Truthcoin/raw/master/docs/3_PM_Applications.pdf)  
4. [Some myths about PMs which I still hear.](https://github.com/psztorc/Truthcoin/raw/master/docs/4_PM_Myths.pdf)  
5. [A comment on PM-manipulation and why it actually is helpful (by providing profit opportunities).](https://github.com/psztorc/Truthcoin/raw/master/docs/5_PM_Manipulation.pdf)


FAQ
------------------------------------------

### Basics / Project Scope

#### What does this project aim to accomplish?
Traditional PMs have many problems:  
1. Counterparty risk (must trust whoever is holding the money to use it as promised). CR is why one can't make bets with certain friends.  
2. The trustworthy PM-administrator must (coincidentally) share your taste in PM topics.  
3. The PM-administrator would have to be expected to provide service for a length of time (and not be interrupted by an executive's death or regulatory interference).  
4. PM-administrator would have to offer competitive prices, be economically viable, not go out of business, etc.  
This project aims to solve all of these problems.  

#### How do I contact you?
truthcoin@gmail.com  
Please share your opinion, and your questions so the FAQ can grow!

#### Donation Address
1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8

### PM-Questions

#### Can't PMs be driven by people who are oblivious to who little they know?
Yes, at first. However, these people will quickly start losing large quantities of money, and thereby lose their ability to influence the market. Moreover, the existence of these ignorant "sheep" will attract "wolves" who profit by correcting the mistakes of the sheep.

#### How do you address the problem of low liquidity?
For PMs which are bounded (ie, will be worth between 0 and $1), tt is possible to design them such that traders can always update the market price, by trading with an automated market maker powered by a market scoring rule. http://hanson.gmu.edu/mktscore.pdf
I threw together an Excel sheet in the docs folder [LogMSR_Demo.xlsx](https://github.com/psztorc/Truthcoin/raw/master/docs/LogMSR_Demo.xlsx) for additional clarification. Feedback is appreciated.




### Incentives
#### How do you know that people wont claim an outcome was whatever will benefit them personally?
Voters have a strong incentive to vote "the way they believe other will vote". Coupled with a desire to collect trading fees (which are higher in a useful marketplace vs. a useless one), voters all have an incentive to vote accurately on all outcomes.
Check 'voting strategy' in the Whitepaper (docs folder). The code/function library which prevents this has been finished in both R and Python flavors.




