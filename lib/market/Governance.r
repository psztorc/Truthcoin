#Governance - 'Branch as Colored Coin' Version
rm(list=ls())
#Function Library
tryCatch(expr=setwd("~/GitHub/Truthcoin/lib"), error=function(e) setwd(choose.dir(caption="Failed to set working directory automatically. Choose 'lib' folder:")) )
source(file="market/Markets.r")
source(file="consensus/ConsensusMechanism.r")
Sha256 <- function(x) digest(unlist(x),algo='sha256',serialize=FALSE)

GenesisBlock <- list(
  
  # Block Ordering Stuff
  "Bn"=1,               # Block Number
  "h.B.1"=Sha256(""),   # Hash of previous block
  "Time"=Sys.time(),    # System Date and Time 
  "Nonce"=1,
   
  
  "Branches"=Branches,  # Branch Data (List) 
  "Markets"=Markets,    # Market Data (List)
  
  "Funds"=data.frame("id"=c("A","B","C"),
                     "value"=c(30, 999, 2))   # Cash

  )



BlockChain <- list(NA,GenesisBlock)
# Setup Complete


# Problem: Current functions optimized for testing/collaborate-knowledge.
# Getting more specific would tangle these functions into blockchain-specific data structures, and integrate the moving parts.
# This would make understanding (even running) the code much more difficult.
# Therefore, I think it is time to stop the reference implementation. The remaining design specification, ValidateBlock(), is below.
# Please email me at truthcoin@gmail.com or visit the Development section of our forum ( forum.truthcoin.info ) for help from this point.


### - ValidateBlock - ###

## Chain Integrity
# contains hash of previous block
# hash is below target

## Branch Integrity
# branches added correctly
# existing branches are paying fees
# is it time for Voting? if so, freeze Reputation-Currency, build VoteMatrix and ask for encrypted votes
# is it time for Unsealing? if so, freeze VoteMatrix and ask for unseals
# is it time for SVD? if so, run Factory()

## Decisions Integrity
# Decisions added correctly
# Did SVD resolve any decisions last period? if so update 'Decisions'

## Market Integrity
# Did a Market's Decisions SVD-resolve? if so GetFinalPrices( Market )

## Transactions
# are all transactions valid
# (reminder: reputation cannot be moved during vote-periods)