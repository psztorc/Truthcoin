#Trading Protocol and Market Maker


#Create Marketplace
Markets <- vector("list",length=0)

CreateMarket <- function(ID=1,Nstates=2,B=1) {
  #Add a new contract to the global 'Markets' variable.
  Markets[[ID]] <<- list(
    "Shares"=rep(0,length=Nstates),
    "Balance"=B*log(Nstates),
    "B"=B,
    "State"=0)
}


ShowPrices <- function(ID) {
  #Takes a Market and ID and returns the current market price.
  S <- exp(Markets[[ID]]$Shares/Markets[[ID]]$B)
  return(S/sum(S))
}


QueryMove <- function(ID,State,P) {
  #How many shares would I need to buy of'ID'-'State' to move the probability to 'P'?
  S <- exp(Markets[[ID]]$Shares/Markets[[ID]]$B)
  Sstar <- Markets[[ID]]$B* ( log(P/(1-P)) + log(sum(S[-State])) )
  Marginal <- Sstar -Markets[[ID]]$Shares[State]
  return(Marginal)
}


QueryCost <- function(ID,State,S) {
  #What price will the market-maker demand for a purchase of S shares?  
  B <- Markets[[ID]]$B
  
  #Original Case
  S0 <- Markets[[ID]]$Shares
  LMSR <- B*log(sum(exp(S0/B)))
  
  #Proposed Adjustment
  S1 <- S0;  S1[State] <- S1[State] + S
  LMSR2 <- B*log(sum(exp(S1/B)))
  
  return( LMSR2-LMSR )
}


QueryMoveCost <- function(ID,State,P) {
  #How much would it cost to set the probability to P?
  NewS <- QueryMove(ID,State,P) 
  return( QueryCost(ID,State, NewS ) )
}

Buy <- function(uID,ID,State,P) {
  #Calculate Required Cost
  Cost <- QueryMoveCost(ID,State,P)
  MarginalShares <- QueryMove(ID,State,P)
  if(MarginalShares<0) return("Price already exceeds target. Sell shares or buy a Mutually Exclusive State (MES).")
  
  #Reduce Funds, add Shares
  if(Users[[uID]]$Cash<Cost) return("Insufficient Funds")
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost 
  OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]] ; if(is.null(OldShares)) OldShares <- 0
  Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares
    
  #Credit Funds, add Shares
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares  
  
  print(paste("Bought",MarginalShares,"for",Cost,"."))
  return(c(MarginalShares,Cost))
}

Sell <- function(uID,ID,State,P) {
  #Calculate Required Cost
  Cost <- QueryMoveCost(ID,State,P)
  MarginalShares <- QueryMove(ID,State,P)
  if(MarginalShares>0) return("Price already below target. Buy shares or sell a Mutually Exclusive State (MES).")
  
  #Reduce shares, add Funds
  OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]]
  if(OldShares<(-1*MarginalShares)) return("Insufficient Shares") #Remember, shares are negative.
  Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares 
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost #Cost is also negative
  
  #Remove Funds and Shares from Market
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost  
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares 
  
  print(paste("Sold",-1*MarginalShares,"for",-1*Cost,"."))
  return(c(MarginalShares,Cost))
}

FinalSell <- function(uID,ID,State,ContractState,S) {
  #This function takes over after the event's state has been determined, and all shares are either worth zero or the unit price.
  ContractState <- ContractState
  #ContractState <- GetContractState() #unwritten function to determine State...probably will just lookup from Cmatrix.
  #!!! Obviously, some check will need to be made.
  
  #Which shares are valuable?
  if(State!=ContractState) return("Shares of this state have value 0.") 
  OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]]
  
  MarginalShares <- S*-1 #Users are expected to enter +3 if they wish to sell 3 shares, ie marginally change shares by -3.
  Cost <- MarginalShares # All shares have value 1, so this identiy holds.
    
  #Reduce shares, add Funds
  Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares #MarginalShares are negative
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost #Cost is negative
  
  #Remove Funds and Shares from Market
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost  
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares 
  
  print(paste("FinalSold",-1*MarginalShares,"for",-1*Cost,"."))
  return(c(MarginalShares,Cost))
}  
