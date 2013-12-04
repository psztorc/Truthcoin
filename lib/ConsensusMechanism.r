#Consensus Mechanism
#This is the mechanism that, theoretically,
 #   1] allows the software to determine the state of contracts truthfully, and
 #   2] only allows an efficient number of most-traded-upon-contracts.


#try(setwd("W:/VeteranCord/Documents/Decentralized Prediction Markets/Latest"))
#To my knowledge, R does not feature 'automatic working directories' uneless it is being run as a script

# #Function Library
source("CustomMath.r")


GetRewardWeights3 <- function(M,Rep=ReWeight(rep(1,nrow(M))),alpha=.1,Debug=0) {
  #Calculates the new reputations using WPCA

  #Rep=ReWeight(rep(1,nrow(M)))
  Results <- WeightedPrinComp(M,Rep)
  
  FirstLoading <- Results$Loadings #The first loading is designed to indicate which contracts were more 'agreed-upon' than others. 
  FirstScore   <- Results$Scores   #The scores show loadings on consensus (to what extent does this observation represent consensus?)
  
  #PCA, being an abstract factorization, is incapable of determining anything absolute.
  #Therefore the results of the entire procedure would theoretically be reversed if the average state of contracts changed from TRUE to FALSE.
  #Because the average state of contracts is a function both of randomness and the way the contracts are worded, I quickly check to see which
  #  of the two possible 'new' reputation vectors had more opinion in common with the original 'old' reputation.
  #  I originally tried doing this using math but after multiple failures I chose this ad hoc way.
  Set1 <-  FirstScore+abs(min(FirstScore))
  Set2 <-  FirstScore-max(FirstScore)   
  
  Old <- Rep%*%M
  
  New1 <- GetWeight(Set1%*%M)
  New2 <- GetWeight(Set2%*%M)
  
  #Difference in Sum of squared errors, if >0, then New1 had higher errors (use New2), and conversely if <0 use 1.
  RefInd <- sum( (New1-Old)^2) -  sum( (New2-Old)^2)
  
  if(RefInd<=0) AdjPrinComp <- Set1  
  if(RefInd>0)  AdjPrinComp <- Set2  
  
  #optionally print some variables 
  if(Debug==1) {
    print("FirstLoading")
    print(FirstLoading)
    print("FirstScore")
    print(FirstScore)
    print("RefInd")
    print(RefInd)
    print("AdjPrinComp - Adjusted to take into account the average reference point")
    print(AdjPrinComp)
  }

  #Declared here, filled below (unless there was a perfect consensus).
  RowRewardWeighted <- Rep # (set this to uniform if you want a passive diffusion toward equality when people cooperate [not sure you would])
  if(max(abs(AdjPrinComp))!=0) RowRewardWeighted <- GetWeight( (AdjPrinComp * Rep/mean(Rep)) ) #Overwrite the inital declaration IFF there wasn't perfect consensus.
  #note: Rep/mean(Rep) is a correction ensuring Reputation is additive. Therefore, nothing can be gained by splitting/combining Reputation into single/multiple accounts.
  
  
  #Freshly-Calculated Reward (Reputation) - Exponential Smoothing
  #New Reward: RowRewardWeighted
  #Old Reward: Rep
  SmoothedR <- alpha*(RowRewardWeighted) + (1-alpha)*Rep
  
  #Return Data
  Out <- list("FirstL"=FirstLoading,"OldRep"=Rep,"ThisRep"=RowRewardWeighted,"SmoothRep"=SmoothedR)  #Keep the factors and time information along for the ride, they are interesting.
  return(Out)
}

