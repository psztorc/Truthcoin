# Markets / Branches / Decisions
# Paul Sztorc
# Written in R (v 3.1.1) using Rstudio (v 0.98.1028)

#Load
Use <- function(package) { if(suppressWarnings(!require(package,character.only=TRUE))) install.packages(package,repos="http://cran.case.edu/") ; require(package,character.only=TRUE) }
options(stringsAsFactors = FALSE)

Use('digest')
Sha256 <- function(x) digest(unlist(x),algo='sha256',serialize=FALSE)

tryCatch(expr=setwd("~/GitHub/Truthcoin/lib"), error=function(e) setwd(choose.dir(caption="Failed to set working directory automatically. Choose 'lib' folder:")) )
source(file="market/ListingFee.r")



## Global Parameters

FeePerKb=.0001          # Message Fee (discourage spam)
SpaceFee=log(8)/(8^2)   # Second listing fee...designed to lightly discourage low-k, high-n Markets with more than N=256 states. Recall, set st f1(x) = a(x^2) = f2(x) = b (log(x)) @ x=8 
MaxCommission <- 0.01   # For use in the Liquidity-Sensitive market maker

## Global Data Sets ##

CreateDecisionSpace <- function() {
  # Creates the dataset we use to store Decisions
  # Only run this once ...(will erase everything and create a new dataset, otherwise).

   Temp <- data.frame(Decision_ID="xcharacter",
                      State=0,             # The status of this Decision (-1 = Resolved, 0 = No Attempts, N = N failed resolution attempts)
                      ResolvedOutcome=NA,     # The post-judgement result.
                      Size=0,
                      Branch="character",
                      Prompt="character",
                      OwnerAd="character",
                      TauFromNow=5,        # corresponds to the voting period in which this information will be widely and readily availiable.  
                      Scaled=FALSE,         # FALSE equals binary (all or nothing yes/no), TRUE indicates continuous value
                      Min=0,                # Only meaningful for scaled
                      Max=1,                # Only meaningful for scaled
                      
                      Standard=1            # Standard or Overflow
                      )
  
  Finalized <- Temp[-1,] # erase dummy row
  
  Decisions <<- Finalized # global assign
  
}

CreateBranchSpace <- function() {
  # Creates the dataset we use to store Branches
  # Only run this once ...(will erase everything and create a new dataset, otherwise).
  
  Branches <<- data.frame(
                    ID=NA,
                    Name="Main",
                    
                    ExodusAddress="1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8", # which coin was split to make the Votecoins for this branch
                    Description="The main Votecoin branch, for all your Prediction Market needs. \n Rules: 1] Decisions involving violence (murder, threats, theft, destruction) in ANY WAY resolve to .5",
                    
                    BaseListingFee=.01,
                    
                    MaxDecisions=300,       # Related to Tau (the Voting Period)
                    
                    MinimumTradingFee=.0001, # Voters want at least (1/2) of this.
                    
                    VotingPeriod=4032,       # "Tau". Vote every 4032 blocks, or every 4 weeks (once a month) [might use regular time instead, if reliable?]
                    BallotTime=1008,         # Time between 'start of voting' and 'voting deadline'. Submit Ballots during this time.
                    UnsealTime=1008,         # Time between 'voting deadline' and 'unseal deadline'. Submit private keys during this time.
                    
                    TauRange=3,              # Impacts the Branch significantly, in Listing-Fee-Calculations and Continuance-Inconvenience
                    
                    ConsensusThreshold=.75   # "Phi" To address the 51% buyup attack. [optional, or this may be a global parameter with automatic branching]
                          )
  
  ID <- digest(unlist(Branches[1,-1]), "md5")
  Branches[1,"ID"] <<- ID
  
}

CreateMarketSpace <- function() {
  # Just create an empty list
  
  Markets <<- vector("list",length=0) 
  
}

