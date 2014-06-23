
### Market Structure/Example ###

#Load
Use <- function(package) { if(suppressWarnings(!require(package,character.only=TRUE))) install.packages(package,repos="http://cran.case.edu/") ; require(package,character.only=TRUE) }
options(stringsAsFactors = FALSE)
Use('digest')


## Global Data Sets ##

CreateDecisionSpace <- function() {
  # Creates the dataset we use to store Decisions
  # Only run this once ...(will erase everything and create a new dataset, otherwise).

   Temp <- data.frame(Decision_ID="xcharacter",
                      Size=0,
                      Branch="character",
                      Prompt="character",
                      OwnerAd="character",
                      EventOverBy=5,        # corresponds to the voting period in which this information will be widely and readily availiable.  
                      Scaled=FALSE,         # FALSE equals binary (all or nothing yes/no), TRUE indicates continuous value
                      Min=0,                # Only meaningful for scaled
                      Max=1                 # Only meaningful for scaled
                      )
  
  Finalized <- Temp[-1,] # erase dummy row
  
  Decisions <<- Finalized #global assign
  
}

CreateBranchSpace <- function() {
  # Creates the dataset we use to store Branches
  # Only run this once ...(will erase everything and create a new dataset, otherwise).
  
  Branches <<- data.frame(Name="Main",
                          ExodusAddress="1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8", # which coin was split to make the Votecoins for this branch
                          Description="The main Votecoin branch, for all your Prediction Market needs. \n Rules: 1] Decisions involving violence (murder, threats, theft, destruction) in ANY WAY resolve to .5",
                          
                          BaseListingFee=.01,
                          FreeDecisions=5,        # First 5 Decisions are free
                          TargetDecisions=75,     # Next 70 Decisions cost .01
                          MaxDecisions=300,       # Decisions become incrementally more expensive from 76-300, after which they cannot be added.
                          
                          MinimumTradingFee=.0001, # Voters want at least (1/2) of this.
                          
                          VotingPeriod=4032,       # Vote every 4032 blocks, or every 4 weeks (once a month) [might use regular time instead, if reliable?]
                          BallotTime=1008,         # Time between 'start of voting' and 'voting deadline'. Submit Ballots during this time.
                          UnsealTime=1008,         # Time between 'votind deadline' and 'unseal deadline'. Submit private keys during this time.
                          
                          ConsensusThreshold=.75
                          )
}

AddBranch <- function(Name, ExodusAddress, Description, BaseListingFee, FreeDecisions, TargetDecisions, MaxDecisions, MinimumTradingFee, 
                      VotingPeriod, BallotTime, UnsealTime, ConsensusThreshold) {
  # Adds a New Branch to the mix.
  
  # Check and make sure that we haven't already added that branch.
  if( sum( Branches$Name=="Politics" ) == 1 ) {
    print("A branch with that name already exists.")
    return(-1)
  }
  
  # Make sure parameters make sense
  if( !((0 <= FreeDecisions) & (FreeDecisions <= TargetDecisions) & (TargetDecisions <= MaxDecisions)) ) {
    print("Free/Target/Max Decisions must be non-negative and increasing")
    return(-2)
  }  
  if( BallotTime + UnsealTime >= VotingPeriod ) {
    print("Irregular overlap in voting periods. Provide longer inter-consensus time, or shorten Ballot / Unseal times.")
    return(-3)
  }  
  

  Branches <<- rbind(Branches, data.frame(Name=Name,
                                          ExodusAddress=ExodusAddress,
                                          Description=Description,
                                          
                                          BaseListingFee=BaseListingFee,
                                          FreeDecisions=FreeDecisions,
                                          TargetDecisions=TargetDecisions,
                                          MaxDecisions=MaxDecisions,
                                          
                                          MinimumTradingFee=MinimumTradingFee,
                                          
                                          VotingPeriod=VotingPeriod,
                                          BallotTime=BallotTime,
                                          UnsealTime=UnsealTime,
                                          
                                          ConsensusThreshold=ConsensusThreshold
                                          )
                     )
}


CreateDecisionSpace()
CreateBranchSpace()

AddBranch(Name="Politics", ExodusAddress="1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8", Description="Politics, particularly US Elections. No violence.",
          BaseListingFee=.02, 10, 200, 600, MinimumTradingFee=.0005, VotingPeriod=26208, 2016, 2016, ConsensusThreshold=.80)


