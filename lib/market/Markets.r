
### Market Structure/Example ###

#Load
Use <- function(package) { if(suppressWarnings(!require(package,character.only=TRUE))) install.packages(package,repos="http://cran.case.edu/") ; require(package,character.only=TRUE) }
options(stringsAsFactors = FALSE)
Use('digest')


## Sample Decisions ##

#Change this around with an 'add decision' which contains branch info, calcs ID, etc. !

D1 <- list(Decision_ID=NA,
           Size=NA,
           Prompt="Did Barack H Obama win the United States 2012 presidential election?",
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           EventOverBy=5 #block number, corresponds to time that this information will be widely and readily availiable.  
           )

D2 <- list(Decision_ID=NA,
           Size=NA,
           Prompt="Did the Democratic Party Candidate win the United States presidential election in 2016?",
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           EventOverBy=5 #block number, corresponds to time that this information will be widely and readily availiable.  
)

D3 <- list(Decision_ID=NA,
           Size=NA,
           Prompt="Did the Democratic Party win (only) a majority of Senate seats?",
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           EventOverBy=5 #block number, corresponds to time that this information will be widely and readily availiable.  
)

D4 <- list(Decision_ID=NA,
           Size=NA,
           Prompt="Did the Democratic Party win (only) a three-fifths supermajority of Senate seats (60+)?",
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           EventOverBy=5 #block number, corresponds to time that this information will be widely and readily availiable.  
)

D5 <- list(Decision_ID=NA,
           Size=NA,
           Prompt="Did the Democratic Party win a two-thirds supermajority of Senate seats (67+)?",
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           EventOverBy=5 #block number, corresponds to time that this information will be widely and readily availiable.  
)

D5 <- list(Decision_ID=NA,
           Size=NA,
           Prompt="Did the Democratic Party win a two-thirds supermajority of Senate seats (67+)?",
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           EventOverBy=5 #block number, corresponds to time that this information will be widely and readily availiable.  
)

D6 <- list(Decision_ID=NA,
           Size=NA,
           Prompt="Did the Democratic Party win (only) a majority of House seats?",
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           EventOverBy=5 #block number, corresponds to time that this information will be widely and readily availiable.  
)

D7 <- list(Decision_ID=NA,
           Size=NA,
           Prompt="Did the Democratic Party win a two-thirds supermajority of House seats (67+)?",
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           EventOverBy=5 #block number, corresponds to time that this information will be widely and readily availiable.  
)




## Sample Markets ##
M1 <- list(
          # features which change during trading
  
           Market_ID=NA,    #hash of c1[-1:-7] (permanent features)
           Size=NA,         #size in bytes of c1[-1:-7] (permanent features) 
           Shares=NA,       #initially, zero of course
           Balance=NA,      #funds in escrow for this Market
           FeeBalance=NA,   #Transaction Fees Collected
           State=-2,        # -2 indicates active (ie neither trading nor judging are finished).
           B=1,             #Liquidity Parameter

           #permanent features
           TradingFee=.01,  #Cost to traders for participating in this market
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",  #the Bitcoin address of the creator of this Market
           Title="Obama2012",                             #title - not necessarily unique
           Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
           #in practice, this might be pretty long.
           Tags=c("en", "UnitedStates", "Politics", "President", "Winner"), #ordinal descriptors, so individuals can find the market
           MaturationTime=5,   #max of Decision "EventOverBy", the point in time where all required info is available  
           D_State=list( D1 )
)

M2 <- list(Market_ID=NA,
           Size=NA,
           Shares=NA,
           Balance=NA,
           FeeBalance=NA,
           State=-2,
           B=2,
           
           TradingFee=.01,  
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           Title="Dems2016",                 
           Description="Democratic Control of the United States federal government following 2016 election.\nThis Market ...",
           Tags=c("en", "UnitedStates", "Politics", "President", "Congress"),
           MaturationTime=5,
           D_State=list( D2, c(D3,D4,D5), c(D6,D7) )
           #option to also use (or always use) hash of an existing Conout
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
# [1] "c9f569b3d66ce52390e7a3370db2edab"
# > GetId(M2)
# [1] "fe26330f3c2c54f860d1611f3e004767"


GetSize <- function(Market,Verbose=FALSE) {
  #Size of the Market in bytes. This may be requried to prevent spam.
  x <- deparse(Market[-1:-6])
  if(Verbose) {print("Getting Bytes..."); print(x)}
  return( sum(nchar(x, type="bytes")) )
}

# > GetSize(M1)
# [1] 753
# > GetSize(M2)
# [1] 2106


GetDim <- function(Input,Raw=TRUE) {
  #Infers, from the D_State ("decision space") the total size of this Markets.
  Dim <- unlist( lapply(Input$D_State,length) ) / 5   #Decisions have 5 items
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
  StateInfo <- unlist(Market$D_State)               #grab the info
  EndingDates <- StateInfo [ names(StateInfo)=="EventOverBy" ] #extract the relevant section
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

GetDecisionRows(M1f)
GetDecisionRows(M2f)

#Assume some results

Results <- GetDecisionRows(M2f)
Results$J <- c(0,0,0,0,0,1)
Results

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

# > MapJudgement(Results,M2f)
# [1] 17


## Marketplace Creation ##
Marketplace <- vector("list",length=0) #Critical Step...creates (blank) marketplace (branch). Would erase the existing marketplace if called twice.

CreateMarket <- function(Title,
                         B=1,
                         TradingFee=.01,
                         D_State=list(D1), #Decisions
                         Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
                         Tags=c("Politics, UnitedStates, President, Winner"),
                         OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh"
                         ) {
  
  #check to see if market already exists, if it does, amp beta instead of creating a new market
  
  #Create Object
  TempMarket <- list( Market_ID=NA,Size=NA,Shares=NA,Balance=NA,FeeBalance=0,State=-2,B=B,TradingFee=TradingFee,OwnerAd=OwnerAd,Title=Title,
                       Description=Description,Tags=Tags,MaturationTime=NA,D_State=D_State )
  
  #Prepare Object
  Temp2 <- FillMarketInfo(TempMarket)
           
  #Add a new Market to the global 'Markets' variable.
  #Use 'Title' for testing/understanding. I anticipate we will actually use the hash for uniqueness.  
  #Markets[[Temp2$Market_ID]] <<- Temp2 
  Marketplace[[Temp2$Title]] <<- Temp2
}

CreateMarket("Obama2012")
CreateMarket(Title="USFedElect2016",B=2.5,TradingFee=.005,
             D_State=list(
                      c(D2),
                      c(D3,D4,D5),
                      c(D6,D7)
                      ),
             Description="One stop shopping for all of your federal election predictions.",
             Tags=c("en", "UnitedStates", "Politics", "President", "Winner"),
             OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh"
             )