AddBranch <- function(Name, ExodusAddress, Description, BaseListingFee, MaxDecisions, MinimumTradingFee, 
                      VotingPeriod, BallotTime, UnsealTime, TauRange, ConsensusThreshold) {
  # Adds a New Branch to the mix.
  
  # Check and make sure that we haven't already added that branch.
  if( sum( Branches$Name==Name ) == 1 ) {
    print("A branch with that name already exists.")
    return(-1)
  }
  
  # Make sure parameters make sense
  if( BallotTime + UnsealTime >= VotingPeriod ) {
    print("Irregular overlap in voting periods. Provide longer inter-consensus time, or shorten Ballot / Unseal times.")
    return(-2)
  }  

  IncomingBranch <- data.frame(
                     ID='filled_later',
                     Name=Name,
                     
                     ExodusAddress=ExodusAddress,
                     Description=Description,
                     
                     BaseListingFee=BaseListingFee,
                     MaxDecisions=MaxDecisions,
                     
                     MinimumTradingFee=MinimumTradingFee,
                     
                     VotingPeriod=VotingPeriod,
                     BallotTime=BallotTime,
                     UnsealTime=UnsealTime,
                     
                     TauRange=TauRange,
                     
                     ConsensusThreshold=ConsensusThreshold
  )
  
  ID <- digest(unlist(IncomingBranch[1,-1]), "md5")
  IncomingBranch[1,"ID"] <- ID
  
  Branches <<- rbind(Branches, IncomingBranch)
   
}

# Eventually, there will need to be a function to "update the branch rules", which will probably require some kind of 75% vote.


FillDecisionInfo <- function(UnfilledDecision, Verbose=FALSE) {
  # Gets the ID and Size of the Decision.
  
  NewDecision <- UnfilledDecision

  # md5 hashes the Decision, ignoring all mutable fields.
  x <- unlist(UnfilledDecision[-1:-4])
  NewDecision$Decision_ID <- digest(x, "md5")
  
  #Size of the Decision in bytes. This may be requried to prevent spam.
  x <- deparse(UnfilledDecision[-1:-4])
  if(Verbose) {print("Getting Bytes..."); print(x)}
  NewDecision$Size <- sum(nchar(x, type="bytes"))
  
  return(NewDecision)
}

AddDecision <- function(Branch, Prompt, OwnerAd, TauFromNow, Scaled=FALSE, Min=0, Max=1, Standard=1) {
  
  # Check Branch Integrity
  if( sum( Branches$Name==Branch ) != 1 ) {
    print("There is no (unique) branch with that name.")
    return(-1)
  }
  
  Temp <- data.frame(Decision_ID=NA,
                     Size=NA,
                     State=0,         # Ie, no Judgement has occured.
                     ResolvedOutcome=NA, # Obviously, we don't know it yet.
                     
                     Branch=Branch,
                     Prompt=Prompt,
                     OwnerAd=OwnerAd,
                     TauFromNow=TauFromNow,     
                     Scaled=Scaled,
                     Min=Min,
                     Max=Max,
                     
                     Standard=Standard
                     )
  
  New <- FillDecisionInfo(Temp)
  
  
  # Check Preexistance
  if( sum(Decisions$Decision_ID==New$Decision_ID) > 0 ) {
    print("A Decision with that name already exists.")
    return(-2)
  }
  
  # Check Availiable Space
  ExistingDecisionQuantity <- sum(Decisions$Branch==Branch & Decisions$TauFromNow==TauFromNow)
  dMax <- Branches[Branches$Name==Branch, "MaxDecisions"]
  if( ExistingDecisionQuantity >= dMax ) {
    print("Too many Decisions in this Voting Period, move to another.")
    return(-3)
  }
  
    
  # Pay Required Fees  
  if(Standard==0) FinalListFee  <- QueryCostToAuthorOverflow(BranchToAddOn = Branch, TauUntillAfterEvent = TauFromNow)  
  if(Standard==1) FinalListFee  <- QueryCostToAuthorStandard(BranchToAddOn = Branch, TauUntillAfterEvent = TauFromNow)
  
  print(FinalListFee)
    
  Decisions <<- rbind(Decisions, New)
}




## Functions to Define/Set Attributes of Markets
LongForm <- function(Ctr) return(unlist(Ctr))
# unlists the info - easier to hash (convienience only)