FillDecisionInfo <- function(UnfilledDecision, Verbose=FALSE) {
  # Gets the ID and Size of the Decision.
  
  NewDecision <- UnfilledDecision

  # md5 hashes the Market, ignoring the hash field for reproduceability, and the shares/balance fields for consistency.
  x <- unlist(UnfilledDecision[-1:-2])
  NewDecision$Decision_ID <- digest(x, "md5")
  
  #Size of the Decision in bytes. This may be requried to prevent spam.
  x <- deparse(UnfilledDecision[-1:-2])
  if(Verbose) {print("Getting Bytes..."); print(x)}
  NewDecision$Size <- sum(nchar(x, type="bytes"))
  
  return(NewDecision)
}

AddDecision <- function(Branch, Prompt, OwnerAd, EventOverBy, Scaled=FALSE, Min=0, Max=1) {
  
  # Check Branch Integrity
  if( sum( Branches$Name=="Politics" ) != 1 ) {
    print("There is no (unique) branch with that name.")
    return(-1)
  }
  
  Temp <- data.frame(Decision_ID=NA,
                     Size=NA,
                     Branch=Branch,
                     Prompt=Prompt,
                     OwnerAd=OwnerAd,
                     EventOverBy=EventOverBy,     
                     Scaled=Scaled,
                     Min=Min,
                     Max=Max
                     )
  
  New <- FillDecisionInfo(Temp)
  
  
  # Check Preexistance
  if( sum(Decisions$Decision_ID==New$Decision_ID) > 0 ) {
    print("A Decision with that name already exists.")
    return(-2)
  }
  
  # Check Availiable Space
  ExistingDecisionQuantity <- sum(Decisions$Branch==Branch & Decisions$EventOverBy==EventOverBy)
  dMax <- Branches[Branches$Name==Branch, "MaxDecisions"]
  if( ExistingDecisionQuantity >= dMax ) {
    print("Too many Decisions in this Voting Period, move to another.")
    return(-3)
  }
  
    
  # Pay Required Fees  
  dFree <- Branches[Branches$Name==Branch, "FreeDecisions"]
  dTarget <- Branches[Branches$Name==Branch, "TargetDecisions"]
  
  BaseFee <- Branches[Branches$Name==Branch, "BaseListingFee"]
  
  if( ExistingDecisionQuantity <= dFree) {
    print("Decision is free.")
    FinalListFee <- 0
  }
  
  if( (ExistingDecisionQuantity > dFree) & (ExistingDecisionQuantity <= dTarget) ) {
    print("Decision costs Base amount.")
    FinalListFee <- BaseFee
  }
  
  if( ExistingDecisionQuantity > dTarget ) {
    print("Decision costs Base amount.")
    Excess <- ExistingDecisionQuantity - dTarget
    FinalListFee <- BaseFee + Excess*BaseFee
  }
  
  print(FinalListFee)
    
  Decisions <<- rbind(Decisions, New)
}


