#Trading Protocol and Market Maker


#MarketPlace
Markets <- vector("list",length=0)

Users <- vector("list",length=0)
Users$Alice$Cash <- 10
Users$Bob$Cash <- 50
Users$Charlie$Cash <- 78


#New Contract
CreateMarket <- function(ID=1,Nstates=2,B=1) {
  Markets[[ID]] <<- list(
    "Shares"=rep(0,length=Nstates),
    "Balance"=B*log(Nstates),
    "B"=B,
    "State"=0)
}

Markets

CreateMarket("Obama",2,B=1)
CreateMarket("Hillary",4,B=3.5)


Markets
Markets$Obama$Price

ShowPrices <- function(ID) {
  S <- exp(Markets[[ID]]$Shares/Markets[[ID]]$B)
  return(S/sum(S))
}

ShowPrices("Obama")
ShowPrices("Hillary")

QueryMove <- function(ID,State,P) {
  #How many shares would I need to buy to move the probability to X
  S <- exp(Markets[[ID]]$Shares/Markets[[ID]]$B)
  Sstar <- Markets[[ID]]$B* ( log(P/(1-P)) + log(sum(S[-State])) )
  Marginal <- Sstar -Markets[[ID]]$Shares[State]
  return(Marginal)
}

QueryMove("Obama",1,.6)
QueryMove("Obama",2,.4)
QueryMove("Hillary",3,.35)

QueryCost <- function(ID,State,S) {
  #Original Case
  S0 <- Markets[[ID]]$Shares
  B <- Markets[[ID]]$B
  LMSR <- B*log(sum(exp(S0/B)))
  
  #Proposed Adjustment
  S1 <- S0
  S1[State] <- S1[State] + S
  LMSR2 <- B*log(sum(exp(S1/B)))
  
  return( LMSR2-LMSR )
}

QueryCost("Obama",2,1)
QueryCost("Hillary",1,1)

QueryMoveCost <- function(ID,State,P) {
  NewS <- QueryMove(ID,State,P)
  if(NewS<0) return("Price already exceeds target. Sell shares or buy MuEx.")
  return( QueryCost(ID,State, NewS ) )
}

QueryMoveCost("Obama",1,.5)
QueryMoveCost("Obama",1,.6)
QueryMoveCost("Obama",1,.7)
QueryMoveCost("Obama",1,.90)
QueryMoveCost("Obama",1,.99)

QueryMoveCost("Hillary",1,.25)
QueryMoveCost("Hillary",1,.35)
QueryMoveCost("Hillary",1,.45)
QueryMoveCost("Hillary",1,.90)
QueryMoveCost("Hillary",1,.99)


Buy <- function(uID,ID,State,P) {
  #Calculate Required Cost
  Cost <- QueryMoveCost(ID,State,P)
  MarginalShares <- QueryMove(ID,State,P)
  if(is.character(MarginalShares)) return(MarginalShares)
  
  #Reduce Funds, add Shares
  if(Users[[uID]]$Cash<Cost) return("Insufficient Funds")
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost 
  OldShares <- Users[[uID]][[ID]][[State]] ; if(is.null(OldShares)) OldShares <- 0
  Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares
    
  #Credit Funds, add Shares
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares  
}

Sell <- function(uID,ID,State,P) {
  #Calculate Required Cost
  Cost <- QueryMoveCost(ID,State,P)
  MarginalShares <- QueryMove(ID,State,P)
  if(is.character(MarginalShares)) return(MarginalShares)
  
  #Reduce shares, add Funds
  OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]]
  if(OldShares<MarginalShares) return("Insufficient Shares")
  Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares - MarginalShares
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash + Cost
  
  #Remove Funds and Shares from Market
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance - Cost 
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] - MarginalShares 
}


Users
Buy("Alice","Obama",1,.6)
Users
Buy("Bob","Obama",1,.7)
Users


Sell("Alice","Obama",1,.55)

# 
# Buy("Alice","Hillary",2,.35)
# ShowPrices("Hillary")
# Buy("Bob","Hillary",3,.60)
# ShowPrices("Hillary")
# 
# Users$Alice
# Users$Bob




