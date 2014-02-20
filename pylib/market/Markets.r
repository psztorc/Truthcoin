
### Market Structure/Example ###

#Load
Use <- function(package) { if(suppressWarnings(!require(package,character.only=TRUE))) install.packages(package,repos="http://cran.case.edu/") ; require(package,character.only=TRUE) }
options(stringsAsFactors = FALSE)
Use('digest')

# NOTE! This section was built assuming someone would Author the Market and its Decisions separately. It will have to be slightly tweaked to comply with the final design.

## Functions to Define/Set Attributes of Markets
LongForm <- function(Ctr) return(unlist(Ctr))
#unlists the info - easier to hash (convienience only)

GetId <- function(CtrBlank) {
  # md5 hashes the Market, ignoring the hash field for reproduceability, and the shares/balance fields for consistency.
  x <- LongForm(CtrBlank[-1:-5])
  return( digest(x,"md5") )
}


GetSize<- function(CtrBlank,Verbose=FALSE) {
  #Size of the Market in bytes. This may be requried to prevent spam.
  x <- deparse(CtrBlank[-1:-2])
  if(Verbose) {print("Getting Bytes..."); print(x)}
  return( sum(nchar(x, type="bytes")) )
}


GetDim <- function(Input,Raw=TRUE) {
  #Infers, from the D.state ("decision space") the total size of this Markets.
  Dim <- unlist( lapply(Input$D.State,length) )
  if(Raw) Dim <- Dim + 1
  #each question corresponds to one partition of the space, thus for each dimension N questions yeilds N+1 states
  return(Dim)
}


GetSpace <- function(Market, Verbose=FALSE) {
  #Takes a Market, specifically its D.States, and constructs the array of possible ending states.
  Dim <- GetDim(Market)
  if(Verbose) { print(paste( "Market Dimention(s):", paste(Dim,collapse=",")))}
  
  Names <- vector('list',length=length(Dim))
  for(i in 1:length(Dim)) Names[[i]] <- paste("d",i,".",c("No",rep("Yes",Dim[i]-1)) ,sep="" )
  
  MaxN <- prod(Dim) #multiply dimensions to get total # of partitions 
  JSpace <- array(data=1:MaxN,dim=Dim,dimnames=Names)
  return(JSpace)
}


FillMarketInfo <- function(Ctr,B=1) {
  #Takes a basic, unfinished Market and fills out some details like the 'size', 'hash', etc. Also calulates the required seed capital for a given B level.
  #For security and simplicity the Market is hashed after the 'B' (and initial balance) are set. Then one only needs to verify that the balance was truly established.
  #Other fields, such as 'balance' and 'share', which would change constantly and rapidly, are calcualted from the base ("blank") Market.
  #Size is calculated second-to-last on the final Market to account for exponentially increasing Share space.
  CtrNew <- Ctr
  
  CtrNew$Shares <- 0*GetSpace(Ctr)

  #AMM seed capital requirement is given as b*log(N), where N is the number of states the Market must support.
  Nstates <- max(GetSpace(Ctr))
  CtrNew$Balance <- CtrNew$B*log(Nstates)
  
  CtrNew$Size <- GetSize(CtrNew)
  CtrNew$Market <- GetId(CtrNew)
  return(CtrNew)
}



## Sample Markets ##
C1 <- list(Market=NA,     #hash of c1[-1:-4]
           Size=NA,         #size of c1[-1:-2] in bytes 
           Shares=NA,       #initially, zero of course
           Balance=NA,      #funds in escrow for this Market
           FeeBalance=NA,   #Transaction Fees Collected
           State=-2,        # -2 indicates active (ie neither trading nor judging are finished).
           B=1,            #Liquidity Parameter
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",  #the Bitcoin address of the creator of this Market
           Title="Obama2012",                             #title - not necessarily unique
           Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
           #in practice, this will probably be pretty long.
           Tags=c("Politics, UnitedStates, President, Winner"), #ordinal descriptors
           EventOverBy=5,             #block number, corresponds to time that this information will be widely and readily availiable.     

           D.State=list(
             c("Did Barack H Obama win the United States 2012 presidential election?"))
           
)

C2 <- list(Market=NA,
           Size=NA,
           Shares=NA,
           Balance=NA,
           FeeBalance=NA,
           State=-2,
           B=2,
           OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           Title="Dems2016",                 
           Description="Democratic Control of the United States federal government following 2016 election.\nThis Market ...",
           Tags=c("Politics, UnitedStates, President, Congress"),
           EventOverBy=7,
           D.State=list(
             c("Did the Democratic Party Candidate win the United States presidential election in 2016?"),
             
             c("Did the Democratic Party win (only) a majority of Senate seats?",
               "Did the Democratic Party win (only) a three-fifths supermajority of Senate seats (60+)?",
               "Did the Democratic Party win a two-thirds supermajority of Senate seats (67+)?"),
             
             c("Did the Democratic Party win (only) a majority of House seats?",
               "Did the Democratic Party win a two-thirds supermajority of House seats (67+)?"))
           #option to also use (or always use) hash of an existing Conout
)

C1 <- FillMarketInfo(C1)
C2 <- FillMarketInfo(C2)


GetDecisionRows <- function(Market) {
  #Takes a Market and returns the set of Decisions that will need to be made
  #Build IDs for UJ
  Dim <- GetDim(Market,0)
  UJ_ID <- vector(length=0)
  
  for(i in 1:length(Dim)) UJ_ID <- c(UJ_ID, rep(i,Dim[i]) )

  Dvec <- (1:length(Dim))[UJ_ID] #Dimensions
  Svec <- unlist( lapply(X=GetDim(Market,0),FUN=function(x) 1:x) ) #State-dividers

  DfStates <- data.frame("IDc"=Market$Market,
                         "IDd"=Dvec,
                         "IDs"=Svec,
                         "T"=Market$EventOverBy,
                         "UJ"=unlist(Market$D.State),
                         "J"=.5)
  return(DfStates)
}

GetDecisionRows(C1)
GetDecisionRows(C2)

#Assume some results

Results <- GetDecisionRows(C2)
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

MapJudgement(Results,C2)



## Marketplace Creation ##
# - Where shares exist. (!) replace 'Markets' with Cmatrix eventually.
Markets <- vector("list",length=0) #Critical Step...creates (blank) marketplace. Would erase the existing marketplace if called twice.

CreateMarket <- function(Title,
                         B=1,
                         D.State=list(c("Did Barack H Obama win the United States 2012 presidential election?")), #Decisions
                         Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
                         Tags=c("Politics, UnitedStates, President, Winner"),
                         MatureTime=5,
                         OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh"
                         ) {
  
  #Create Object
  TempMarket <- list( Market=NA,Shares=NA,Balance=NA,FeeBalance=0,State=-2,B=B,Size=NA,OwnerAd=OwnerAd,Title=Title,
                       Description=Description,Tags=Tags,EventOverBy=MatureTime,D.State=D.State )
  
  #Prepare Object
  Temp2 <- FillMarketInfo(TempMarket)
           
  #Add a new Market to the global 'Markets' variable.
  #Use 'Title' for testing/understanding. I anticipate we will actually use the hash for uniqueness.  
  #Markets[[Temp2$Market]] <<- Temp2 
  Markets[[Temp2$Title]] <<- Temp2
}

CreateMarket("Obama2012")