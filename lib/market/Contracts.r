
### Contract Structure/Example ###

#Load
Use <- function(package) { if(suppressWarnings(!require(package,character.only=TRUE))) install.packages(package,repos="http://cran.case.edu/") ; require(package,character.only=TRUE) }
options(stringsAsFactors = FALSE)
Use('digest')


## Functions to Define/Set Attributes of Contracts
LongForm <- function(Ctr) return(unlist(Ctr))
#unlists the info - easier to hash (convienience only)

GetId <- function(CtrBlank,debug=0) {
  # md5 hashes the contract, ignoring the hash field for reproduceability, and the shares/balance fields for consistency.
  x <- LongForm(CtrBlank[-1:-4])
  if(debug==1) print(x)
  return( digest(x,"md5") )
}


GetSize<- function(CtrBlank,debug=0) {
  #Size of the contract in bytes. As only the contract's hash is required, and judges have an incentive to punish incoherent contracts, I dont think there is a need for this anymore, but perhaps it will still be useful.
  x <- deparse(CtrBlank)
  if(debug==1) print(x)
  return( sum(nchar(x, type="bytes")) )
}


GetDim <- function(Input,Raw=TRUE) {
  #Infers, from the D.state ("decision space") the total size of this contracts.
  Dim <- unlist( lapply(Input$D.State,length) )
  if(Raw) Dim <- Dim + 1
  #each question corresponds to one partition of the space, thus for each dimension N questions yeilds N+1 states
  return(Dim)
}


GetSpace <- function(Contract) {
  #Takes a contract, specifically its D.States, and constructs the array of possible ending states.
  Dim <- GetDim(Contract)
  MaxN <- prod(Dim) #multiply dimensions to get total # of partitions
  Names <- vector('list',length=length(Dim))
  for(i in 1:length(Dim)) Names[[i]] <- paste("d",i,".",c("No",rep("Yes",Dim[i]-1)) ,sep="" )
  JSpace <- array(data=1:MaxN,dim=Dim,dimnames=Names)
  return(JSpace)
}


FillContract <- function(Ctr,B=1) {
  #Takes a basic, unfinished contract and fills out some details like the 'size', 'hash', etc. Also calulates the required seed capital for a given B level.
  #For security and simplicity the contract is hashed after the 'B' (and initial balance) are set. Then one only needs to verify that the balance was truly established.
  #All other fields, such as 'size' and 'balance', are calculated from the basic contract, as are fields such as 'shares' which would change constantly and rapidly.
  CtrNew <- Ctr
  
  CtrNew$Shares <- 0*GetSpace(Ctr)
  CtrNew$Size <- GetSize(Ctr)
  
  #AMM seed capital requirement is given as b*log(N), where N is the number of states the contract must support.
  Nstates <- max(GetSpace(Ctr))
  CtrNew$Balance <- CtrNew$B*log(Nstates)
  
  CtrNew$Contract <- GetId(CtrNew)
  return(CtrNew)
}



## Sample Contracts ##
C1 <- list(Contract=NA,     #hash of c1[-1:-4]
           Shares=NA,       #initially, zero of course
           Balance=NA,      #funds in escrow for this contract
           State=-2,        # -2 indicates active (ie neither trading nor judging are finished).
           B=NA,            #Liquidity Parameter
           Size=NA,         #size of c1[-1:-4] in bytes 
           OwnerAd="1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T",  #the Bitcoin address of the creator of this contract
           Title="Obama2012",                             #title - not necessarily unique
           Description="Barack Obama to win United States President in 2012\nThis contract will expire in state 1 if the statement is true and 0 otherwise.",
           #in practice, this will probably be pretty long.
           Tags=c("Politics, UnitedStates, President, Winner"), #ordinal descriptors
           EventOverBy=5,             #block number, corresponds to time that this information will be widely and readily availiable.     

           D.State=list(
             c("Did Barack H Obama win the United States 2012 presidential election?"))
           
)

