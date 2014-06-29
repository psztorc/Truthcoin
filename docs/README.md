
Documentation
======================================

Papers
-------------------------------

[Truthcoin_1.1.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/Truthcoin_1.1.pdf) - My whitepaper describing a software protocol which creates and manages decentralized prediction markets (PMs).  
[TruthcoinValuable.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/TruthcoinValuable.pdf) - A simple slide deck on the potential return available to contributing investors / programmers ([.pptx](https://github.com/psztorc/Truthcoin/raw/master/docs/TruthcoinValuable.pptx) with presentation notes).  

Other papers which describe the overall purposes and goals of this endeavour:  

1. [What PMs are and why they're important.](https://github.com/psztorc/Truthcoin/raw/master/docs/1_Purpose.pdf)  
2. [How PMs can be assembled into different types (for maximum impact).](https://github.com/psztorc/Truthcoin/raw/master/docs/2_PM_Types.pdf)  
3. [How PMs can be used in ways other than simply predicting the future.](https://github.com/psztorc/Truthcoin/raw/master/docs/3_PM_Applications.pdf)  
4. [Some myths about PMs which I still hear.](https://github.com/psztorc/Truthcoin/raw/master/docs/4_PM_Myths.pdf)  
5. [A comment on PM-manipulation and why it actually is helpful (by providing profit opportunities).](https://github.com/psztorc/Truthcoin/raw/master/docs/5_PM_Manipulation.pdf)




Wall of Shame
-------------------------------------------------

I worked hard to explain my point of view. Here I chronicle the disrespectful attempts to criticize my point of view without even reading it! (Those who **used a question mark or otherwise sought information** were spared).

|   ID     |   Did Not Read |Shame|
|:----------|:---------------------:|:---------:|
|[maaku](https://news.ycombinator.com/item?id=7692848) | Anything|"There seems to be some code here but absolutely no description of what it is doing." |
|[maaku](https://news.ycombinator.com/item?id=7691919)|[Truthcoin_1.1.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/Truthcoin_1.1.pdf) I.a.ii.2.b |"Except that analysis only holds when you assume participants are honest, or there are no derivatives." | 
|[freshhawk](https://news.ycombinator.com/item?id=7691289)|[Truthcoin_1.1.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/Truthcoin_1.1.pdf) I.a.ii.2.b [Truthcoin_1.1.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/Truthcoin_1.1.pdf) II.b|"The defence here is the assumption that the usefulness of the market long term will motivate people to vote "fairly"."|
|[maaku](https://news.ycombinator.com/item?id=7693254)|[1_Purpose.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/1_Purpose.pdf) "What are prediction markets?" [5_PM_Manipulation.pdf](https://github.com/psztorc/Truthcoin/raw/master/docs/5_PM_Manipulation.pdf)|"Sounds a lot like a "synthetic asset" which is constructed from derivatives rather than the other way around. Synthetic assets are very much vulnerable to manipulation by whales."|


Talking without knowing is **lying**. If you don't know something (for example, because you haven't read about it), then **be quiet**. 


FAQ
------------------------------------------
These are all **actual** questions that I received from people via email or forum post. You can either email me or pull request a question here, better to answer them all in one place.

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
https://twitter.com/Truthcoin  
Please share your opinion, and your questions so the FAQ can grow!

#### Donation Address
1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8

### PM-Questions

#### Can't PMs be driven by people who are oblivious to how little they know?
Yes, at first. However, these people will quickly start losing large quantities of money, and thereby lose their ability to influence the market. Moreover, the existence of these ignorant "sheep" will attract "wolves" who profit by correcting the mistakes of the sheep.

#### How do you address the problem of low liquidity?
For PMs which are bounded, it is possible to design them such that traders can always update the market price, by trading with an automated market maker powered by a market scoring rule. http://hanson.gmu.edu/mktscore.pdf
I threw together an Excel sheet in the docs folder [LogMSR_Demo.xlsx](https://github.com/psztorc/Truthcoin/raw/master/docs/LogMSR_Demo.xlsx) for additional clarification. Feedback is appreciated.

####If you built something like this, what use would people get out of it? Most people/organizations aren’t interested in improving their forecast accuracy through PMs. Who would pay to create (let alone subsidize) these markets?
Excellent question. Firstly, Authors (who bear the economic cost of Market-Creation) are rewarded with a slice of transaction volume. Recreational speculation is likely in markets covering sports and politics, arbitrage transactions are likely in markets tracking a price index, and in many cases, individuals will just disagree with each other passionately enough to begin wagering (global warming, gun control, etc.).  

Secondly, the [public might just pay for publically useful information]( http://www.themoneyillusion.com/?p=15446).  

Thirdly, although the information revealed by a PM is public, the effect of that revelation may be privately beneficial. For example, consider [Robin Hanson’s Wish]( http://www.overcomingbias.com/2008/04/if-i-had-a-mill.html), where conditional PMs are introduced to advise firing an incompetent yet entrenched CEO. With 1000 USD per firm to kickstart this idea, we might then collect data on firm/BoD/investor response. However, if we did not have 1000 USD per firm ourselves (we don’t), is there not someone who would benefit from the creation of this information? Of course there is: the second-in-line for CEO! CEOs are typically paid so much that their salary can be twice that of even the CFO. 1000 bucks is nothing for a decent shot at such a nice raise, to say nothing of the competitive spirit which overwhelms those who seek the top job. Even *better*, individuals would not try this if they suspected their CEO of actually being quite competent. So there is actually an economically-efficient self-selection in the creation of these markets: when unneeded, they are not created. Better still, competent CEOs may themselves create these markets to protect their job (although I doubt this type of activity will happen for some time).  

Fourth, individuals could collaborate via assurance contract to efficiently pool their info-demand. In fact, in [my applications paper](https://github.com/psztorc/Truthcoin/raw/master/docs/3_PM_Applications.pdf), I describe a way of using PMs to create extremely incentive-powerful Trustless Dominant Assurance Contracts. To my knowledge nothing similar has ever been conceived.

####If PMs can be used to finance Public Goods, can they also be used to finance Public Bads (for example, to assassinate someone)?
I've thought about this in the past and never considered it to be realistic problem for the following reasons:  

1. Firstly, the branches (which specialize by info-area) can claim in advance that they will vote .5 on anything they find to be violent or immoral, meaning the market fails to resolve into a State, and anyone who paid to list the Decision/Market gets less (probably zero) money. The branch has effectively 'specialized' into 'non-violent markets'.

2. Assuming a crazy branch, the contract needs to specify a time horizon "...killed before 2015". Too long (10 years) and the assassin will go unpaid for an inconvenient amount of time, and too short and the target can bet on surviving and "outlast" the time period, becoming richer. Incidentally anyone on a 'crazy branch' (Owners, Authors, Traders) would almost certainly be tracked by the NSA/FBI/Military and would (and should) be prosecuted for breaking numerous existing laws and disturbing the peace of society.

3. Let’s assume you get a branch working. Consider the schedule (below) in reverse-time (a la Backward Induction), and one can see that there are problems at nearly every stage.


4. I have many more ideas, involving life insurance, buying up the branch (easier than it sounds), counter-exploitation of crazy branch, counter-contracts (paying if you stay alive, or to find/kill the assassin) etc. Many roads lead to failure.

5. If those ideas don't appeal to you, you can simply bet on your own death, then fake your own death. It's inconvenient (and possibly traumatic to friends/family), but you get paid pretty well (money from your enemies, no less) and it beats dying. Modern law enforcement will even help you do this (so I read).

6. All even before we consider the fact that law enforcement has-always/will-continue-to evolve with new technology. Law enforcement would literally know who was most at risk and when. 

7. Finally, I just don't see PMs as encouraging this behaviour, as most murders are for extremely personal reasons (sexual jealousy, religious/political extremism, mental instability) and not economic ones (rich people have way more to lose by going to prison).
    
|Item    |Normally Would Involve   |  Criminal Problems|
|:--------:|:----------------------------------:|:---------------------------:|
|Provider redeems shares for money (gets paid).|Provider distributes money to organization/ partners, as he contracted to do.|Must trust partner to share post-hoc, or do job alone.|
|Voters accurately reproduce reality.|Voters reaching consensus.|Voters may instead coordinate in deciding that market is un-resolvable (for ethical reasons).|
|Provider manipulates reality to create publically-available information about the good (Schelling Indicator, used by Voters).|Something very easy, such as a large poster or official press release. Police don’t care.|Provider must commit a crime (itself difficult and risky), in the precise way of their public trade (whatever the SI was), when the police/victim are now aware of the SI (through the public trade). (Although, one could possibly mitigate this by doing all of them very quickly).|
|Provider places a large trade on a chosen Schelling Indicator.|If the trade is front-run, simply switches to another Indicator. Can switch as many times as desired.|If the trade is front-run, might catastrophically interfere with time-sensitive crime plans. (Could create contingency plans for this).|
|Provider takes out a loan otherwise ties up capital for a huge upcoming trade.|Borrowing at the risk-free rate.| Criminals probably can’t borrow at all (what bank would want anything to do with this, and what lender would trust an anonymous murderer [they’ll just kill you instead of paying you back...]) and have to self-finance (very expensive).|
|Provider assembles team and begins working on good.|Everyone can probably see that someone has started working on this project. Competitors shelve their plans for now.|Might get caught preparing. Criminal (working privately) has no idea if others are working on the same ‘job’, creating risk.|
|Provider examines marketplace, budgets carefully, and decides that it is possible for him to provide a desired public good at acceptable risk/reward.|Costs are stable.|Target may change behavior as a result of market’s creation, including hiring bodyguards, entering witness protection, flee the country, etc.|

Other thoughts: http://www.sirc.org/articles/policy_analysis.shtml

### Incentives
#### How do you know that people wont claim an outcome was whatever will benefit them personally?
1. Voters have a strong incentive to vote "the way they believe others will vote". More deviant individuals are punished more.
2. Voters must vote on many Decisions, many more than they could practically be trading on.
3. Voters must buy reputation tokens, use them to vote regularly, and gain an economic return from them proportional to the usefulness of the network, hence Voters and Traders are likely to be different groups of people. 
4. Even if a substantial majority (>80%) votes unrealistically, as long as these votes are random, there are enough Decisions in a ballot (50 or so), and there is a tightly coordinated core group of identical truth-tellers, this 80% coalition will not affect PM Outcomes **at all**, and instead only lose their reputation-tokens. Liars must form a tightly coordinated coalition.
5. Voters have an incentive to trick other voters into voting unrealistically (regardless of the proportion voting realistically). Thus, a tightly coordinated coalition cannot form.
6. Voters face a penalty for not voting, which is high when the proportion of missing votes is high (a few missed votes won't hurt you, but in a low-turnout environment you will be penalized more severely). Thus voters must always vote.

Votes cross-validate other votes, in addition to suppling the data used for Outcome-calculation.

####Why don't you...?

The idea I published was not my **first** idea for a Trustless PM, it was my **best**. I probably *did* think of whatever you have in mind, but feel free to ask anyway (if you'd like to know why I didn't select it).

Prompts:

1. ...have a single Judge collect fees for his Judging services? Good judges would gain a good reputation, and charge more for their services. Bad judges would lose the stream of future income payments. We could even force Judges to put up collateral so that they would have more to lose.
2. ...have a few 'trusted feeds', where the outcome is determined as the median feed, or outcome is a draw if feeds disagree too much?
3. ...publish a hash of every event description combined with the outcome "true" or "false" and sign the real outcome? Thus we can build up reputations and predictions can be placed completely independent.
4. ...store bets in a 2 out of 3 multi sign address? That would make it impossible for the central PM to run away with the money - just to choose the winning side.
5. ...have both sides put 10% more money in a multi-sign address? No the person that loses the bet can admit the loss and sign the transaction to the winner but he gets back the 10%. If none of both admits to be the looser we sign a transaction to the winner but take the 10% of the looser.
6. ...have a preselected Judge decide, but allowing users to force an audit of the Judge if they disagree with his ruling?

Responses:

1. Obviously, the Attack Profit here is defined by 3 inputs: the cash influx for attacking today (call this "Defect"), the stream of payments in the future for honest judges (call this "Conform"), and the discount rate used to reconcile the fact that these payments are taking place at different times (call this “r”). There are severe problems with all 3 inputs: ‘Defect’ can skyrocket unexpectedly as a market becomes popular, ‘Conform’ can collapse on news about the future of the protocol or judge-industry-competitiveness, and r will change with the Judge’s preferences (if a Judge wants to retire and leave the Judging industry, r can become infinite). This uncertainty means that it is practically impossible to guarantee today that a given Decision will have negative Attack Profit (ie, not be attacked) at the time of Judgement.
2. The first problem with this is that there is little to truly prevent the feed operators from colluding to lie (which is unacceptable). By buying cheap shares and reporting falsely, feed operators can reap substantial profit (InTrade's Barack Obama market expired with 20 million USD volume). If feeds are anonymous this attack is easier to finish, if they are non-anonymous this attack is easier to start. With a low number of feed operators, that have brands/customer-support-contact info, a clear reason to work together, and a clear payoff, they will either collude, or create chaos by falsely accusing each other of attempting-to-collude. Secondly, non-cross-validated/centralized sources are fragile, and can be corrupted, hacked, closed by authorities, etc. Thirdly, this attack does not allow the feed operators to 'retire' and choose to do something else. In Truthcoin, one wants to keep one's reputation-tokens as "clean" as possible, so that one can eventually sell them, but with systems like these, there is no safe way to cash out, so one profits by making one's last report a lie, and lying about when one plans to make a 'last report'. Fourth, it is complex to choose a method for determining the feed-sources and deciding what to do if they break or start lying, in a way that cannot itself be gamed (ie with me falsely saying that you are a bad feed operator and you should be ignored).
3. This requires trust and provides no method for cashing-out that trust. Again, a 20 million payday today for one lie is very persuasive, against an uncertain future stream of small fee payments. This strategy is already used by the service [Reality Keys](https://www.realitykeys.com/), and may be effective in a low-cost environment where many specific contracts are needed.
4. Same problem, attacker simply trades on the losing side before lying. This is unblockable, and attempts to block it will let clever traders 'fake out' rivals by buying up losing shares last minute to tinker against the countermeasure.
5. Although I was working with this idea for awhile, its not as good as one might think, because in Nash Equilibrium you still need an incorruptible way of determining outcomes (for the holdouts [even if it were never be used on-path, the game theory requires that the off-path reasoning be persuasive]). Furthermore, one holdout can cause you to have to research the issue, and once you've done that, it costs nothing to re-use that research for all other traders in that market. So a losing trader can easily force the administrator to research his claim, if the administrator is not prepared for the possibility that he will be required to research ALL claims, than this can be gamed strategically by buying a small amount of every losing claim.
6. This is another idea I considered, but there's a strange paradox where the Judge and the Auditor don't really gain reputations (which, again, they can't sell) at the same time: either Judges are lying (and Auditors are proving their worth), or the Auditors are never needed (and hence their reliability cannot be assessed). Who decides who becomes a Judge and Auditor, and who Judges/Audits what (to avoid the obvious problem of Judges being their own Auditors? Who bears the economic costs of establishing these selections? In a software environment these selections and associations will be strongly anonymous, individuals may have several accounts. If auditors are to be assigned randomly, what will be the source of randomness? Why are Auditors superior to Judges? Again, all parties involved may *still* be able to collude (if they are lucky enough to be paired). Moreover, if miscreants force needless Audits, it just delays everyone for no reason. Mandatory fees for auditing could prevent this, but could also weaken confidence. My proposal assumes that all Judges and Auditors would lie, and that they therefore *must* audit each other always. This pessimism results from the incentive to lie today (which is **very** strong).

Comments:  
 
Generally, many ideas ignore...
 
1. ...**uncertainty**. If you can't guarantee the mechanism will *always* work, people will respond strategically to this, and avoid using it. Eventually, fate will drift everything into its weakest point, if that point is weak the idea will break.
2. ...the **Chicken and Egg Scale Problem**, that there's no way to know if something is secure until people begin trusting it with large amounts of money. This makes all empirical assumptions about the project (51% honest, presence/effects of competition) permanently uncheckable, and disqualifies projects with many assumptions or even one potentially-untrue assumption. As a project grows, it may be attacked in extremely expensive ways. If it would not survive such attacks, it will never grow to that size.
2. ...**differences between brands/individuals and digital identities**. In the real world, you can lose *more* than you've established: you can be sued, shamed, thrown in prison, or (traditionally) whacked. Online, you have little to lose.
3. ...the **Retirement Attack**, ie they tell Judges that the most profitable way to retire is by attacking on their last turn (can't be sued/killed, see above). 
4. ...how **easy it is to collude**. If Judges think the mechanism is going to fail soon, they're actually much more likely to betray it. They could think this for any reason, including irrational panic, Keynesian-beauty-contest-panic, or induced-reasons such as "some guy says he's got 5 Judges and will kill their families unless they vote X". This implies Early Retirement and #3.
5. ... **profit-equilibrium**. If Judging is a profitable industry, more Judges will join, increasing competitiveness and decreasing profits. This implies Early Retirement.
6. ...**the opportunity cost of the attack**, ie that one could potentially make $100 million dollars just by moving a switch here rather than there. You intend to discourage this how, exactly?
7. ...the **Double Mechanism Reputation Problem**, that proposing two ideas at once (such as a Judge being checked by an Auditor) necessarily means that one idea will go completely unused, making it irrelevant. This is fine strategically ("off-path reasoning"), but not economically (how do you pay Auditors who are never used? What if 10 million people sign up to be auditors?).
8. ...**Sybil attacks**, ie that one person can be pretending (even from the very beginning, or from a long period of time) to be several people.

I did not base my own choice on trial-and-error, I instead based it on my day-to-day real-world truth-finding experiences.

####In practice everyone [may] pull their data from some kind of external data feed. Presumably they'll use whatever is simplest and cheapest, then they'll be stuck with that until it completely breaks...
This concern has only been voiced for scaled claims, not binaries (which probably are novel and don't have a feed). If Voters are instructed to use a few external sources (for comparison),Do they can double-check their answers (of course, if they believe others will NOT double-check, they will not either, so they might not), or more importantly switch to a new source if the first is broken. I personally find it highly unlikely that Yahoo or Google will start publishing wildly disparate financial index data, as they have every reason to ensure that the data is accurate.

####It sounds a lot like you've reinvented...
So far, people have written in 'Bayesian Truth Serum', ["Thirteen theorems in search of the truth."](http://www.socsci.uci.edu/~bgrofman/69%20Grofman-Owen-Feld-13%20theorems%20in%20search%20of%20truth.pdf), [EigenTrust](http://en.wikipedia.org/wiki/EigenTrust), and a few other things (that weren't quite right).

I probably did. I don't think any of my core building-block ideas are that complicated, especially compared to the library of academic work published each year since forever. BTS allows you to vote on how other's will lie, this is a little better but doesn't scale as easily (an furthermore in a coordination game all the votes would theoretically be equal to each other).

####Do you feel its necessary to penalize miners for not voting? In my mind it would be better to rely on positive rewards as we wouldn’t really want to encourage voting by those with less interest/knowledge in the outcomes.

Actually it is necessary. Firstly the concern you mentioned later is mitigated by (and one of the main benefits of) Branching, where voters stay only on the branches/trees where they are interested and knowledgeable. More importantly, however, if we assume voting is costly (which it certainly is), then the assumption I made on page 2 that voters are lazy implies that theoretically none of them will vote, in a sort of 'tragedy of the commons'. Realistically, some might care enough to vote, but this would weaken the confidence in the coordination-ballot, as it takes a smaller % of votes to throw off. Thirdly, voters are not just contributing their point of view when they vote, they are also securing the network by validating the point of view of all other voters (via the coordination game). Notice that an individual's penalty for not-voting is only high when many other individuals have also not-voted. You can miss a vote every once in a while, and as long as everyone else is voting it won't really be a big deal for you.

####Do strategic decisions change if one node started publishing (potentially biased) votes immediately upon noticing them? One could publish 10% attack-votes, and the 11th % user would be tempted to conform, leading to a cascading failure.
Excellent question. Ballots are encrypted, and contain a new destination (public key), for this reason. Votes are cast in one period, and unsealed in a later period (during which no new votes are cast). Because private keys are required to decrypt, it is always impossible to prove that you've voted a certain way (and recall that you have an incentive to vote honestly yet say that you are voting dishonestly).

####In some of your notes you suggested timelines of a couple of weeks for voting. Would it be fair to say this wouldn't be suitable to horse racing etc. where the events happen very fast, there are many of them and payouts need to be made fairly quickly?
The price will not fix at 1 or 0 until voting occurs, but it will converge toward one of those values as the event info is revealed (ie just as the horse wins). If voting is in two weeks, there may be some time-value-of-money/time-preference/liquidity effect, but shares of the winning horse could still sell for 99.0 or 99.9. Those buying at 99 would be Wall Street / banker types who pick up the shares purely to earn 2 week's worth of above-market interest on their capital. So fast cashouts shouldn't be a problem.

####Is SVD computationally complex, to continue doing on such a large scale and frequency?
That depends on your definition of complex. In python, on an i5 processor, svd solves instantly for a matrix of dimensions 10000 x 100 (my expectation for the steady-state requirement). It is a common misconception that svd is preformed frequently in my scheme. It is only performed once per month (per Judgment Period), upon the maturation of large batches of Decisions.

####Why don’t you perform judgment more often?
1. For security reasons we need a group of a few Decisions per Judgment Period.
2. Judgment is inconvenient, and we would like to minimize inconvenience. Because of setup costs, it is likely easier for judges to sit down once per month, at their leisure, and do all Decisions at that time, than it would be to force them to do this every week or every day. Monthly JPs allow for a two week vacation, for example.
3. There’s really no benefit to doing so (see the horse racing question above).


### Other

####Mining / Coin Distribution ?

Any game-theorist worth his salt knows Pareto/Kaldor-Hicks improvements. Cryptocurrencies have the **beautiful** ability to preserve ownership by taking snapshots of the unspent-outputs set. I see no good reason not to do this for the currency-tokens, just as I see no good reason not to use Bitcoin’s proof-of-work mining scheme. I’ve never seen a proof-of-stake proposal that achieved Kaldor-Hicks, and in fact my guess is that is it this challenge (KH) that primarily motivated Satoshi to choose his mining scheme (which is Pareto).
The reputation-tokens are more complex, but the obvious choice is to distribute them to individuals proportional to what they sacrificed to create the software.


####Have you seen a similar effort from some CS guys at princeton? Wonder if they're solving the same problems...
I had previously heard about the [Princeton guys](http://dailyprincetonian.com/news/2014/01/u-researchers-develop-bitcoin-prediction-market/) but I never heard any news from them and had forgotten about it. Would be great to collaborate, but I had already finished most of my ideas when I found that article. To date I have heard nothing from them about their project. As always: Nullius in Verba.  
Update: The long awaited [paper](http://users.encs.concordia.ca/~clark/papers/2014_weis.pdf) did actually come out. Unfortunately, we seem to disagree on the true nature of the problem of designing a decentralized prediction market. Namely, in Section 5.3 the paper assumes Prompt 1 above (in “Why don’t you…”), which I view as unacceptable (see above). The paper does mention two ideas, ‘PredCo’ (which solves the discount rate problem), and the Keynesian Beauty Contest, which, when combined, more closely resemble what I had in mind. The second major proposal in the paper is for an order book system. Instead, I chose to use market scoring rules, for a variety of reasons, one of which is that operating a MSR is extraordinarily similar to sending a normal Bitcoin transaction. The paper is not truly a proposal for anything, instead a sort of menu of different ideas and avenues for decentralizing prediction markets. A novel is easier to assess than a dictionary, so it difficult for me to critique the paper more directly than this.






