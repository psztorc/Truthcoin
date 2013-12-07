#Trading Protocol and Market Maker


#MarketPlace
Markets <- vector("list",length=0)

Users <- vector("list",length=0)
Users$Alice$Cash <- 200
Users$Bob$Cash <- 50
Users$Charlie$Cash <- 100




# #Change this to an array
# array(2,2,2,2)  ## results in unused argument error
# 
# I think you want a 4D array
# 
# U <- array(0, dim = c(2,2,2,2))
# 
# and then to assign to a 2D portion use R's ?Extract syntax
# 
# U[1,1,,] <- cbind(c(0.7,0.3),c(0.3,0.7))



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

Users$Alice$Owns <- Markets
Users$Bob$Owns <- Markets
Users$Charlie$Owns <- Markets

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
  return(Sstar)
}

QueryMove("Obama",1,.6)
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
  return( QueryCost(ID,State, QueryMove(ID,State,P) ) )
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
  Shares <- QueryMove(ID,State,P)
  
  #Reduce Funds, add Shares
  
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost
  Users[[uID]]$Owns[[ID]]$Shares[State] <<- Users[[uID]]$Owns[[ID]]$Shares[State] + Shares
  
  #Credit Funds, add Shares
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + Shares  
}

Buy("Alice","Obama",1,.6)
ShowPrices("Obama")
Users$Alice$Cash
Users$Alice$Owns

Buy("Alice","Hillary",2,.35)
ShowPrices("Hillary")
Buy("Bob","Hillary",3,.60)
ShowPrices("Hillary")

Users$Alice$Owns
Users$Bob$Owns


