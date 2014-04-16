<h2>Technical Differences from Bitcoin </h2>
<h3>Data Sets</h3>

<h4>F</h4>
**(Owner: 160-bit address, Cash: 64-bit integer)**  
Stores everyone's funds (Bitcoin).
<h4>R</h4>
**(Owner: 160-bit address, Cash: 64-bit integer)**  
Stores everyone's reputation. This reputation can be sent P2P, so this is similar to Bitcoin’s UTXO.
<h4>D</h4>
**(Author: 160-bit address, ID: 160-bit Hash, Description: X-bit Text Statement, Outcome: 8-bit Value, Maturity Date: 64-bit integer)**  
Stores the Yes/No building blocks of markets.
<h4>M</h4>
**(Author: 160-bit address, ID: 160-bit Hash, Balance (Cash): 64-bit integer, Fee Balance (Cash): 64-bit integer, State: 8-bit Value, Beta: 16-bit integer, Tag1..4: X-bit Text Statement, Title: X-bit Text Statement, Description: X-bit Text Statement, Structure: Structured array-dimensions built from D-ID's (typically just one Decision), Shares: Array of 64-bit integers whose dimentionality is specified by M-Structure (typically just 1 dimention of 2 states))**  
Stores the markets themselves during the trading period.
<h4>V</h4>
**(Matrix of 4-bit values with dimension Voters by Decisions)**  
The matrix which stores this period's votes.
<h4>P</h4>
**(Fee: 64-bit integer, Participation: 16-bit integer, Catch: 16-bit integer, Smooth: 16-bit integer, MaxRows: 16-bit integer)**
Some parameters to keep track of.


<h3>TX Types</h3>

<h4>TransferReputation</h4>
**(New Owner, Value)**  
Just like a Bitcoin transaction.

<h4>AuthorDecision</h4>
**(Text, Fee, Time to Maturity, Sponsor Address)**  
Creates a new decision.

<h4>AuthorMarket</h4>
**(Decisions, Tags, Structure, b, Payment, Sponsor Address)**  
Creates a new Market for traders to trade in.

<h4>Vote</h4>
**(Account, Signed and Encrypted Ballot, New Owner)**  
Submits a ballot, and simultaneously transfers 



Buy, Sell, FinalSell To-be-completed

