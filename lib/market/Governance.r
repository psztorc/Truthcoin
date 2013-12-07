#Governance
rm(list=ls())
#Function Library
try(setwd("~/GitHub/Truthcoin/lib"))
source(file="market/Contracts.r")
Sha256 <- function(x) digest(unlist(x),algo='sha256',serialize=FALSE)

BlockZero <- list(
  "Bn"=1,                #Block Number
  "h.B_1"=Sha256(""),    #Hash of previous block
  "Time"=Sys.time(),     #System Date and Time
   "ListFee"=.01,        #Listing Fee - Fee to create a new contract and add a column to the V matrix. (selected to be nonzero but arbitrarily low - about 1 USD)
  "Cnew"=NULL,                                          #New Contracts (appends to C) ?
  "Cmatrix"=data.frame(C1,stringsAsFactors=FALSE)[-1,], #Matrix of Active Contracts (will eventually be stored somewhere else for non-redundancy)
  "Vmatrix"=matrix(0,nrow=6,ncol=0),                    #Matrix of 'Votes' ...extensive attention is given to this matrix with the 'Factory' function.
  "Jmatrix"=NULL,                                       #The contracts that, in this block, were ruled to have been decisivly judged (appends to H) ?
  "h.H_1"=Sha256("")                                    #Hash of the H matrix (the H matrix refers to the 'history' of contracts and their outcomes)
  )

#+nonce, merkle, Bitcoin fields, etc.


BlockChain <- list(BlockZero)

#Setup Complete

#Functions
AddContract <- function(CurChain,NewContract) {
  
  #Declare Working Variables
  Now <- length(CurChain)
  CurBlock.Old <- CurChain[[Now]]
  CurBlock.New <- CurBlock.Old
    
  #Add the contract to Cmatrix
  CurBlock.New$Cmatrix <- rbind(CurBlock.Old$Cmatrix,NewContract)
  
  #Assign Output - Replace
  NewChain <- CurChain
  NewChain[[Now]] <- CurBlock.New
  return(NewChain)                                   
}                          

Now <- length(BlockChain)
BlockChain[[Now]]$Cmatrix

BlockChain <- AddContract(BlockChain,C1)
BlockChain[[Now]]$Cmatrix

AdvanceChain <- function(BlockChain,VDuration=10) {
  
  #Add a new link to the chain.
  N <- length(BlockChain)
  Old <- BlockChain[[N]] #The most recent block
  New <- Old             #A copy of the most recent block.
  
  #add hash of previous block
  New$h.B_1  <- Sha256(Old)
  
  #if any contracts have matured in Cmatrix, add them to Vmatrix
  OpenContracts <- subset(New$Cmatrix,subset=EventOverBy==N,select=Title)[,1]  #gets the title of any contracts maturing today #! change to ID after validation
  Vn <- dim(New$Vmatrix)[1]
  Vm1 <- dim(New$Vmatrix)[2]
  Vm2 <- length(OpenContracts) 
  New$Vmatrix  <- matrix(data=    c(New$Vmatrix, rep(NA,Vn*Vm2)),
                         nrow=    Vn,
                         ncol=    (Vm1+Vm2),
                         dimnames=list(row.names(Old$Vmatrix), c(colnames(Old$Vmatrix),OpenContracts))
                         )
  New$Vmatrix
  
  #if any contracts have expired from Vmatrix, remove them from 
  ExpiredContracts <- subset(New$Cmatrix,subset=EventOverBy==(N+VDuration),select=Title)[,1] #gets the title of any contracts maturing today #! change to ID after validation
  New$Vmatrix <- New$Vmatrix[,(colnames(New$Vmatrix)!=ExpiredContracts)]
  
  Return <- c(BlockChain,New) 
  return(Return)
}





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