BuildConOut <- function(Mtemp=M1, Rep=ReWeight(rep(1,nrow(Mtemp))), Debug=1) {
  #Determines the outcomes of contracts based on the provided reputation (weighted vote)
  RewardWeightsNA <- Rep
  
  ConoutRAW  <- 1:ncol(Mtemp) #Declare this (filled below)
  for(i in 1:ncol(Mtemp)) {    
    #For each column:    
    Row <- ReWeight(RewardWeightsNA[!is.na(Mtemp[,i])]) #The Reputation of the row-players who DID provide judgements, rescaled to sum to 1.
    Col <- Mtemp[!is.na(Mtemp[,i]),i]                   #The relevant contract with NAs removed. ("What these row-players had to say about the contracts they DID judge.")
    
    ConoutRAW[i] <- Row%*%Col                           #Our Current best-guess for this contract (weighted average)  
  }
  
  #Output
  return(ConoutRAW)
}

FillNa <- function(Mna,Rep=ReWeight( rep(1,nrow(Mna)) ), CatchP=.1, Debug=0) { 
  #Uses exisiting data and reputations to fill missing observations.
  #Essentially a weighted average using all availiable non-NA data.
  #How much should slackers who arent voting suffer? I decided this would depend on the global percentage of slacking.
  
  #Count the missing observations (NA). We will need this information later.
  NAcontract <- apply(Mna,2,function(x) sum(is.na(x)) )
  NAvote <- apply(Mna,1,function(x) sum(is.na(x)) )

  Mnew <- Mna #Declare (in case no Missing values, Mnew and Mna will be the same)
  
  if(sum(NAcontract)>0) {
    #Of course, only do this process if there ARE missing values.
    
    #Contract Outcome - Our best guess for the contract state (FALSE=0, Ambiguous=.5, TRUE=1) so far (ie, using the present, non-missing, values).
    ConoutRAW <- BuildConOut(Mna,Rep,Debug)
    
    #Fill in the predictions to the original M
    NAmat <- is.na(Mna)   #The slice of the matrix which needs to be edited.
    Mna[NAmat] <- 0       #Erase the NA's
    
    if(Debug==1) {
      print("Original M")
      print(Mna)
      print(" ")
      print("NA matrix")
      print(NAmat)
      print(" ")
    }
    
    #Slightly complicated:
    NAsToFill <- ( NAmat%*%diag(as.vector(ConoutRAW)) )
    #   This builds a matrix whose columns j:
        #          NAmat was false (the observation wasn't missing)     ...  have a value of Zero
        #          NAmat was true (the observation was missing)         ...  have a value of the jth element of ConoutRAW (the 'current best guess') 
    Mnew <- Mna + NAsToFill
    #This replaces the NAs, which were zeros, with the predicted Contract outcome.
    
    
    #Print some items 
    if(Debug==1) {
      print("Creation of New Matrix")
      print("Added Part 1")
      #print(Mtemp)
      print(" ")
      print("Added Part 2")
      print(NAsToFill)
      print(" ")
      print("Result")
      print(Mnew) 
    }
  
  }
  
  #Appropriately force the predictions into their discrete (0,.5,1) slot. (continuous variables can be gamed).
  MnewC <- apply(Mnew, c(1,2), function(x) Catch(x,CatchP) )
  
  #Results
  Output <- vector("list")
  Output[[1]] <- MnewC
  Output[[2]] <- NAcontract
  Output[[3]] <- NAvote
  return(Output)
}

