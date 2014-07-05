#Governance
rm(list=ls())
#Function Library
tryCatch(expr=setwd("~/GitHub/Truthcoin/lib"), error=function(e) setwd(choose.dir(caption="Failed to set working directory automatically. Choose 'lib' folder:")) )
source(file="market/Markets.r")
source(file="consensus/ConsensusMechanism.r")
Sha256 <- function(x) digest(unlist(x),algo='sha256',serialize=FALSE)

GenesisBlock <- list(
  "Bn"=1,               #Block Number
  
  "h.B.1"=Sha256(""),   #Hash of previous block
  
  "Time"=Sys.time(),    #System Date and Time
  
  "ListFee"=.001,       #Listing Fee - Fee to create a new Market and add a column to the V matrix. (selected to be nonzero but arbitrarily low - about 1 USD)
  
  "ListFee2"=log(8)/(8^2),                              #Second listing fee...even smaller, designed to lightly discourage low-k, high-n Markets with more than N=256 states. st f1(x) = a(x^2) = f2(x) = b (log(x)) @ x=8 
  
  "Cnew"=NULL,                                          #New Markets (appends to C) ?
  
  "Cmatrix"=data.frame(                                 #Matrix of Active Markets (stores only the essential information).
    "Market"='a',
    "Matures"=1)[-1,], 
  
  "Vmatrix"=matrix(0,nrow=6,ncol=0,dimnames=(           #Matrix of 'Votes' ...extensive attention is given to this matrix with the 'Factory' function.
    list(paste("Voter",1:6,sep="."))                    #(fake names, will be Truthcoin Addresses)
    )),
  
  "Reputation"=c(.3,.2,.15,.15,.1,.1),   #Reputation
  
  "Jmatrix"=data.frame("Market"='a',"State"=1)[-1,],  #The Markets that, in this block, were ruled to have been decisivly judged (appends to H) ?
              
  "h.H.1"=Sha256(""),             #Hash of the H matrix (the H matrix refers to the 'history' of Markets and their outcomes)
  
  "Nonce"=1
  )

#+nonce, merkle, Bitcoin fields, etc.
BlockChain <- list(NA,GenesisBlock)
#Setup Complete


## Functions Involving BlockChain Information ##

QueryAddMarket <- function(NewMarket,CurChain=BlockChain) {
  
  Now <- length(CurChain)
  CurDecFee <- CurChain[[Now]]$ListFee    #get parameters for this block
  CurStateFee <- CurChain[[Now]]$ListFee2 #get parameters for this block
  
  D.calc <- sum(GetDim(NewMarket,0))  #Total number of decisions that must be made.
  S.calc <- prod(GetDim(NewMarket))   #Size of the trading space.
  
  Seed.Capital <- NewMarket$B*log(S.calc)
  
  Out <- list("MarketMake"=Seed.Capital,
              "CurrentDecisionFee"=CurDecFee,
              "D"=D.calc, 
              "D.cost"= D.calc*CurDecFee,
              "CurrentStateFee"=CurStateFee,
              "S"=S.calc, 
              "S.cost"=  (S.calc^2) * CurStateFee,              
              "TotalCost"= Seed.Capital + (D.calc * CurDecFee) + ((S.calc^2) * CurStateFee)  #Cost to list this Market.
              )
  return(Out)
}

QueryAddMarket(C1)
QueryAddMarket(C2)