AddDecision(Branch="Politics", Prompt="Did Barack H Obama win the United States 2012 presidential election?",
            OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh", EventOverBy=5)
AddDecision(Branch="Politics", Prompt="Did the Democratic Party Candidate win the United States presidential election in 2016?",
            OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh", EventOverBy=5)
AddDecision(Branch="Politics", Prompt="Did the Democratic Party win (only) a majority of Senate seats?",
            OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh", EventOverBy=5)
AddDecision(Branch="Politics", Prompt="Did the Democratic Party win (only) a three-fifths supermajority of Senate seats (60+)?",
            OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh", EventOverBy=5)
AddDecision(Branch="Politics", Prompt="Did the Democratic Party win a two-thirds supermajority of Senate seats (67+)?",
            OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh", EventOverBy=5)
AddDecision(Branch="Politics", Prompt="Did the Democratic Party win (only) a majority of House seats?",
            OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh", EventOverBy=5)
AddDecision(Branch="Politics", Prompt="Did the Democratic Party win a two-thirds supermajority of House seats (290+)?",
            OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh", EventOverBy=5)

## Sample Markets ##
M1 <- list(
          # features which change during trading
  
           Market_ID=NA,    #hash of c1[-1:-7] (permanent features)
           Size=NA,         #size in bytes of c1[-1:-7] (permanent features) 
           Shares=NA,       #initially, zero of course
           Balance=NA,      #funds in escrow for this Market
           FeeBalance=NA,   #Transaction Fees Collected
           State=1,         # 1 indicates active (ie "trading"), 2 = "contested", 3 = "redeemable"
           B=1,             #Liquidity Parameter

           #permanent features
           TradingFee=.01,  #Cost to traders for participating in this market
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",  #the Bitcoin address of the creator of this Market
           Title="Obama2012",                             #title - not necessarily unique
           Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
           #in practice, this might be pretty long.
           Tags=c("en", "UnitedStates", "Politics", "President", "Winner"), #ordinal descriptors, so individuals can find the market
           MaturationTime=5,   #max of Decision "EventOverBy", the point in time where all required info is available  
           D_State=list( "184b97f33923f30a9f586827b400676e" )
)

M2 <- list(Market_ID=NA,
           Size=NA,
           Shares=NA,
           Balance=NA,
           FeeBalance=NA,
           State=1,
           B=2,
           
           TradingFee=.01,  
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           Title="Dems2016",                 
           Description="Democratic Control of the United States federal government following 2016 election.\nThis Market ...",
           Tags=c("en", "UnitedStates", "Politics", "President", "Congress"),
           MaturationTime=5,
           D_State=list( "2024304e88665e58b3147b9bfd33fb1f",
                         c("4bb76625de425c29ce52150cc5b3f160", "b8b085a2957ae1359056257cce61f0c8", "1800a5b6dc68dfddafbe4bf32ca813dc"),
                         c("b55b9a7faf26a97d0a06e16c7151ba33", "1d5ae87389527a9b9916fffd6b6b511c")
                         )
)


## Functions to Define/Set Attributes of Markets
LongForm <- function(Ctr) return(unlist(Ctr))
#unlists the info - easier to hash (convienience only)


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
  #Size of the Market in bytes. This may be requried to prevent spam.
  x <- deparse(Market[-1:-6])
  if(Verbose) {print("Getting Bytes..."); print(x)}
  return( sum(nchar(x, type="bytes")) )
}

# > GetSize(M1)
# [1] 511
# > GetSize(M2)
# [1] 693


GetDim <- function(Input, Raw=TRUE) {
  #Infers, from the D_State ("decision space") the total size of this Markets.
  Dim <- unlist( lapply(Input$D_State,length) )
  if(Raw) Dim <- Dim + 1
  #each question corresponds to one partition of the space, thus for each dimension N questions yeilds N+1 states
  return(Dim)
}

# > GetDim(M1)
# [1] 2
# > GetDim(M2)
# [1] 2 4 3


GetSpace <- function(Market, Verbose=FALSE) {
  #Takes a Market, specifically its D_States, and constructs the array of possible ending states.
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
  EndingDates <- Decisions[ Decisions$Decision_ID %in% StateInfo, "EventOverBy" ] # extract the relevant section (match by ID, endings)
  return( max(as.numeric(EndingDates)) )
}


FillMarketInfo <- function(UnfilledMarket) {
  #Takes a basic, unfinished Market and fills out some details like the 'size', 'hash', etc. Also calulates the required seed capital for a given B level.
  #For security and simplicity the Market is hashed after the 'B' (and initial balance) are set. Then one only needs to verify that the balance was truly established.
  #Other fields, such as 'balance' and 'share', which would change constantly and rapidly, are calcualted from the base ("blank") Market.
  #Size is calculated second-to-last on the final Market to account for exponentially increasing Share space.
  NewMarket <- UnfilledMarket
  NewMarket$MaturationTime  <- GetEndingDate(UnfilledMarket)
  NewMarket$Shares <- 0*GetSpace(UnfilledMarket)

  #AMM seed capital requirement is given as b*log(N), where N is the number of states the Market must support.
  Nstates <- max(GetSpace(UnfilledMarket))
  NewMarket$Balance <- NewMarket$B*log(Nstates)
  
  NewMarket$Size <- GetSize(NewMarket)
  NewMarket$Market_ID <- GetId(NewMarket)
  return(NewMarket)
}

M1f <- FillMarketInfo(M1)
M2f <- FillMarketInfo(M2)


#Possibly Obsolete
GetDecisionRows <- function(Market) {
  #Takes a Market and returns the set of Decisions that will need to be made
  #Build IDs for UJ
  Dim <- GetDim(Market,0)
  UJ_ID <- vector(length=0)
  
  for(i in 1:length(Dim)) UJ_ID <- c(UJ_ID, rep(i,Dim[i]) )

  Dvec <- (1:length(Dim))[UJ_ID] #Dimensions
  Svec <- unlist( lapply(X=GetDim(Market,0),FUN=function(x) 1:x) ) #State-dividers

  DfStates <- data.frame("IDc"=Market$Market_ID,
                         "IDd"=Dvec,
                         "IDs"=Svec,
                         "IDd"=unlist(Market$D_State)[ names(unlist(Market$D_State))=="Decision_ID" ],
                         "T"=unlist(Market$D_State)[ names(unlist(Market$D_State))=="EventOverBy" ],
                         "UJ"=unlist(Market$D_State)[ names(unlist(Market$D_State))=="Prompt" ],
                         "J"=.5)
  return(DfStates)
}

# GetDecisionRows(M1f)
# GetDecisionRows(M2f)

#Possibly Obsolete
MapJudgement <- function(Results,Market) {
  
  #Filter on correct Market.
  # (hasnt been done yet)
  
  #Market undecided - kick out to -1
  if(sum(Results$J==.5)>0) return(-2)
  
  #Decided Markets ...traverse the OutComeSpace
  Results$T <- Results$IDs*Results$J + 1  # +1 for index.. R does not count from zero
  PreState <- 1:length(GetDim(Market))
  for(i in 1:length(PreState)) PreState[i] <- max(Results$T[Results$IDd==i])
  
  State <- GetSpace(Market)[PreState[1],PreState[2],PreState[3]]
  return(State)
  
}

#Assume some results
#
# > Results <- GetDecisionRows(M2f)
# > Results$J <- c(0,0,0,0,0,1)
# > Results
#
# > MapJudgement(Results,M2f)
# [1] 17


## Marketplace Creation ##
Markets <- vector("list",length=0) #Critical Step...creates (blank) marketplace (branch). Would erase the existing marketplace if called twice.

CreateMarket <- function(Title,
                         B=1,
                         TradingFee=.01,
                         D_State=list( "184b97f33923f30a9f586827b400676e" ), #Decisions
                         Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
                         Tags=c("Politics, UnitedStates, President, Winner"),
                         OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh"
                         ) {
  

  # Create Object
  TempMarket <- list( Market_ID=NA,Size=NA,Shares=NA,Balance=NA,FeeBalance=0,State=1,B=B,TradingFee=TradingFee,OwnerAd=OwnerAd,Title=Title,
                       Description=Description,Tags=Tags,MaturationTime=NA,D_State=D_State )
  
  # Prepare Object
  Temp2 <- FillMarketInfo(TempMarket)
  
  # Check Pre-existance
  if( !is.null(Markets[[Temp2$Title]]) ) {  #!is.null(Markets[[Temp2$Market_ID]])
    print("That exact market already exists.")
    return(-1)
  }
   
  #Add a new Market to the global 'Marketplace' variable.  
  Markets[[Temp2$Title]] <<- Temp2     #Markets[[Temp2$Market_ID]] <<- Temp2 
  
}

CreateMarket("Obama2012")
CreateMarket(Title="USFedElect2016",
             B=2.5,
             TradingFee=.005,
             D_State=list( # This contract has 3 dimensions. 
               
                       c("2024304e88665e58b3147b9bfd33fb1f"),  # Dim 1 is typical 2-state, containing one Decision.
         
                       c("4bb76625de425c29ce52150cc5b3f160",   # Dim 2 actually has 4 mutually-exclusive states (N Decisions = N+1 States)
                         "b8b085a2957ae1359056257cce61f0c8",
                         "1800a5b6dc68dfddafbe4bf32ca813dc"),
                       
                       c("b55b9a7faf26a97d0a06e16c7151ba33",   # Dim 3 has 3 mutually-exclusive states, and requires 2 Decisions.
                         "1d5ae87389527a9b9916fffd6b6b511c")
                       ),

             Description="One stop shopping for all of your federal election predictions.",
             Tags=c("en", "UnitedStates", "Politics", "President", "Winner"),
             OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh"
             )