#Putting it all together:
Factory <- function(M0,Rep=NULL,CatchP=.1,MaxRow=5000,Debug=0) {
  #Main Routine
  #Fill the default reputations if none are provided
  if(is.null(Rep)) Rep <- ReWeight(rep(1,nrow(M0)))
  
#   TruncateMatrix
  
  INPUT2 <- FillNa(M0, Rep, CatchP=CatchP, Debug=0)
  #Pre-Analytics
   
  M <- INPUT2[[1]]
  NAcontract <- INPUT2[[2]]
  NArow <- INPUT2[[3]]  
  
  NAmat <- M0*0 
  NAmat[is.na(NAmat)] <- 1
  
  #NA importance = % of awnsers given as NA
  #Democratic: PercentNA  <- sum(NAcontract)/ (dim(M)[1]*dim(M)[2])  
  PercentNA  <- sum(NAcontract)/ (dim(M)[1]*dim(M)[2])  

  ## Consensus - Row Players 
  #New Consensus Reward
  PlayerInfo <- GetRewardWeights3(M=M,Rep,.1,Debug)
  AdjLoadings <- PlayerInfo$FirstL

  
  ##Column Players (The Contract Creators)
  #Calculation of Reward for Contract Authors
  # Consensus - "Who won?" Contract Outcome 
  ConoutRAW <- PlayerInfo$SmoothRep %*% M #Simple matrix multiplication ... highest information density at RowBonus, but need ConoutRAW to get to that
  # Quality of Outcomes - is there confusion?
  Certainty <- (2*(ConoutRAW-.5))**2      #all binary [ .5 is obviously undesireable ]
  ConReward <- GetWeight(ConoutRAW-.5)    #all binary [ .5 is obviously undesireable ]  
  ConoutFinal <- mapply(Catch,ConoutRAW,m=CatchP)  

    
  ## Participation
  #Row - Easier...we calculate the % of reputation that answered each contract
  ParticipationC <- 1-(PlayerInfo$SmoothRep%*%NAmat)
  #Column Harder...build a quadratic loss with 3 maxima (0,.5,1) and feed it ConoutRaw
  Coefs <- c(1,-12.907504,63.345748,-100.876487,50.438244)
  Map <- function(X)  ( Coefs[1] + Coefs[2]*(X**1) + Coefs[3]*(X**2) + Coefs[4]*(X**3) + Coefs[5]*(X**4) )
  Agreement <- Map(ConoutRAW)
  RelativeAgreement <- GetWeight(Agreement)
  ParticipationR <-  1-(NAmat%*%t(RelativeAgreement)) #1 - ( NAmat%*%t((1-Agreement)) )
  
  ## Calculate Player Scores
  #Row
  #NAbonusR <- GetWeight(NArow-max(NArow)) #Set most-missing player to zero and reweigh the rest. 
  NAbonusR <- GetWeight(ParticipationR)
  #Aggregation
  RowBonus <- (NAbonusR*(PercentNA))+(PlayerInfo$SmoothR*(1-PercentNA)) #aggregation of all supplied data...
  
  #Column
  #NAbonusC <- GetWeight(NAcontract-max(NAcontract))
  NAbonusC <- GetWeight(ParticipationC)
  #Aggregation
  ColBonus <- (NAbonusC*(PercentNA))+(ConReward*(1-PercentNA))  
  
  #Present Results
  Output <- vector("list",3) #Declare
  names(Output) <- c("Original","Agents","Contracts")
  Output[[1]] <- M0
  Output[[2]] <- cbind(PlayerInfo$OldRep, PlayerInfo$ThisRep,PlayerInfo$SmoothRep,NArow,ParticipationR,NAbonusR,RowBonus)
  colnames(Output[[2]]) <- c("OldRep", "ThisRep", "SmoothRep", "NArow", "ParticipationR","RelativePart","RowBonus") 
  
  Output[[3]] <- rbind(AdjLoadings,ConoutRAW,ConReward,Certainty,Agreement,RelativeAgreement,NAcontract,ParticipationC,ColBonus,ConoutFinal) # [2]
  rownames(Output[[3]]) <- c("First Loading","ConoutRAW","Consensus Reward","Certainty","Agreement","RelativeAg", "NAs Filled","ParticipationC","Contract Bonus","ConoutFinal") 
  return(Output)
}

#Long-Term
Chain <- function(X,N=2,ThisRep=NULL) {
  #Repeats factory process N times
  if(is.null(ThisRep)) ThisRep <- ReWeight(rep(1,nrow(X)))
  
  Output <- vector("list")
  for(i in 1:N) {
    Output[[i]] <- Factory(X,Rep=ThisRep)
    ThisRep <- Output[[i]]$Agents[,"RowBonus"]
  }
  
  return(Output)
}



# !!! Must FillNa with .5 FIRST, then average in, to prevent monopoly voting on brand-new contracts. (Actually, if it will eventually be ruled .5).

#Voting Across Time
#Later Votes should count more
#! ...simple change = ConoutFinal becomes exponentially smoothed result of previous chains.
#! require X number of chains (blocks) before the outcome is officially determined (two weeks?)

