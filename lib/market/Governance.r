#Governance
rm(list=ls())
#Function Library
try(setwd("~/GitHub/Truthcoin/lib"))
source(file="market/Contracts.r")
Sha256 <- function(x) digest(unlist(x),algo='sha256',serialize=FALSE)

GenesisBlock <- list(
  "Bn"=1,               #Block Number
  "h.B_1"=Sha256(""),   #Hash of previous block
  "Time"=Sys.time(),    #System Date and Time
  "ListFee"=.01,        #Listing Fee - Fee to create a new contract and add a column to the V matrix. (selected to be nonzero but arbitrarily low - about 1 USD)
  "Cnew"=NULL,                                          #New Contracts (appends to C) ?
  "Cmatrix"=data.frame(                                 #Matrix of Active Contracts (stores only the essential information).
    "Contract"='a',
    "Matures"=1)[-1,], 
  "Vmatrix"=matrix(0,nrow=6,ncol=0,dimnames=(           #Matrix of 'Votes' ...extensive attention is given to this matrix with the 'Factory' function.
    list(paste("Voter",1:6,sep=".")) #(fake names, will be Truthcoin Addresses)
    )),        
  "Jmatrix"=NULL,                                       #The contracts that, in this block, were ruled to have been decisivly judged (appends to H) ?
  "h.H_1"=Sha256(""),                                   #Hash of the H matrix (the H matrix refers to the 'history' of contracts and their outcomes)
  "Nonce"=1
  )

#+nonce, merkle, Bitcoin fields, etc.
BlockChain <- list(GenesisBlock)
#Setup Complete


## Functions Involving BlockChain Information ##

QueryAddContract <- function(NewContract,CurChain=BlockChain) {
  
  Now <- length(CurChain)
  CurFee <- CurChain[[Now]]$ListFee
  
  Out <- list("CurrentListFee"=CurFee,
              "D"=sum(GetDim(NewContract,0)),  #Total number of decisions that must be made.
              "S"=prod(GetDim(NewContract)),   #Size of the trading space.
              "Cost"=sum(GetDim(NewContract,0)) * CurFee #Cost to list this contract.
              )
  return(Out)
}

AddContract <- function(NewContract,CurChain=BlockChain,PaymentTransaction=0) {
  
  #Verify Payment
  Cost <- QueryAddContract(NewContract,CurChain)$Cost
  #Payment <- LookUpPayment(PaymentTransaction)
  #if(Payment<Cost) return("Payment Error")

  #Declare Working Variables
  Now <- length(CurChain)
  CurBlock.Old <- CurChain[[Now]]
  CurBlock.New <- CurBlock.Old
  
  #Format the Contract's Decision-States as rows
  C.Filled <- FillContract(NewContract)
  if( !all.equal(C.Filled, FillContract(C.Filled)) ) { # Sanity Check
    print("Contract Error")
    return(all.equal(C.Filled, FillContract(C.Filled)))  
  }
  
  UJRows <- GetUJRows(C.Filled) #The 'Unjudged' that need to be added as rows.
  UJRows.Cformat <- data.frame("Contract"=paste("C",UJRows[,2],UJRows[,3],UJRows[,1], sep="."), #in the format for adding to Cmatrix
                               "Maturity"=UJRows[,4])
  #Add the contract to Cmatrix
  CurBlock.New$Cmatrix <- rbind(CurBlock.Old$Cmatrix,UJRows.Cformat)
  
  #Assign Output - Replace
  NewChain <- CurChain
  NewChain[[Now]] <- CurBlock.New
  return(NewChain)                                   
}            

QueryAddContract(C2)
BlockChain <- AddContract(C2)


AdvanceChain <- function(BlockChain,VDuration=10) {
    
  #Add a new link to the chain.
  Now <- length(BlockChain)
  Old <- BlockChain[[Now]] #The most recent block
  New <- Old             #A copy of the most recent block.
  
  #add hash of previous block
  New$h.B_1  <- Sha256(Old)
  
  #if any contracts have matured in Cmatrix, add them to Vmatrix
  OpenContracts <- New$Cmatrix[New$Cmatrix$Maturity==Now,1]  #gets the ID of any contracts maturing today #! change to ID after validation
  Vm1 <- length(OpenContracts)
  if(Vm1>0) {
    Vn <- dim(New$Vmatrix)[1]
    Vm2 <- dim(New$Vmatrix)[2]
    
    New$Vmatrix  <- matrix(data=    c(New$Vmatrix, rep(NA,Vn*Vm1)),
                           nrow=    Vn,
                           ncol=    (Vm2+Vm1),
                           dimnames=list(row.names(Old$Vmatrix), c(colnames(Old$Vmatrix),OpenContracts)) ) 
  }
  New$Vmatrix

  #if any contracts have expired from Vmatrix, remove them from Vmatrix
  ExpiredContracts <- New$Cmatrix[New$Cmatrix$Maturity==(Now-VDuration),1]  #gets the ID of any contracts maturing today #! change to ID after validation
  if(length(ExpiredContracts)>0) {
    New$Vmatrix <- New$Vmatrix[,(colnames(New$Vmatrix)!=ExpiredContracts)]
  }
  New$Vmatrix
  
  Out <- c(BlockChain,New) 
  return(Out)
}


#Find next block


#requires:
#hash of previous block (previous block)
#previous Vmatrix
#previous Fee







# 
# 
# #Get Labels
# OldNames <- colnames(CurBlock.Old$Vmatrix)
# NewNames <- c(OldNames, NewContract$Title)
# print(OldNames)
# print(NewNames)
# 
# 
# #Add the contract to Vmatrix
# CurBlock.New$Vmatrix <- cbind(CurBlock.Old$Vmatrix,NA)
# print(CurBlock.New$Vmatrix)
# colnames(CurBlock.New$Vmatrix) <- NewNames


