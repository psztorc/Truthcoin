
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
Find a typo? Was anything not **completely clear**? Send me an email or pull request into this section:

Whitepaper  

1. Andrew Poelstra has pointed out (and I agree) that there should be breif periods (20 blocks or so) of forced VoteCoin inactivity between each of the steps of the Voting Period. This costs the protocol almost-nothing, but prevents a kind of bizarre uncertainty where extremely confused or reckless Voters accidentally do something which might give other Voter-Miner coalitions an incentive to wait until the last to cast their vote (and potentially try to rewind it [if the reckless thing is done]).
2. A reader has pointed out that the offered limit of 100K Voters per Outcome resolution per Branch (in performing SVD) may in fact be conservative, and points out that [the SVDPACK library](http://www.netlib.org/svdpack/) can handle a dataset of size 100M x 500k in reasonable time.





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