GetId <- function(Market) {
  # md5 hashes the Market, ignoring the hash field for reproduceability, and the shares/balance fields for consistency.
  x <- LongForm(Market[-1:-6])
  return( digest(x,"md5") )
}

# > GetId(M1)
# [1] "c5e9554aef9ce1e865085ccf6c5a5f90"
# > GetId(M2)
# [1] "8110b4bc50d1c90befa9993682dee46c"


GetSize <- function(Market,Verbose=FALSE) {
  # Size of the Market in bytes. This may be requried to prevent spam.
  x <- deparse(Market[-1:-6])
  if(Verbose) {print("Getting Bytes..."); print(x)}
  return( sum(nchar(x, type="bytes")) )
}

# > GetSize(M1)
# [1] 511
# > GetSize(M2)
# [1] 693


GetDim <- function(Input, Raw=TRUE) {
  # Infers, from the D_State ("decision space") the total size of this Markets.
  Dim <- unlist( lapply(Input$D_State,length) )
  if(Raw) Dim <- Dim + 1
  # each question corresponds to one partition of the space, thus for each dimension N questions yeilds N+1 states
  return(Dim)
}

# > GetDim(M1)
# [1] 2
# > GetDim(M2)
# [1] 2 4 3


GetSpace <- function(Market, Verbose=FALSE) {
  # Takes a Market, specifically its D_States, and constructs the array of possible ending states.
  Dim <- GetDim(Market)
  if(Verbose) { print(paste( "Market Dimention(s):", paste(Dim,collapse=",")))}
  
  Names <- vector('list',length=length(Dim))
  for(i in 1:length(Dim)) Names[[i]] <- paste("d",i,".",c("No",rep("Yes",Dim[i]-1)) ,sep="" )
  
  MaxN <- prod(Dim) #multiply dimensions to get total # of partitions 
  JSpace <- array(data=1:MaxN,dim=Dim,dimnames=Names)
  return(JSpace)
}

# > GetSpace(M1)
# d1.No d1.Yes 
# 1      2 

# > GetSpace(M2)
# , , d3.No
# 
#         d2.No d2.Yes d2.Yes d2.Yes
# d1.No      1      3      5      7
# d1.Yes     2      4      6      8
# 
# , , d3.Yes
# 
#         d2.No d2.Yes d2.Yes d2.Yes
# d1.No      9     11     13     15
# d1.Yes    10     12     14     16
# 
# , , d3.Yes
# 
#         d2.No d2.Yes d2.Yes d2.Yes
# d1.No     17     19     21     23
# d1.Yes    18     20     22     24

#note that d here refers to 'dimension' and not 'decision'


GetEndingDate <- function(Market) {
  StateInfo <- unlist(Market$D_State)               # grab the Decision ID's
  EndingDates <- Decisions[ Decisions$Decision_ID %in% StateInfo, "TauFromNow" ] # extract the relevant section (match by ID, endings)
  return( max(as.numeric(EndingDates)) )
}


FillMarketInfo <- function(UnfilledMarket) {
  # Takes a basic, unfinished Market and fills out some details like the 'size', 'hash', etc. Also calulates the required seed capital for a given B level.
  # For security and simplicity the Market is hashed after the 'B' (and initial balance) are set. Then one only needs to verify that the balance was truly established.
  # Other fields, such as 'balance' and 'share', which would change constantly and rapidly, are calcualted from the base ("blank") Market.
  # Size is calculated second-to-last on the final Market to account for exponentially increasing Share space.
  
  # Switch: Is market liquidity sensitive
  LS <- TRUE
  if(UnfilledMarket$MaxCommission==0) LS <- FALSE
  
  # Basics
  NewMarket <- UnfilledMarket
  NewMarket$MaturationTime  <- GetEndingDate(UnfilledMarket)
  NewMarket$Shares <- 0*GetSpace(UnfilledMarket)

  # AMM seed capital requirement is given as b*log(N), where N is the number of states the Market must support.
  Nstates <- max(GetSpace(UnfilledMarket))
  NewMarket$Balance <- NewMarket$B*log(Nstates)
  
  if(LS) {
    # Liquidity Sensitivity
    Alpha <- NewMarket$MaxCommission / (Nstates * log(Nstates))
    MinShares <- (NewMarket$B / Alpha) / Nstates
    NewMarket$Shares <- 0*GetSpace(UnfilledMarket) + MinShares
    
    # Note: no need to go through the trouble of awarding these initial shares, then having the author redeem them.
    # It turns out that LMSR_UpdateCost( Initial_Shares ) - FinalValue( Intitial_Shares ) always = b * log (N) , anyways.
    # NewMarket$Balance <- sum(NewMarket$Shares) * log( sum( exp( NewMarket$Shares / sum(NewMarket$Shares) ) ) )
  
  }

  # Get size and hash of the Market's initial state
  NewMarket$Size <- GetSize(NewMarket)
  NewMarket$Market_ID <- GetId(NewMarket)
  
  return(NewMarket)
}

