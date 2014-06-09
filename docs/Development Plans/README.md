
<h2>Helpful Forum Posts</h2>

[Timeline comments](http://forum.truthcoin.info/index.php/topic,14.msg103.html#msg103)

<h2>Block Validation Requirements</h2>
<h3>Data Sets</h3>

<h4>F Set</h4>
**(Owner: 160-bit address, Cash: 64-bit integer)**  
Stores everyone's funds (Bitcoin).
<h4>R Set</h4>
**(Owner: 160-bit address, Cash: 64-bit integer)**  
Stores everyone's reputation. This reputation can be sent P2P, so this is similar to Bitcoin’s UTXO.
<h4>D Set</h4>
**(Author: 160-bit address, ID: 160-bit Hash, Description: X-bit Text Statement, Outcome: 8-bit Value, Maturity Date: 64-bit integer)**  
Stores the Yes/No building blocks of markets.
<h4>M Set</h4>
**(Author: 160-bit address, ID: 160-bit Hash, Balance (Cash): 64-bit integer, Fee Balance (Cash): 64-bit integer, State: 8-bit Value, Beta: 16-bit integer, Tag1..4: X-bit Text Statement, Title: X-bit Text Statement, Description: X-bit Text Statement, Structure: Structured array-dimensions built from D-ID's (typically just one Decision), Shares: Array of 64-bit integers whose dimentionality is specified by M-Structure (typically just 1 dimention of 2 states))**  
Stores the markets themselves during the trading period.
<h4>V Set</h4>
**(Matrix of 4-bit values with dimension Voters by Decisions)**  
The matrix which stores this period's votes.
<h4>P Set</h4>
**(Fee: 64-bit integer, Participation: 16-bit integer, Catch: 16-bit integer, Smooth: 16-bit integer, MaxRows: 16-bit integer)**
Some parameters to keep track of.


<h3>TX Types</h3>

Note that drafts of these functions are in lib and pylib. 

<h4>TransferReputation(New Owner, Value)</h4>
Just like a Bitcoin transaction.

<h4>AuthorDecision(Text, Fee, Time to Maturity, Sponsor Address)</h4>
Creates a new decision.

<h4>AuthorMarket(Title, Tags, Decisions, Structure, b, Payment, Sponsor Address)</h4>
Creates a new Market for traders to trade in.


<h4>Buy(Fund Source, Market ID, State, P)</h4>
Purchases shares of a chosen State of a chosen Market with a chosen Funding Source. P ("target price") can instead be amount, or shares or something else, it doesn't matter.

<h4>Sell(Fund Destination, Market ID, State, P)</h4>
Sells shares of a chosen State of a chosen Market, depositing funds to a chosen Funding Source. P ("target price") can instead be amount, or shares or something else, it doesn't matter.

<h4>Redeem(Fund Destination, Market ID, State, S)</h4>
This function takes over for 'sell' after the event's outcome has been determined, and all shares are either worth zero or the unit price. Sells shares of a chosen State of a chosen Market, depositing funds to a chosen Funding Source.
P ("price")  will equal S ("shares") at this time (or be zero).

<h4>CastBallot(Account, Signed and Encrypted Ballot, New Owner)</h4>
Submits a ballot (containing this period's votes), and simultaneously transfers ownership to a new key (upon ballot unseal).

<h4>WithdrawFunds(BtcAddress, Value)</h4>
Exactly how this works depends on if/how side chains are implemented. Best to work on this very last  

*For convenience / Optional*

<h4>QueryAuthorDecision(Text, Time to Maturity)</h4>
"How much would it cost me to add this decision?"

<h4>QueryAuthorMarket(Title, Tags, Decisions, Structure, b)</h4>
"How much would it cost me to add this market?"

<h4>QueryMove(Market ID, State, P)</h4>
"How many shares would I need to buy of'ID'-'State' to move the probability to 'P'?"

<h4>QueryCost(Market ID, State, S)</h4>
"What would the market-maker demand for a user-purchase of S shares?"

<h4>QueryMoveCost(Market ID, State, P)</h4>
"How much would it cost to set the probability to P?"



    

