<h1>Truthcoin: Decentralized Bitcoin Prediction Markets</h1>
Truthcoin is my ambitious project to create a censorship-resistant prediction-marketplace. This is possible because, unlike most marketplaces, the end product of a prediction market (PM) is information. Bitcoin adds the second piece of the puzzle: the exchange of value.

Contract outcomes are determined by a weighted vote based on present and past consensus with (theoretically) a unique Nash Equilibrium where all voters place 'open contracts' (contracts for events that have already happened) into the correct state, and only contracts anticipated to generate sufficiently-high transaction volume are created at all. Additionally, market liquidity (a frequent problem on sites such as InTrade.com) is guaranteed to be permanently nonzero thanks to the LMSR, an invention of Dr. Robin Hanson.

<h2>Directory</h2>
R code is generally in the 'lib' folder, Python code is in the 'pylib' folder, other items (documentation, purpose, applications) are generally in the 'docs' folder. The 'lib' folder also has html files which describe the outcome of function tests and demonstrations. These files were automatically generated from R code using R-markdown, and the .rmd files are included alongside the html files for reproducibility.

<h2>Current Status</h2>
The open design question (transaction signing), preliminary survey of experts has not been promising. Two working solutions have been eliminated, so I have temporarily retreated to the most-conservative 'BothCoin' strategy (where this blockchain would actually track two assets, representing "money" and "reputation"). I remain hopeful that a crypto expert will allow this system to work more directly with Bitcoin, but perhaps it is best to test everything on a completely new currency first anyway. My personal development activities are on schedule.

<h2>Pipeline</h2>
Finish python re-code: market transactions, block items. Project Management: More clearly state development goals and requirements, timeline, dependencies.

<h2>Frequently Asked Questions</h2>
<h4>Reading:</h4>
In addition to my whitepaper describing the logical protocol which creates and manages decentrailed prediction markets (Truthcoin_1.1.pdf), I wrote many papers on Prediction Markets, including and overview of what they are [1], how they can be assembled into different types for maximum impact [2], how they can be used to improve our lives [3], some myths about PMs which I still hear [4], and a comment on manipulation and why it  is mostly impossible [5].

These files can all be found in the /docs folder.

<h4>I can't open these pdfs!</h4>
Click on the filename, then click on the small central box labeled 'Raw', which can be found in the trio of boxes to the right of the file size.


<h4>If you have votes, how do you know that people wont just lie and claim the outcome was whatever will benefit them personally?</h4>
Check 'voting strategy' in the Whitepaper (docs folder). The code/function library which prevents this has been finished in both R and Python flavors.


<h4>What about a 'decentralized feed' for stocks/bonds/other markets I'd like to replace with cryptocurrency magic?</h4>
Although I failed to generalize this project from discrete Yes/No events to continuous variables, it is a trivial application of the binomial option pricing model to use PMs to generate a portfolio whose return will equal that of an underlying asset. This is possible even with just a single PM. I sketched together an example of such a replicating portfolio (ContinuousEstimation.xlsx) in docs/Notes.

<h4>Prediction markets are a waste of time because no one uses them, drying up the liquidity and punishing the few who dared to try to make the market work.</h4>
The liquidity problem has been solved, even if the solution is widely ignored: http://hanson.gmu.edu/mktscore.pdf
I threw together an Excel sheet in the docs folder (LogMSR_Demo.xlsx) for additional clarification. Feedback is appreciated.

<h4>How do I contact you?</h4>
truthcoin@gmail.com
Please share your opinion, and your questions so the FAQ can grow!

<h4>Donation Address</h4>
1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8