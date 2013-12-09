#Trading Protocol and Market Maker


#MarketPlace
Markets <- vector("list",length=0)

Users <- vector("list",length=0)
Users$Alice$Cash <- 10
Users$Bob$Cash <- 50


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
  return( QueryCost(ID,State, NewS ) )
}

Buy <- function(uID,ID,State,P) {
  #Calculate Required Cost
  Cost <- QueryMoveCost(ID,State,P)
  MarginalShares <- QueryMove(ID,State,P)
  if(MarginalShares<0) return("Price already exceeds target. Sell shares or buy MuEx.")
  
  #Reduce Funds, add Shares
  if(Users[[uID]]$Cash<Cost) return("Insufficient Funds")
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost 
  OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]] ; if(is.null(OldShares)) OldShares <- 0
  Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares
    
  #Credit Funds, add Shares
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares  
  
  print(paste("Bought",MarginalShares,"for",Cost,"."))
}

Sell <- function(uID,ID,State,P) {
  #Calculate Required Cost
  Cost <- QueryMoveCost(ID,State,P)
  print(Cost)
  MarginalShares <- QueryMove(ID,State,P)
  print(MarginalShares)
  if(MarginalShares>0) return("Price already below target. Buy shares or sell MuEx.")
  
  #Reduce shares, add Funds
  OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]]
  print(OldShares)
  if(OldShares<(-1*MarginalShares)) return("Insufficient Shares")
  Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares #Shares are negative
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost #Cost is negative
  
  #Remove Funds and Shares from Market
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost  
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares 
  print(paste("Sold",-1*MarginalShares,"for",-1*Cost,"."))
}

#Tests
DisplayTest <- function() {
  print(Users$Alice)
  print(ShowPrices("Obama"))
  print(Markets$Obama$Shares)
}

DisplayTest()

Buy("Alice","Obama",1,.6)
DisplayTest()

Buy("Alice","Obama",1,.7)
DisplayTest()

Sell("Alice","Obama",1,.6)
DisplayTest()

Sell("Alice","Obama",1,.5)
DisplayTest()

Sell("Alice","Obama",1,.4)
DisplayTest()

Sell("Alice","Obama",1,.4)
DisplayTest()

Buy("Alice","Obama",1,0.9000)
DisplayTest()
Buy("Alice","Obama",1,0.9900)
DisplayTest()
Buy("Alice","Obama",1,0.9990)
DisplayTest()
Buy("Alice","Obama",1,0.9999)
DisplayTest()
Buy("Alice","Obama",1,0.99999)
DisplayTest()



