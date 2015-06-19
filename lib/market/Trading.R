# Trading Protocol and Market Maker
# Paul Sztorc
# Written in R (v 3.1.1) using Rstudio (v 0.98.1028)

# A collection of relatively basic functions.


tryCatch(expr=setwd("~/GitHub/Truthcoin/lib"), error=function(e) setwd(choose.dir(caption="Failed to set working directory automatically. Choose 'lib' folder:")) )
source(file="market/Markets.r")

# The following functions have little meaning in markets that have no trading activity (ie, shares always zero, prices always uniform)
# Therefore, examples are not provided here, instead, see TradingTests.Rmd



## Simple Market Info ##
ShowPrices <- function(ID, LS=TRUE, Standardized=FALSE) {
  # Takes a Market and ID and returns the current market price.
  

  # Accepts two types of argument: The Market ID (and all associated information) or just the shares.
  if( class(ID)=="character" ) {
    M <- Markets[[ID]]
    LS <- !!( M$MaxCommission )  # Returns FALSE iff MaxCommission == 0. At zero, liquidity sensitivity is off, implying LS=FALSE.
  }
  
  if( class(ID)=="array" ) Shares <- ID
  # If ID is of class "array", we won't know the LS status. It must be provided to us.
  
  # Traditional prices with a fixed Beta
  if( !LS ) {
    B  <- M$B
    S <- exp(M$Shares/B)
    Prices <- S/sum(S)
    
    # Much easier...
    return( Prices )
  }
  
  # Liquidity-Sensitive Parameters
  
  if( class(ID)!="array" ) Shares <- M$Shares
  
  N <- length( Shares )
  Alpha <- MaxCommission / ( N * log(N) )
  B <- Alpha*sum( Shares )
  
  SH <- Shares
  ES <- exp(Shares/B)
  
  # Return "normal" prices which sum to zero (using the existing Beta)  
  if( Standardized ) {
    Prices <- ES / sum(ES)
    return( Prices )
  }

  # Finally: the more complicated LS-prices
  Prices <- Alpha*log(sum(ES))  + (( sum(SH)* ES) - sum(SH*ES) ) / ( sum(SH) * sum(ES) )
  return(Prices)
  
}


QueryMoveLS <- function(Shares, State, P) {
  # How many shares would I need to buy of'ID'-'State' to move the probability to 'P'?
  # The LS-version is much more complicated, and defined first
  
  N <- length( Shares )
  Alpha <- MaxCommission / ( N * log(N) )
  
  # Rescale   
  S <- Shares
  rS <- S/sum(S) * 1/Alpha # An unbelievable amount of math is easier if one assumes (without loss) that sum(shares) = 1/Alpha
  

  eS <- exp( rS )
  SeS <- rS * eS 
  
  # Calculate the share-vector which would produce price P
  Sstar <- log(  sum(eS)*(P-( Alpha*log(sum(eS)) )) + Alpha*sum(SeS)  )
  

  # Adjust rS
  NewRS <- rS                                                              # Copy
  NewRS[ State] <- Sstar                                                   # Impose target S
#  NewRS[-State] <- rS[-State] * ( ( (1/Alpha)-Sstar )  / sum(rS[-State]) ) # Total must sum to 1/Alpha
  NewRS[ State] <- Sstar
  
  # if( 1/Alpha == sum(NewRS) ) print("Alpha normal.")
  
  # Rescale    - old shares must add up to their previous values. 
  Buying <- TRUE
  if( ShowPrices(Shares, LS=TRUE)[State] > P ) Buying <- FALSE
    
  if( Buying) Congruance <- min(S) / min(NewRS)
  if(!Buying) Congruance <- max(S) / max(NewRS)
  
  NewShares <- NewRS * Congruance
  
  return(NewShares)

}

