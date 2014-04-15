<h2>Truthcoin: Decentralized Bitcoin Prediction Markets</h2>
Truthcoin is my ambitious project to create a trustless P2P prediction-marketplace. This is possible because, unlike most marketplaces, the end product of a prediction market (PM) is information. Bitcoin adds the second piece of the puzzle: the exchange of value.  

Traditional PMs have been persecuted much in the same way as e-cash systems, and current Bitcoin alternatives require the user to trust the operator to 1] keep funds safe, 2] create desirable markets, and 3] correctly determine the outcome of markets.  

Contract outcomes are determined in a trustless and decentralized way, through a weighted vote based on present and past consensus with a unique Nash Equilibrium where all voters report accurately on the sate of markets. Incentives are such that contracts are only created if they are anticipated to generate sufficiently-high transaction volume and be unambiguous in their outcome. Additionally, market liquidity (a frequent problem) is guaranteed to be permanently nonzero thanks to the LMSR, an invention of Dr. Robin Hanson. The LMSR's use of an update rule instead of actual Buy/Ask trading greatly simplifies implementation, while allowing for realtime buying and selling.

<h3>Pipeline</h3>
Now: Transaction Types and Data Structures (for implementation planning)
Up Next: FAQ
Up Next: Other cleanup, LMSR/Continuous .xls file-readability.
Up Next: Seek funding / development team.

<h4>What's going on!?</h4>
Read [this](https://github.com/psztorc/Truthcoin/raw/master/docs/1_Purpose.pdf) to understand "what this is and why it is important".

<h4>Where is Everything?</h4>
R code ='lib' folder, Python code = 'pylib' folder, other items (documentation, purpose, applications) = 'docs' folder.  
The 'lib' folder also has html files which describe the outcome of function tests and demonstrations. These files were automatically generated from R code using R-markdown, and the .rmd files are included alongside the html files for reproducibility.

<h4>Reading:</h4>
[Truthcoin_1.1.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/Truthcoin_1.1.pdf) - My whitepaper describing a software protocol which creates and manages decentralized prediction markets.  

Other Papers on Prediction Markets:  

1. [What they are.](https://github.com/psztorc/Truthcoin/raw/master/docs/1_Purpose.pdf)  
2. [How they can be assembled into different types (for maximum impact).](https://github.com/psztorc/Truthcoin/raw/master/docs/2_PM_Types.pdf)  
3. [How they can be used in ways other than simply predicting the future.](https://github.com/psztorc/Truthcoin/raw/master/docs/3_PM_Applications.pdf)  
4. [Some myths about PMs which I still hear.](https://github.com/psztorc/Truthcoin/raw/master/docs/4_PM_Myths.pdf)  
5. [A comment on PM manipulation and why it actually is helpful (by providing profit opportunities).](https://github.com/psztorc/Truthcoin/raw/master/docs/5_PM_Manipulation.pdf)

These files can all be found in the /docs folder, prefixed with their number.

<h4>I can't open these pdfs!</h4>
Click on the filename, then click on the small central box labeled 'Raw', which can be found in the trio of boxes to the right of the file size. Do not click on 'View Raw'.


<h4>If you have votes, how do you know that people wont just lie and claim the outcome was whatever will benefit them personally?</h4>
Check 'voting strategy' in the Whitepaper (docs folder). The code/function library which prevents this has been finished in both R and Python flavors.


<h4>What about a 'decentralized feed' for stocks/bonds/other markets (...that I'd like to replace with cryptocurrency magic)?</h4>
Although I failed to generalize this project from discrete Yes/No events to continuous variables, it is a trivial application of the binomial option pricing model to use PMs to generate a portfolio whose return will equal that of an underlying asset. This is possible even with just a single PM. I sketched together an example of such a replicating portfolio [ContinuousEstimation.xlsx](https://github.com/psztorc/Truthcoin/raw/master/docs/Notes/ContinuousEstimation.xlsx) in docs/Notes.

<h4>Prediction markets are a waste of time because no one uses them, drying up the liquidity and punishing the few who dared to try to make the market work.</h4>
The liquidity problem has been solved, even if the solution is widely ignored: http://hanson.gmu.edu/mktscore.pdf
I threw together an Excel sheet in the docs folder [LogMSR_Demo.xlsx](https://github.com/psztorc/Truthcoin/raw/master/docs/LogMSR_Demo.xlsx) for additional clarification. Feedback is appreciated.

<h4>How do I contact you?</h4>
truthcoin@gmail.com
Please share your opinion, and your questions so the FAQ can grow!

<h4>Donation Address</h4>
1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8