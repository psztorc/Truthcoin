
Documentation
======================================

Papers
-------------------------------

[Truthcoin_Whitepaper.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/Truthcoin_Whitepaper.pdf) - My whitepaper describing a software protocol which creates and manages decentralized prediction markets (PMs).  
[TruthcoinValuable.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/TruthcoinValuable.pdf) - A simple slide deck on the potential return available to contributing investors / programmers ([.pptx](https://github.com/psztorc/Truthcoin/raw/master/docs/TruthcoinValuable.pptx) with presentation notes).  

Other papers which describe the overall purposes and goals of this endeavour:  

1. [What PMs are and why they're important.](https://github.com/psztorc/Truthcoin/raw/master/docs/1_Purpose.pdf)  
2. [How PMs can be assembled into different types (for maximum impact).](https://github.com/psztorc/Truthcoin/raw/master/docs/2_PM_Types.pdf)  
3. [How PMs can be used in ways other than simply predicting the future.](https://github.com/psztorc/Truthcoin/raw/master/docs/3_PM_Applications.pdf)  
4. [Some myths about PMs which I still hear.](https://github.com/psztorc/Truthcoin/raw/master/docs/4_PM_Myths.pdf)  
5. [A comment on PM-manipulation and why it actually is helpful (by providing profit opportunities).](https://github.com/psztorc/Truthcoin/raw/master/docs/5_PM_Manipulation.pdf)



Addendum / Errata
------------------------------------------
Find a typo? Was anything not **completely clear**? Send me an email or pull request right into this sucker:

### Whitepaper

1. Change terminology: "Voting Period" implies that what-is-being-discussed is "the time it takes to vote". Instead, call it "Intervote Period", or "Voting Cycle Length" or something.
2. Emphasize that Tau-'Voting' and Tau-'Unsealing' really not vary anywhere near as much as Tau-'Idle'. Voting/Unsealing need to be more or less fixed at 1000 or so blocks.
3. Explain the {'free option' to own a future Branch} better.
4. Change the Encryption Vote Seal method of voting to the Hash-Publish as described on forum.
5. Emphasize that Auditors fight over Pooled Trading Fees: 
	1. Half to the Auditors.
	2. Half to the Ballot which agreed with the Auditors (this is what encourages minority voters to 'stick it out').
	3. Erase the 'Audit Fee parameter' as it is terrible way of explaining this.
4. Update Figure of the Attacker-flowchart, possibly warrants a whole second page at this point.
5. Explain the Miner-Veto Concept better
	1. Princeton idea isn't great - consensus failure, laziness, instability
	2. Better is a 'fail-SAFE' (more like mining an empty block)
		1. Nonce + Vetos have no signature.
	2. Explain that it will probably never be used (and this is a good thing).
2. Fee1 can be set by >Phi Branch vote.
3. Explain that it is extremely easy to have Markets not just reference Decisions, but also LOG, LN, ()^2, ()^3, etc of Decisions.
4. Update the Vote-Outcome plot using the new PlotJ().
5. Add the 'teacher story' as an appendix item.
6. Typo on page 4: "continute".
7. Add backlinks to figures.
8. Explain that Scaled Decisions resolving to ".5" must be 'dodged' from the user's point of view
	1. 'Unclear' should return ".5", and '.5' should return ~".5000001"
	1. Remove previous explanation about max-min. 
2. Describe an "Open" transaction, (likely ideal for low-dimensional, illiquid markets) where 2 parties could purchase and split $X worth of complete-sets. For example, pay $20,000 total at prices (p1, p2) to give (s1, s2) shares to identities (i1, i2).
3. Add the concept of "non-outsourceable" VTC buying/selling (one VTC private key per transfer), to prevent an obscure but critical assurance-contract attack (which would place attacker a world where he only had to purchase when his attack would succeed).
4. Improve Appendix b / 2 on page 35, by highlight the (1-p) case, and by adding examples that aren't 2 by 2, to highlight the ( p + (1-p) ) / 2 aggregation in the code.


FAQ
------------------------------------------

FAQ has been moved to: [http://www.truthcoin.info/faq/](http://www.truthcoin.info/faq/)


Notes to Self
---------

1. Just as Namecoin has an extra tab for names, ideally an extra tab for Markets / Trading.
2. Toggle an 'Voter/Employee Mode' to access a Voting tab.
3. Concept of a "Voter helper": gets info from 'recentralizers' (reddit, google, twitter, etc).
4. Arbitrage Helper (described slightly in Paper #3).
5. Voters for 'Unclear' always become ".5". For this reason, clear votes for a value which would actually translate to .5 must instead translate to .500001 or so.
6. 