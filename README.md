<h2>Truthcoin: Decentralized Bitcoin Prediction Markets</h2>

This is the theoretical work behind [the actual C++ implementation here](https://github.com/truthcoin/truthcoin-cpp).

<h4>Summary</h4>  
Truthcoin is my ambitious project to create a trustless P2P prediction-marketplace. This is possible because, unlike most marketplaces, the end product of a prediction market (PM) is information. Bitcoin adds the second piece of the puzzle: the exchange of value. The end result is the first of its kind: a market for actual prediction-commodities, which have a value based on their accuracy and not based on the behavior of any administrator, rival trader, or counterparty.

Traditional PMs have been persecuted much in the same way as e-cash systems, and current Bitcoin alternatives require the user to trust the operator to:  
1. Keep funds safe.  
2. Create desirable markets.  
3. Accurately determine the outcome of markets.  

Instead, Truthcoin's outcomes are determined by [a vote weighted by present and past conformity](https://lyoshenka.ocpu.io/truthcoindemo/www/), using in [a new token-ownership-model](http://www.truthcoin.info/presentations/truthcoin-outcomes.pdf). This theoretically produces a unique Nash Equilibrium of unanimous honesty. Moreover, incentives are to only create contracts which are useful (measured by trading volume), and unambiguous (measured by vote-similarity). Additionally, market liquidity is guaranteed to be permanently nonzero thanks to the [LMSR](http://hanson.gmu.edu/mktscore.pdf). MSRs allow for simple, secure, realtime buying and selling.

<h4>What's going on!?</h4>
Look at some [Slide Shows](http://www.truthcoin.info/presentations/).  
[This written intro](https://github.com/psztorc/Truthcoin/raw/master/docs/1_Purpose.pdf) explains "what this is and why it is important".  
[The whitepaper](https://github.com/psztorc/Truthcoin/raw/master/docs/Truthcoin_Whitepaper.pdf) explains "how it works".  
Check out the [voting demo](https://lyoshenka.ocpu.io/truthcoindemo/www/).  
Read the [FAQ](http://www.truthcoin.info/faq/).  
Visit the [website](http://www.truthcoin.info/) and [forum](http://forum.truthcoin.info/). 

<!--
<h4>Rough Comparison to Popular CryptoProjects</h4>

| Concept   | P2P Coin| "Old" PoW Mining   | PMs - Trust 3rd Party (Administrator) | PMs - Trust 2nd Party (Traders) | Low-Trust PMs | Can Solve Computations | Score (X,*,.) |
| :-------- | :------:| :--: | :--------:| :--: | :--------:| :--: | :--------:| :--: |
| Truthcoin  ?  | X | X | * | * | X | *?| 3, 2, 1 |
| Bitcoin       | X | X | * | * | . | *?| 2, 2, 2 |
| BitsharesX    | X | . | * | X | . | . | 2, 1, 3 |
| Counterparty  | X | X | X | * | . | . | 3, 1, 2 |
| Ethereum ?    | * | . | * | * | * | X | 1, 4, 1 |
| Mastercoin    | X | X | X | * | . | . | 3, 1, 2 |
| NXT Coin      | X | . | * | * | . | . | 1, 2, 3 |
| USD           | . | . | * | * | . | . | 0, 2, 4 |

Legend: X = "Yes (Inherently Supported)", . = "No (Inherently Unsupported)", * = "Can Build on Top of / Third-Party"

Table Notes:  
1. Compiled on a best-effort basis. Mistake? Pull-request / email me.  
2. Emphasis is on differences across coins, so many similarities were ignored (token issuance).  
3. The question marks indicate some unproven claims, or vague theories, which have yet to be fully explored, tested, and resolved (these score as 'No'). When used after a concept name, they indicate that the concept does not yet exist.  
4. Given that 3 of the columns are about PMs, and even somewhat mutually-exclusive, the score column really isn't very meaningful.
5. -->



<h4>You Can Help!</h4> 
1. Read the documentation / code and ask questions to grow the FAQ! (<a href="mailto:truthcoin@gmail.com?subject=Feedback">Email me</a> or pull into [the errata section](https://github.com/psztorc/Truthcoin/tree/master/docs#addendum--errata) or [the FAQ section](https://github.com/truthcoin/www.truthcoin.info/blob/gh-pages/faq/index.md) with any new questions). 
2. Joining and posting to the forum.  
3. Help test/improve the code. Or, work for money and use that money to hire someone who can test/improve the code!


<h4>Where is Everything?</h4>
Code: 'lib' folder
Readings/Documentation/Purpose/Applications/Tech: 'docs' folder 
 
The 'lib' folder also has html files which describe the outcome of function tests and demonstrations. These files were automatically generated from R code using R-markdown, and the .rmd files are included alongside the html files for reproducibility.


<h4>Contact</h4>
truthcoin@gmail.com  
https://twitter.com/Truthcoin  

Donation Address: [1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8](https://blockchain.info/address/1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8)  
I'm giving away all of this work for free. It was hard work!  
Thanks to everyone who donated.