# > FillMarketInfo(M1)
# $Market_ID
# [1] "c5e9554aef9ce1e865085ccf6c5a5f90"
# 
# $Size
# [1] 511
#   ...

# > FillMarketInfo(M2)
# $Market_ID
# [1] "8110b4bc50d1c90befa9993682dee46c"
# 
# $Size
# [1] 693
# 
# ...


GetOutcomeAxis <- function(DecisionAxis, Verbose=FALSE) {
  # Intermediate step in 'Get Final Prices' (which calculates the final, Redeem-able value of Market Shares)
  # Takes the calculated Outcomes (ie Decisions that have been Voted on and Resolved), and transforms them to axis prices.
  # Relies on mutual exclusivity (ie, if all were Decided as not happening, the Null must have happened), and averages cases where two things are both said to have happened.
  
  N <- length(DecisionAxis)
  PreCompressedAxis <- matrix(NA, nrow=N, ncol=(N+1))
  for(j in 1:N) {
    Pair <- Decisions[Decisions$Decision_ID == DecisionAxis[j], "ResolvedOutcome"]
    PreCompressedAxis[j,(j+1)] <- Pair
  }
  
  if(Verbose) print(PreCompressedAxis)
  
  Out <- apply(PreCompressedAxis,2,function(x) mean(x,na.rm=TRUE))
  if(sum(Out, na.rm=TRUE) !=0) Out <- Out/sum(Out, na.rm=TRUE)  # renormalize (as long as we don't divide by zero)
  
  Null <- 1 - sum(Out, na.rm=TRUE)
  Out[1] <- Null
  
  return(Out)
  
}



Use("tensor")
Use("reshape")

GetFinalPrices <- function(Market, Verbose=FALSE) {
  
  # Takes a Market, and evaluates the value of its shares.
  # For multidimensional markets, this is literally the joint probability ( ie P(A) & P(B), calculated P(A) * P(B) ) 
  
  # Check Market State
  if( Market$State !=3 ) {
    print("This market does not yet HAVE final price. It is either being traded or audited.")
    return(-1) }

  # Get Each Axis of this Market
  nDim <- length(Market$D_State)
  Axes <- vector("list",nDim)
  for(i in 1:nDim) {
    Axes[[i]] <- GetOutcomeAxis( Market$D_State[[i]] )
  }
  
  # R cant handle array multiplication, in something-like-MATLAB, this would be simpler: Axes[[1]] * Axes[[2]] * Axes[[3]] 
  Accumulator <- Axes[[1]]
  
  if( nDim > 1) {
    for(i in 2:nDim) {
      Accumulator <- tensor(Accumulator, Axes[[i]]) # requires tensor package
    }
  }
  
  # reshape accumulated data into original format
  Out <- array( melt(Accumulator)$value,      
                dim=GetDim(Market),
                dimnames=dimnames(GetSpace(Market)) ) 
  
  return(Out)
  
}

# > GetFinalPrices(M1)
# [1] "This market does not yet HAVE final price. It is either being traded or audited."
# [1] -1
# > M1$State <- 3 # claim Market is Resolved
# > GetFinalPrices(M1)
#  d1.No  d1.Yes 
#      0       1 


## Governance Items