C2 <- list(Contract=NA,
           Shares=NA,
           Balance=NA,
           State=-2,
           B=NA,
           Size=NA,
           OwnerAd="1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T",
           Title="Dems2016",                 
           Description="Democratic Control of the United States federal government following 2016 election.\nThis contract ...",
           Tags=c("Politics, UnitedStates, President, Congress"),
           EventOverBy=5,
           D.State=list(
             c("Did the Democratic Party Candidate win the United States presidential election in 2016?"),
             
             c("Did the Democratic Party win (only) a majority of Senate seats?",
               "Did the Democratic Party win (only) a three-fifths supermajority of Senate seats (60+)?",
               "Did the Democratic Party win a two-thirds supermajority of Senate seats (67+)?"),
             
             c("Did the Democratic Party win (only) a majority of House seats?",
               "Did the Democratic Party win a two-thirds supermajority of House seats (67+)?"))
           #option to also use (or always use) hash of an existing Conout
)

C1 <- FillContract(C1)
C2 <- FillContract(C2)


GetUJRows <- function(Contract) {
  #Takes a contract and returns the set of judgements that will need to be made
  #Build IDs for UJ
  Dim <- GetDim(Contract,0)
  UJ_ID <- vector(length=0)
  
  for(i in 1:length(Dim)) UJ_ID <- c(UJ_ID, rep(i,Dim[i]) )

  Dvec <- (1:length(Dim))[UJ_ID]
  Svec <- unlist( lapply(X=GetDim(Contract,0),FUN=function(x) 1:x) )

  DfStates <- data.frame("IDc"=Contract$Contract,
                         "IDd"=Dvec,
                         "IDs"=Svec,
                         "UJ"=unlist(Contract$D.State),
                         "J"=.5)
  return(DfStates)
}

GetUJRows(C1)
GetUJRows(C2)

#Assume some results

Results <- GetUJRows(C2)
Results$J <- c(0,0,0,0,0,1)
Results

MapJudgement <- function(Results,Contract) {
  
  #Filter on correct contract.
  # (hasnt been done yet)
  
  #Contract undecided - kick out to -1
  if(sum(Results$J==.5)>0) return(-2)
  
  #Decided Contracts ...traverse the OutComeSpace
  Results$T <- Results$IDs*Results$J + 1  # +1 for index.. R does not count from zero
  PreState <- 1:length(GetDim(Contract))
  for(i in 1:length(PreState)) PreState[i] <- max(Results$T[Results$IDd==i])
  
  State <- GetSpace(Contract)[PreState[1],PreState[2],PreState[3]]
  return(State)
  
}

MapJudgement(Results,C2)



## Marketplace Creation ##
# - Where shares exist. (!) replace 'Markets' with Cmatrix eventually.
Markets <- vector("list",length=0) #Critical Step...creates (blank) marketplace. Would erase the existing marketplace if called twice.

CreateMarket <- function(Title,
                         B=1,
                         D.State=list(c("Did Barack H Obama win the United States 2012 presidential election?")),
                         Description="Barack Obama to win United States President in 2012\nThis contract will expire in state 1 if the statement is true and 0 otherwise.",
                         Tags=c("Politics, UnitedStates, President, Winner"),
                         MatureTime=5,
                         OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh"
                         ) {
  
  #Create Object
  TempContract <- list( Contract=NA,Shares=NA,Balance=NA,State=-2,B=B,Size=NA,OwnerAd=OwnerAd,Title=Title,
                       Description=Description,Tags=Tags,EventOverBy=MatureTime,D.State=D.State )
  
  #Prepare Object
  Temp2 <- FillContract(TempContract)
           
  #Add a new contract to the global 'Markets' variable.
  #Use 'Title' for testing/understanding. I anticipate we will actually use the hash for uniqueness.  
  #Markets[[Temp2$Contract]] <<- Temp2 
  Markets[[Temp2$Title]] <<- Temp2
}

CreateMarket("Obama2012")