QueryMove <- function(ID, State, P, Iterations=125) {
  # How many shares would I need to buy of'ID'-'State' to move the probability to 'P'?
  
  M <- Markets[[ID]]
  
  # Is market liquidity-sensitive?
  LS <- !!( M$MaxCommission )  # Returns FALSE iff MaxCommission == 0. At zero, liquidity sensitivity is off, implying LS=FALSE.
  
  if( LS) {   
    # Way more complicated than non-LS
    # I could not crack the simultaneous solutions for 
    
    Shares <- M$Shares
    for(i in 1:Iterations) Shares <- QueryMoveLS(Shares, State, P)
    
    Marginal <- Shares[State] - M$Shares[State]
    
    return( Marginal ) 
  }
    
  
  if(!LS) {
    B <- M$B
    
    S <- exp( M$Shares / B )
    Sstar <- B * ( log(P/(1-P)) + log(sum(S[-State])) )
    
    Marginal <- Sstar - M$Shares[State]
    return(Marginal[[1]]) # drop column names
  }

}


QueryCost <- function(ID,State,S, LS=TRUE) {
  #What price will the market-maker demand for a purchase of S shares? 
  
  M <- Markets[[ID]]
  
  # Is market liquidity-sensitive?
  LS <- !!( M$MaxCommission )  # Returns FALSE iff MaxCommission == 0. At zero, liquidity sensitivity is off, implying LS=FALSE.
  
  if(!LS) {
    # original way
    B <- M$B
    
    #Original Case
    S0 <- M$Shares
    LMSR <- B*log(sum(exp(S0/B)))
    
    #Proposed Adjustment
    S1 <- S0;  S1[State] <- S1[State] + S
    LMSR2 <- B*log(sum(exp(S1/B)))
  }
  
  if(LS) {
    # liquidity sensitivity
    B <- sum( M$Shares )
    
    #Original Case
    S0 <- M$Shares
    LMSR <- B*log(sum(exp(S0/B)))
    
    #Proposed Adjustment
    S1 <- S0;  S1[State] <- S1[State] + S
    B <- sum( Markets[[ID]]$Shares )
    LMSR2 <- B*log(sum(exp(S1/B)))
  }
  
  return( LMSR2-LMSR )
}


QueryMoveCost <- function(ID,State,P) {
  # How much would it cost to set the probability to P?
  NewS <- QueryMove(ID,State,P) 
  return( QueryCost(ID,State, NewS ) )
}



## User Accounts ##
CreateUserSpace <- function() {
  Users <<- vector("list",length=0) # Critical Step...creates (blank) user-space. Would erase the existing userspace if called twice.
}


CreateAccount <- function(Name,Qfunds) {
  #Creates an account filled with money. 
  #Obviously, this is a crucial step which will require (!) verification of Bitcoin payments, an X-confirmation delay, etc. For testing we allow unconstrained (free/infinite) cash.
  #These accounts have simple toy names, actual accounts would be addresses themselves.
  Users[[Name]]$Cash <<- Qfunds
}



## Buying and Selling Shares ##

Buy <- function(uID, ID, State, P, Verbose=TRUE) {
  
  # State Label
  SL <- paste("State",State,sep="")
  
  # Calculate Required Cost
  BaseCost <- QueryMoveCost(ID,State,P)         # trade cost assuming no fees
  Fee <- BaseCost * Markets[[ID]]$TradingFee    # fees for buying only
  TotalCost <- BaseCost + Fee                   # Total cost including Fee

  MarginalShares <- QueryMove(ID,State,P)
  if(MarginalShares<0) return("Price already exceeds target. Sell shares or buy a Mutually Exclusive State (MES).")
  if(Verbose) { print(paste("Calulating Required Shares...", MarginalShares)); print(paste("Determining Cost of Trade...",BaseCost)); print(paste("Fee:",Fee)) }
  
  # For User: Reduce Funds, add Shares
  # Reduce Funds
  if( Users[[uID]]$Cash < TotalCost) return("Insufficient Funds")
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - TotalCost 
  #
  # Add Shares
  OldShares <- tryCatch(  expr = Users[[uID]][[ID]][[SL]],  # Look to see how many shares are already owned...
                          error = function(x) 0  )          # ...if lookup fails, assume none are owned.
  if( is.null(OldShares) ) OldShares <- 0                   # or if there is no entry at all (...database headaches...)
  
  NewShares <- OldShares + MarginalShares
  
  tryCatch( expr = { Users[[uID]][[ID]][[SL]] <<- NewShares },  # Edit the existing value...
                     error = function(x) {                      # ...if no existing value, add one...
                       
                       Users[[uID]][[ID]][[SL]] <<- c(Users[[uID]][[ID]][[SL]], "NewValue"=NewShares)  # Append a new data-slot
                       names(Users[[uID]][[ID]])[ names(Users[[uID]][[ID]])=="NewValue" ] <<- SL       # Rename the slot
                       
                       })  
  
  # For Market: Credit Funds, add Shares
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + BaseCost
  Markets[[ID]]$FeeBalance <<-  Markets[[ID]]$FeeBalance + Fee
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares  
  
  if(Verbose) print(paste("Bought",MarginalShares,"for",TotalCost,"."))
  return(c(MarginalShares,TotalCost))
}