QueryAddMarket <- function(Title="USFedElect2016",
                           B=2.5,
                           TradingFee=.005,
                           MaxCommission=0,
                           D_State=list( 
                             c("2024304e88665e58b3147b9bfd33fb1f")
                           ),
                           Description="One stop shopping for all of your federal election predictions.",
                           Tags=c("en", "UnitedStates", "Politics", "President", "Winner"),
                           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh") {
  
  # Create Object
  TempMarket <- list( Market_ID=NA,Size=NA,Shares=NA,Balance=NA,FeeBalance=0,State=1,B=B,TradingFee=TradingFee,MaxCommission=MaxCommission,
                      OwnerAd=OwnerAd,Title=Title,Description=Description,Tags=Tags,MaturationTime=NA,D_State=D_State )
  
  # Prepare Object
  NewMarket <- FillMarketInfo(TempMarket) # LS makes no difference as far as cost
  
  Kb_calc <- NewMarket$Size           # Size of Market in KB       # Maybe leave this to miners?
  S_calc <- prod(GetDim(NewMarket))   # Size of the trading space. # Maybe leave this to miners?
  
  Seed_Capital <- NewMarket$B*log(S_calc)
  
  Out <- list("MarketMakerSeedCapital"=Seed_Capital,
              
              "kBRate"=FeePerKb,
              "kBSize"=Kb_calc,
              "kBCost"= (FeePerKb * Kb_calc),
              
              "CurrentSpaceRate"=SpaceFee,
              "SpaceLength"=S_calc, 
              "SpaceCost"=  (S_calc^2) * SpaceFee,              
              "TotalCost"= Seed_Capital + (FeePerKb * Kb_calc) + ((S_calc^2) * SpaceFee)  #Cost to list this Market.
  )
  return(Out)
}

# > QueryAddMarket(M1)
# $MarketMakerSeedCapital
# [1] 1.732868
# ...
# $TotalCost
# [1] 1.976333



CreateMarket <- function(Title,
                         B=1,
                         TradingFee=.01,
                         MaxCommission=.005,
                         D_State=list( "184b97f33923f30a9f586827b400676e" ), # Decisions
                         Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
                         Tags=c("Politics, UnitedStates, President, Winner"),
                         OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh"# ,
                         # Payment=" ! infeasable for this proof of concept ! "
                         ) {
  

  # Create Object
  TempMarket <- list( Market_ID=NA,Size=NA,Shares=NA,Balance=NA,FeeBalance=0,State=1,B=B,TradingFee=TradingFee,MaxCommission=MaxCommission,OwnerAd=OwnerAd,Title=Title,
                       Description=Description,Tags=Tags,MaturationTime=NA,D_State=D_State )
  
  # Prepare Object
  Temp2 <- FillMarketInfo(TempMarket)
  
  # Check Pre-existance
  if( !is.null(Markets[[Temp2$Title]]) ) {  # post-testing, switch to:  !is.null(Markets[[Temp2$Market_ID]])
    print("That exact market already exists.")
    return(-1)
  }
  
  # Check Payment
  ExpectedPayment <- QueryAddMarket(Title=Title,
                                       B=B,
                                       TradingFee=TradingFee,
                                       D_State=D_State,
                                       Description=Description,
                                       Tags=Tags,
                                       OwnerAd=OwnerAd)$TotalCost
  
  
  #   # This is shut off on purpose
  #   if( ExpectedPayment != Payment ) {
  #     print("Wrong payment.")
  #     print(paste("Expected:",ExpectedPayment,". Provided:",Payment))
  #     return(-2)
  #   }
   
  
  # FOR TESTING : Add a new Market to the global 'Marketplace' variable.  
  try( Markets[[Temp2$Title]] <<- Temp2 )       
  
  # Realistic
  try( BlockChain[[length(BlockChain)]]$Markets[[Temp2$Market_ID]] <<- Temp2 )
  # BlockChain[[length(BlockChain)]]$Markets is the 'Markets' section of the current block
  # [[ Temp2$MarketID ]] assigns the MarketId to this section of the database
  
  # the 'try' functions are so these don't fail in testing ... will be removed later
  
  
}

