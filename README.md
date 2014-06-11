<h2>Truthcoin: Decentralized Bitcoin Prediction Markets</h2>
Truthcoin is my ambitious project to create a trustless P2P prediction-marketplace. This is possible because, unlike most marketplaces, the end product of a prediction market (PM) is information. Bitcoin adds the second piece of the puzzle: the exchange of value. The end result is the first of its kind: a market for actual prediction-commodities, which have a value based on their accuracy and not based on the behaviour of any administrator, rival trader, or counterparty.

Traditional PMs have been persecuted much in the same way as e-cash systems, and current Bitcoin alternatives require the user to trust the operator to 1] keep funds safe, 2] create desirable markets, and 3] correctly determine the outcome of markets.  

Contract outcomes are determined in a trustless and decentralized way, through a weighted vote based on present and past consensus with a unique Nash Equilibrium where all voters report accurately on the state of markets. Incentives are to only create contracts which are useful (measured by trading volume), and unambiguous (measured by vote-similarity). Additionally, market liquidity (a frequent problem) is guaranteed to be permanently nonzero thanks to the LMSR, an invention of Dr. Robin Hanson. The LMSR's use of an update rule instead of actual Buy/Ask trading greatly simplifies implementation, while allowing for realtime buying and selling.

<h4>What's going on!?</h4>
Read [this](https://github.com/psztorc/Truthcoin/raw/master/docs/1_Purpose.pdf) to understand "what this is and why it is important".  
Visit our new forum: http://forum.truthcoin.info/  

<h3>Rough Comparison to Popular CryptoProjects</h3>

| Concept   | P2P Coin| "Old" PoW Mining   | PMs - Trust 3rd Party (Administrator) | PMs - Trust 2nd Party (Traders) | Low-Trust PMs | Can Solve Computations | Score (X,*,.) |
| :-------- | :------:| :--: | :--------:| :--: | :--------:| :--: | :--------:| :--: |
| Truthcoin  ?  | X | X | * | * | X | *?| 3, 2, 1 |
| Bitcoin       | X | X | * | * | . | *?| 2, 2, 2 |
| BitsharesX ?  | X | . | * | X | . | . | 2, 1, 3 |
| Counterparty  | X | X | X | * | . | . | 3, 1, 2 |
| Etherium ?    | * | . | * | * | * | X | 1, 4, 1 |
| Mastercoin    | X | X | X | * | . | . | 3, 1, 2 |
| NXT Coin      | X | . | * | * | . | . | 1, 2, 3 |
| USD           | . | . | * | * | . | . | 0, 2, 4 |

Legend: X = "Yes (Inherently Supported)", . = "No (Inherently Unsupported)", * = "Can Build on Top of / Third-Party"

Table Notes:
1. Compiled on a best-effort basis. Mistake? Pull-request / email me.
2. Emphasis is on differences across coins, so many similarities were ignored (token issuance).
3. The question marks indicate some unproven claims, or vague theories, which have yet to be fully explored, tested, and resolved (these score as 'No'). When used after a concept name, they indicate that the concept does not yet exist.
4. Given that 3 of the columns are about PMs, and even somewhat mutually-exclusive, the score column really isn't very meaningful.


<h3>My Pipeline</h3>

**Please be aware that this project exists only as a design with some proof of concept code for the novel parts. There is no useable version yet, although I expect it to be very easy to build.** In fact all the code/writing here was created solely by one guy (although we all stand on the shoulders of giants).  

I'm Working on Now: Rewrite new R items in python.  
I'm Working on Now: Evangelize via forum posts, FAQ improvements, etc.  
Up Next: Seek development collaborators, and/or funding (for development). Anyone, anyone?  

<h3>You Might Help By</h3> 
Asking questions to grow the FAQ.  
Posting to the forum (I'll be adding more posts soon).  
Telling your friends (especially developers/investors).  
I'm interested in starting a website where I can test the Event Consensus Mechanism in various ways.  This probably involves some web design/php. Need a way of keeping score / displaying the score, and having users supply a simple number or boolean.  
Operationalizing "Sequential Intra-Block Trading", my protocol for near-instant-speed trades (easier than it sounds, just select 0-confirmed outputs, timestamp entire set, see Whitepaper and ctrl+f for why this works, email me to collaborate).  



<h4>Where is Everything?</h4>
Readings/Documentation/Purpose/Applications/Tech = 'docs' folder  
Details about tx types:  docs/Development Plans/  
R code = 'lib' folder  
Python code = 'pylib' folder  

The 'lib' folder also has html files which describe the outcome of function tests and demonstrations. These files were automatically generated from R code using R-markdown, and the .rmd files are included alongside the html files for reproducibility.



<h4>Contact</h4>
truthcoin@gmail.com  
https://twitter.com/Truthcoin  

Donation Address: 1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8  
https://blockchain.info/address/1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8  
I'm giving away all of this work for free. It was hard work!  
Thanks to everyone who donated.  
  
Please share your opinion, and your questions so the FAQ (docs page) can grow!  