Sell <- function(uID, ID, State, S, Verbose=TRUE) {
  
  # For user-friendliness reasons, as well as for technical reasons concerning the LS-LMSR,
  # I don't ask for P (what price you'd like to move to), instead I just ask for S (how many shares to sell).
  
  # State Label
  SL <- paste("State",State,sep="")
  
  # Check Market Eligibility
  if(Markets[[ID]]$State == 2) {
    print("This market has resolved...use Redeem instead.") 
    return(-1) }
  
  # Calculate Required Cost
  Cost <- QueryCost(ID, State, -S) # Shares are negative, as is Cost
  
# No longer needed:
#   MarginalShares <- QueryMove(ID,State,P)
#   if(MarginalShares>0) return("Price already below target. Buy shares or sell a Mutually Exclusive State (MES).")
  if(Verbose) { print("Determining Revenue for sale of"); print(S); print("shares..."); print(-Cost) }
  
  # Reduce shares, add Funds
  tryCatch( expr = { OldShares <- Users[[uID]][[ID]][[SL]] },   # Lookup how many shares this person owns...
            error = function(x) 0 )
  
  if(OldShares<(S)) return("Insufficient Shares")                      # Does trader have enough?
  Users[[uID]][[ID]][[SL]] <<- OldShares - S                           # Users lose shares...
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost                      # ...but gain $. ( Cost is negative )

  # cleanup if we no longer need this data-slot
  Data <- Users[[uID]][[ID]]
  if( Data[[SL]]==0 ) {  
    
    if( length(Data)==1 ) {
      Users[[uID]][[ID]] <- NULL   # erase the whole thing
    }
    
    if( length(Data)!=1 ) {
      Users[[uID]][[ID]] <- Data[ names(Data) != SL ]  # erase only one
    }
    
  }
  
  # Remove Funds and Shares from Market
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost              # Cost is negative
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] - S 
  
  if(Verbose) print(paste("Sold", S, "for", -1*Cost, "."))
  return( c(S, Cost) )
}


Redeem <- function(uID, ID, State, S, Verbose=TRUE) {
  # This function takes over after the event's state has been determined, and all
  # shares now have a fixed value, as determiend by the outcom-resolution process.
  
  # State Label
  SL <- paste("State",State,sep="")

  # Check Market Eligibility
  if( Markets[[ID]]$State == 1 ) {
    print("You cannot redeem (sell) using this function until there is a consensus about the outcome.") 
    return(-1) }      
  
  # Check Share Ownership
  OldShares <- Users[[uID]][[ID]][[SL]]
  MarginalShares <- S*-1 # Users are expected to enter +3 if they wish to sell 3 shares, ie marginally change shares by -3.
  if(OldShares<(-1*MarginalShares)) { # Remember, shares are negative.
    print("Insufficient Shares") 
    return(-3) }
  
  # Calculate Share Value (Simple joint-probability), and extracts the relevant price.
  FinalPrice <- GetFinalPrices(Markets[[ID]])[State]
  Cost <- MarginalShares*FinalPrice[[1]] # All shares have equal value, [[1]] to trim label 
    
  #Reduce shares, add Funds
  Users[[uID]][[ID]][[SL]] <<- OldShares + MarginalShares # MarginalShares are negative
  Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost # Cost is negative
  
  #Remove Funds and Shares from Market
  Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost 
  Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares 
  
  if(Verbose) print(paste("Redeemed",-1*MarginalShares,"for",-1*Cost,"."))
  return( c(MarginalShares, Cost) )

}  