# Will need:
# 1] Percent Voted
# 2] Time Dimension of blocks.

#
# Possible solutions:
#   1 - sequential filling of NAs (sequential removal of columns) - pre-processing replace with average?
#   2 - what about the 'expert factor' idea? what happened to that?
#   3 - Completely replace FillNa with Reputations (lots of positives here)

#TO-DO
#Cascading reputation .6,.5,.3.,2., etc =   dexp(nrow(Mg))

#Mysterious behavior - loading only on first factor
#solutions
# 1- ignore. incentives will encourage filling out of contracts on 'obvious' events
# 2 - use later factors. Unknown what behavior could result from this
#Update 10.16.2013 This problem is now unreplicable...hopefully it was solved with RewardWeights3


#Steps

# [1] [CANCEL - BAD IDEA] Reward later factors (Comp.2, 3)? Seems risky...lets square the loadings or something to truly emphasize the first factor.
# [2] [DONE] Build R (reward matrix) as a proportion.
# [3] [DONE] What if the guy has no idea? NAs
# [4] [DONE] Fix 'perfect consensus' bug.
# [5] Reward function: a% of current reserve pool? [yes], payouts over time ? [this is whats happening, not finished yet]
# [6] Scale Cost By Funds availiable [????]
# [7] Add payment functionality (pay-per-vote)
# [8] Functionality for new arrivals..old contracts missing data.
# [9] [DONE] Remove incentive to create contracts where consensus is @.5 !
# [10.a] [DONE] Univariate fill missing data in an incentive-consistent way.
# [10.b] [part-DONE] Multivariate fill missing data (recursive? bootstrapped?) [chose simultaneous prediction, and ignore]
# [10.c  - FillNa should faithfully reproduce .5s] 

# [adding a NA to a contract can wipe out the validations there, ONLY when filling NA, - fix by using exponential smoothing to calc Rewards] [Fixed!]
# [11] Ask - Ask people the outcomes of contracts...how to maximize (contract reward? d(Cr)?)

#

# [20 - Discourage "Obvious Outcome" Contracts by fee-for-open-interest (more disagreement)]

### 



# #This functionality can be gamed and is scrapped:
# Ask <- function(M, p=.2, epsilon=.001) {
#   
#   #M is the target matrix, r the random variable assigned to a player
#   #p is the weight given to NAs versus disputed outcomes
#   #epsilon is the weight given to otherwise weightless contracts.
#   
#   Weight1 <- GetWeight( (Factory(M)[[2]][nrow(M)+4,]) + epsilon)  #Na Weight
#   Weight2 <- Factory(M)[[2]][nrow(M)+2,]                          #Contract Reward weight
#   Weight2 <- GetWeight( ((.25)-(Weight2-.5)^2) + epsilon)         #Transformation to find low-weighted 
#   
#   WeightC <- p*Weight1 + (1-p)*Weight2
#   ConCol <- sample(1:ncol(M),1,prob=WeightC)            
#   
#   #print(WeightC)
#   
#   return(ConCol)
# }
# 
# Ask(M1)
# 
# temp <- unlist(lapply(1:100,FUN=function(x) Ask(M10a)))
# hist(temp)

# [12] Create a New contract...it should cost(?)


# [11] [Done] Ask
# [12] NewContract
# [13] Open Interest - Two disagreeing parties each pay Ai (i in 1,2 ; Sum(A)=1) to mint two new coins -- eventually redeemable for 0 and 1-FEEepsilon .

# [14] Subsidized Events - Principals paying Agents to influence the outcome of contracts.


# [14a] A market for an event will allow it's occurance to be noted by the Factory after it's occurance.
# [14b] Partition a 'Verification Space' (private information known only to the agent: date, time, colour, etc).
# [14c] Allow private bets within the Verification Space - possibly a second set of Colored Coins "specical coin".
# [14d] At EoC, people collect proportional to their holdings of insider-information coins.
# [14e] Assurance contracts to allow anyone to fund a 'club good' event.