AddMarket <- function(NewMarket,CurChain=BlockChain,PaymentTransaction=0) {
  
  #Verify Payment
  Cost <- QueryAddMarket(NewMarket,CurChain)$TotalCost
  #Payment <- LookUpPayment(PaymentTransaction)
  #if(Payment<Cost) return("Payment Error")

  #Declare Working Variables
  Now <- length(CurChain)
  CurBlock.Old <- CurChain[[Now]]
  CurBlock.New <- CurBlock.Old
  
  #Format the Market's Decision-States as rows
  C.Filled <- FillMarketInfo(NewMarket)
  if( !all.equal(C.Filled, FillMarketInfo(C.Filled)) ) { # Sanity Check
    print("Market Error")
    return(all.equal(C.Filled, FillMarketInfo(C.Filled)))  
  }
  
  UJRows <- GetUJRows(C.Filled) #The 'Unjudged' that need to be added as rows.
  UJRows.Cformat <- data.frame("Market"=paste("C",UJRows[,2],UJRows[,3],UJRows[,1], sep="."), #in the format for adding to Cmatrix
                               "Maturity"=UJRows[,4])
  #Add the Market to Cmatrix
  CurBlock.New$Cmatrix <- rbind(CurBlock.Old$Cmatrix,UJRows.Cformat)
  
  #Assign Output - Replace
  NewChain <- CurChain
  NewChain[[Now]] <- CurBlock.New
  return(NewChain)                                   
}            

AdvanceChain <- function(VDuration=10) {
 
  #Add a new link to the chain.
  Now <- length(BlockChain)
  Old <- BlockChain[[Now]] #The most recent block
  New <- Old               #A copy of the most recent block.
  
  #Add hash of previous block
  New$h.B.1  <- Sha256(Old)
  #Add the current time
  New$Time <- Sys.time()
  
  ## Construct a Vote every X=10 rounds (if there are Markets waiting) ##
  if(Now%%VDuration==0&length(Old$Vmatrix)>0) {
    
    #Use our big function
    Results <- Factory(Old$Vmatrix,Rep=Old$Reputation)
    
    #Set Reputations
    New$Reputation <- Results$Agents[,"RowBonus"]
    
    #Adjust Entry/Authorship Fee - based on voter turnout
    Participation.Target <- .90
    Participation.Actual <- Results$Participation
    New$ListFee <- Old$ListFee* (Participation.Target/Participation.Actual)
    
    #Set Market State using DecisionOutcome.Final
    MarketOutcomes <- Results$Decisions["DecisionOutcome.Final",]
    PreReformat <- unlist(strsplit(names(MarketOutcomes),split=".",fixed=TRUE))
    MaxX <- length(names(MarketOutcomes))*4    # (4 fields)
    
    Reformat <- data.frame( "IDc"=             PreReformat[1:MaxX%%4==0],
                            "IDd"= as.numeric( PreReformat[1:MaxX%%4==2] ), #lost the numeric formating in strsplit
                            "IDs"= as.numeric( PreReformat[1:MaxX%%4==3] ),
                             "J"= MarketOutcomes)
    
    #Market undecided - kick out to -1  ("Market is permanently unresolveable")
    if(sum(Results$J==.5)>0) return(-1)  #It is possible to improve this through some kind of marginal space.
    
    for(k in unique(Reformat$IDc)) {
      Temp <- Reformat[Reformat$IDc==k,]  #Subset
      
      # "GetDim" lite - Take list of decisions and return vector of dimensions, Question x State
      C.Dim <- vector("numeric",length=max(Temp$IDd))
      for(j in 1:max(Temp$IDd)) C.Dim[j] <- max(Temp[Temp$IDd==j,"IDs"]) + 1
      
      # 'GetSpace' lite - Take Dimensions and return the 'State Array' of all possible states.
      MaxN <- prod(C.Dim) #multiply dimensions to get total # of partitions
      Names <- vector('list',length=length(C.Dim))
      for(i in 1:length(C.Dim)) Names[[i]] <- paste("d",i,".",c("No",rep("Yes",C.Dim[i]-1)) ,sep="" )
      JSpace <- array(data=1:MaxN,dim=C.Dim,dimnames=Names)
      
      # 'Format' lite - Take Judgements from Consensus and use them to navigate to the correct state.
      Temp$T <- Temp$IDs*Temp$J + 1  # +1 for index.. R does not count from zero
      PreState <- 1:length(C.Dim)                #For each dimension of the Market
      for(i in 1:length(PreState)) PreState[i] <- max(Temp$T[Temp$IDd==i])  #Find the maximum value within dimension (assumes Markets have been ordered)
      JState <- JSpace[PreState[1],PreState[2],PreState[3]]
      
      print(paste("Market",k,"ended in State",JState,"."))
      
      #Publish Result
      New$Jmatrix <- rbind(New$Jmatrix,data.frame("Market"=k, "State"=JState))  
    }    
    
  }  
  
  #if any Markets have matured in Cmatrix, add them to Vmatrix
  OpenMarkets <- New$Cmatrix[New$Cmatrix$Maturity==Now,1]  #gets the ID of any Markets maturing today #! change to ID after validation
  Vm1 <- length(OpenMarkets)
  if(Vm1>0) {
    Vn <- dim(New$Vmatrix)[1]
    Vm2 <- dim(New$Vmatrix)[2]
    
    New$Vmatrix  <- matrix(data=    c(New$Vmatrix, rep(NA,Vn*Vm1)),
                           nrow=    Vn,
                           ncol=    (Vm2+Vm1),
                           dimnames=list(row.names(Old$Vmatrix), c(colnames(Old$Vmatrix),OpenMarkets)) ) 
    print(paste("Added",Vm1,"rows to the Vmatrix."))
    print(New$Vmatrix)
  }
  
  #if any Markets have expired from Vmatrix, remove them from Vmatrix
  ExpiredMarkets <- New$Cmatrix[New$Cmatrix$Maturity==(Now-VDuration),1]  #gets the ID of any Markets maturing today #! change to ID after validation
  if(length(ExpiredMarkets)>0) {
    New$Vmatrix <- New$Vmatrix[,(colnames(New$Vmatrix)!=ExpiredMarkets)]
    print(paste("Removed",length(ExpiredMarkets),"rows from the Vmatrix."))
    print(New$Vmatrix)
  }
  

  
  BlockChain[[(Now+1)]] <<- New
}

FastForward <- function(Times=2) {
  for(i in 1:Times) AdvanceChain()
}

BlockChain

QueryAddMarket(C2)
BlockChain <- AddMarket(C2)

BlockChain

AdvanceChain()

BlockChain

FastForward(5)

BlockChain[[length(BlockChain)]]

SetVote <- function(Row,Column,Vote) {
  #Eventually this will require Message Signing, of course.
  try( BlockChain[[length(BlockChain)]]$Vmatrix[Row,Column] <<- Vote )
}

SetVote("Voter.1","C.1.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.2","C.1.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.3","C.1.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.4","C.1.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.5","C.1.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.6","C.1.1.5fa52bc3609598e28214d0e8ba47eca4",1)

SetVote("Voter.1","C.2.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.2","C.2.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.3","C.2.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.4","C.2.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.5","C.2.1.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.6","C.2.1.5fa52bc3609598e28214d0e8ba47eca4",1)

SetVote("Voter.1","C.2.2.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.2","C.2.2.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.3","C.2.2.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.4","C.2.2.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.5","C.2.2.5fa52bc3609598e28214d0e8ba47eca4",1)
SetVote("Voter.6","C.2.2.5fa52bc3609598e28214d0e8ba47eca4",1)

SetVote("Voter.1","C.2.3.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.2","C.2.3.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.3","C.2.3.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.4","C.2.3.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.5","C.2.3.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.6","C.2.3.5fa52bc3609598e28214d0e8ba47eca4",0)

SetVote("Voter.1","C.3.1.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.2","C.3.1.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.3","C.3.1.5fa52bc3609598e28214d0e8ba47eca4",0)

SetVote("Voter.4","C.3.2.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.5","C.3.2.5fa52bc3609598e28214d0e8ba47eca4",0)
SetVote("Voter.6","C.3.2.5fa52bc3609598e28214d0e8ba47eca4",0)

AdvanceChain()