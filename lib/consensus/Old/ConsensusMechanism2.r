#Consensus Mechanism
#This is the mechanism that, theoretically,
 #   1] allows the software to determine the state of Decisions truthfully, and
 #   2] only allows an efficient number of most-traded-upon-Decisions.


try(setwd("~/GitHub/Truthcoin/lib"))
#To my knowledge, R does not feature 'automatic working directories' uneless it is being run as a script

source("consensus/CustomMath2.r")

AsMatrix <- function(Vec) return(matrix(Vec,nrow=length(Vec)))

# #Function Library
GetRewardWeights <- function(M,Rep=NULL,alpha=.1,Verbose=FALSE) {
  #Calculates the new reputations using WPCA
  
  if(is.null(Rep)) { Rep <- ReWeight(rep(1,nrow(M)))  ;   if(Verbose) print("Reputation not provided...assuming equal influence.")  }
  
  if(Verbose) {
    print("****************************************************")
    print("Begin 'GetRewardWeights'")
    print("Inputs...")
    print("Matrix:")
    print(M)
    print("")
    print("Reputation:")
    print(AsMatrix(Rep))
    print("")
  }

  #Rep=ReWeight(rep(1,nrow(M)))
  Results <- WeightedPrinComp(M,Rep)
  
  
  FirstLoading <- Results$Loadings #The first loading is designed to indicate which Decisions were more 'agreed-upon' than others. 
  FirstScore   <- Results$Scores   #The scores show loadings on consensus (to what extent does this observation represent consensus?)
  
  if(Verbose) { print("First Loading:"); print(FirstLoading); print("First Score:"); print(AsMatrix(FirstScore)) }
  
  #PCA, being an abstract factorization, is incapable of determining anything absolute.
  #Therefore the results of the entire procedure would theoretically be reversed if the average state of Decisions changed from TRUE to FALSE.
  #Because the average state of Decisions is a function both of randomness and the way the Decisions are worded, I quickly check to see which
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
  
  if(Verbose) {
    print("")
    print("Estimations using: Previous Rep, Option 1, Option 2")
    print( cbind( AsMatrix(Old), AsMatrix(New1), AsMatrix(New2) ) )
    print("")
    print("Previous period reputations, Option 1, Option 2, Selection")
    print( cbind( AsMatrix(Rep), AsMatrix(Set1), AsMatrix(Set2), AsMatrix(AdjPrinComp) ) )
  }
  
  #Declared here, filled below (unless there was a perfect consensus).
  RowRewardWeighted <- Rep # (set this to uniform if you want a passive diffusion toward equality when people cooperate [not sure why you would]). Instead diffuses towards previous reputation (Smoothing does this anyway).
  if(max(abs(AdjPrinComp))!=0) RowRewardWeighted <- GetWeight( (AdjPrinComp * Rep/mean(Rep)) ) #Overwrite the inital declaration IFF there wasn't perfect consensus.
  #note: Rep/mean(Rep) is a correction ensuring Reputation is additive. Therefore, nothing can be gained by splitting/combining Reputation into single/multiple accounts.
  
  
  #Freshly-Calculated Reward (Reputation) - Exponential Smoothing
  #New Reward: RowRewardWeighted
  #Old Reward: Rep
  SmoothedR <- alpha*(RowRewardWeighted) + (1-alpha)*Rep
  
  if(Verbose) {
    print("")
    print("Corrected for Additivity , Smoothed _1 period")
    print( cbind( AsMatrix(RowRewardWeighted), AsMatrix(SmoothedR)) )
  }
  
  #Return Data
  Out <- list("FirstL"=FirstLoading,"OldRep"=Rep,"ThisRep"=RowRewardWeighted,"SmoothRep"=SmoothedR)  #Keep the factors and time information along for the ride, they are interesting.
  return(Out)
}

GetDecisionOutcomes <- function(Mtemp, Rep, ScaledIndex, Verbose=FALSE) {
  #Determines the Outcomes of Decisions based on the provided reputation (weighted vote)
  
  if(missing(Rep)) { Rep <- ReWeight(rep(1,nrow(Mtemp)))  ;   if(Verbose) print("Reputation not provided...assuming equal influence.")  }
  
  if(Verbose) { print("****************************************************") ; print("Begin 'GetDecisionOutcomes'")}
  
  RewardWeightsNA <- Rep
  
  DecisionOutcomes.Raw  <- 1:ncol(Mtemp) #Declare this (filled below)
  
  for(i in 1:ncol(Mtemp)) {    
    #For each column:    
    Row <- ReWeight(RewardWeightsNA[!is.na(Mtemp[,i])]) #The Reputation of the row-players who DID provide judgements, rescaled to sum to 1.
    Col <- Mtemp[!is.na(Mtemp[,i]),i]                   #The relevant Decision with NAs removed. ("What these row-players had to say about the Decisions they DID judge.")
    
    #Discriminate Based on Contract Type
    if(!ScaledIndex[i]) DecisionOutcomes.Raw[i] <- Row%*%Col                     #Our Current best-guess for this Binary Decision (weighted average) 
    if(ScaledIndex[i]) DecisionOutcomes.Raw[i] <- weighted.median(w=Row, x=Col)  #Our Current best-guess for this Scaled Decision (weighted median)
   
    if(Verbose) { print("** **"); print("Column:"); print(i); print(AsMatrix(Row)); print(Col); print("Consensus:"); print(DecisionOutcomes.Raw[i])}
  }
  
  #Output
  return(DecisionOutcomes.Raw)
}

FillNa <- function(Mna, Rep, ScaledIndex, CatchP=.1, Verbose=FALSE) { 
  #Uses exisiting data and reputations to fill missing observations.
  #Essentially a weighted average using all availiable non-NA data.
  #How much should slackers who arent voting suffer? I decided this would depend on the global percentage of slacking.
  
  if(missing(Rep)) { Rep <- ReWeight(rep(1,nrow(Mna)))  ;   if(Verbose) print("Reputation not provided...assuming equal influence.")  }
  
  Mnew <- Mna #Declare (in case no Missing values, Mnew, MnewC, and Mna will be the same)
  MnewC <- Mna
  
  if(sum(is.na(Mna))>0) {
    #Of course, only do this process if there ARE missing values.
    
    if(Verbose) print("Missing Values Detected. Beginning presolve using availiable values.")
    
    #Decision Outcome - Our best guess for the Decision state (FALSE=0, Ambiguous=.5, TRUE=1) so far (ie, using the present, non-missing, values).
    DecisionOutcomes.Raw <- GetDecisionOutcomes(Mna,Rep,ScaledIndex,Verbose)
    
    #Fill in the predictions to the original M
    NAmat <- is.na(Mna)   #Defines the slice of the matrix which needs to be edited.
    Mnew[NAmat] <- 0       #Erase the NA's
       
    #Slightly complicated:
    NAsToFill <- ( NAmat%*%diag(as.vector(DecisionOutcomes.Raw)) )
    #   This builds a matrix whose columns j:
        #          NAmat was false (the observation wasn't missing)     ...  have a value of Zero
        #          NAmat was true (the observation was missing)         ...  have a value of the jth element of DecisionOutcomes.Raw (the 'current best guess') 
    Mnew <- Mnew + NAsToFill
    #This replaces the NAs, which were zeros, with the predicted Decision outcome.
    
    
    if(Verbose) { print("Missing Values:"); print(NAmat) ; print("Imputed Values:"); print(NAsToFill)}
    
    #Declare Output
    MnewC <- Mnew
    ## Discriminate based on contract type
    #Fill ONLY Binary contracts by appropriately forcing predictions into their discrete (0,.5,1) slot. (reveals .5 coordination, continuous variables are more gameable).
    MnewC[,!ScaledIndex] <- apply(Mnew[,!ScaledIndex], c(1,2), function(x) Catch(x,CatchP) )
    #
    
  
  }
  
  if(Verbose) { print("Raw Results:"); print(Mnew) ; print("Binned:"); print(MnewC) ; print("*** ** Missing Values Filled ** ***") }
  
  return(MnewC)
}


#Putting it all together:
Factory <- function(M0,Scales,Rep,CatchP=.1,MaxRow=5000,Verbose=FALSE) {
  #Main Routine
  #Fill the default reputations (egalitarian) if none are provided...unrealistic and only for testing.
  if(missing(Rep)) { Rep <- ReWeight(rep(1,nrow(M0)))
                     if(Verbose) print("Reputation not provided...assuming equal influence.")
  }
  
  #******************
  #Fill the default scales (binary) if none are provided. In practice, this would also never be used.
  if(missing(Scales)) { Scales <- matrix( c( rep(FALSE,ncol(M0)),
                                             rep(0,ncol(M0)),
                                             rep(1,ncol(M0))), 3, byrow=TRUE, dimnames=list(c("Scaled","Min","Max"),colnames(M1)) )
                        if(Verbose) print("Scales not provided...assuming binary (0,1).")
  }
  ScaledIndex=as.logical( Scales["Scaled",] )
  
  MScaled <- Rescale(M0, Scales)

  #******************
  
  #Handle Missing Values  
  Filled <- FillNa(MScaled, Rep, ScaledIndex, CatchP, Verbose)

  ## Consensus - Row Players 
  #New Consensus Reward
  PlayerInfo <- GetRewardWeights(Filled,Rep,.1,Verbose)
  AdjLoadings <- PlayerInfo$FirstL
  
  ##Column Players (The Decision Creators)
  # Calculation of Reward for Decision Authors
  # Consensus - "Who won?" Decision Outcome 
  DecisionOutcomes.Raw <- PlayerInfo$SmoothRep %*% Filled #Declare (all binary), Simple matrix multiplication ... highest information density at RowBonus, but need DecisionOutcomes.Raw to get to that
  for(i in 1:ncol(Filled)) {    #slow implementation.. 'for loop' bad on R, much faster on python
    #Discriminate Based on Contract Type
    if(ScaledIndex[i]) DecisionOutcomes.Raw[i] <- weighted.median(Filled[,i], w=PlayerInfo$SmoothRep)  #Our Current best-guess for this Scaled Decision (weighted median)
  }
  
  #The Outcome Itself
  #Discriminate Based on Contract Type
  DecisionOutcome.Final <- mapply(Catch,DecisionOutcomes.Raw,Tolerance=CatchP) #Declare first (assumes all binary) 
  DecisionOutcome.Final[ScaledIndex] <- DecisionOutcomes.Raw[ScaledIndex]      #Replace Scaled with raw (weighted-median)
  DecisionOutcome.Final <- t( Scales["Max",] - Scales["Min",] ) %*% diag( DecisionOutcome.Final )    #Rescale these back up.
  DecisionOutcome.Final <- DecisionOutcome.Final + Scales["Min",]                                        #Recenter these back up.
  
  # Quality of Outcomes - is there confusion?
  Certainty <- vector("numeric",ncol(Filled))
  #Discriminate Based on Contract Type
  # Scaled first:
  DecisionOutcome.Final
  for(i in 1:ncol(Filled)) { #For each Decision
    Certainty[i] <- sum( PlayerInfo$SmoothRep [ DecisionOutcomes.Raw[i] == Filled[,i] ] )  # Sum of, the reputations which, met the condition that they voted for the outcome which was selected for this Decision.
  }
  # Overwrite Binary:
  Certainty[!ScaledIndex] <- abs(2*(DecisionOutcomes.Raw[!ScaledIndex]-.5))    # .5 is obviously undesireable for binaries, this function travels from 0 to 1 with a minimum at .5
  ConReward <- GetWeight(Certainty)                  #Grading Authors on a curve. -not necessarily the best idea? may just use Certainty instead
  Avg.Certainty <- mean(Certainty)                   #How well did beliefs converge?
  
 
  if(Verbose) {
    print("*Decision Outcomes Sucessfully Calculated*")
    print("Raw Outcomes, Certainty, AuthorPayoutFactor"); print( cbind(DecisionOutcomes.Raw,Certainty,ConReward))
  }
  
  
  ## Participation
  
  #Information about missing values
  NAmat <- M0*0 
  NAmat[is.na(NAmat)] <- 1 #indicator matrix for missing
  
  #Participation Within Decisions (Columns) 
  # % of reputation that answered each Decision
  ParticipationC <- 1-(PlayerInfo$SmoothRep%*%NAmat)
  
  #Participation Within Agents (Rows) 
  # Many options
  
  # 1- Democracy Option - all Decisions treated equally.
  ParticipationR  <- 1-( apply(NAmat,1,sum)/ncol(M0) )
  
  #General Participation
  PercentNA <- 1-mean(ParticipationC)
  #(Possibly integrate two functions of participation?) Chicken and egg problem...
  
  if(Verbose) {
    print("*Participation Information*")
    print("Voter Turnout by question"); print( ParticipationC )
    print("Voter Turnout across questions"); print ( ParticipationR )
  }
  
  ## Combine Information
  #Row
  NAbonusR <- GetWeight(ParticipationR)
  RowBonus <- (NAbonusR*(PercentNA))+(PlayerInfo$SmoothR*(1-PercentNA))
  
  #Column
  NAbonusC <- GetWeight(ParticipationC)
  ColBonus <- (NAbonusC*(PercentNA))+(ConReward*(1-PercentNA))  
  
  #Present Results
  Output <- vector("list",6) #Declare
  names(Output) <- c("Original","Filled","Agents","Decisions","Participation","Certainty")
  
  Output[[1]] <- M0
  Output[[2]] <- Filled
  Output[[3]] <- cbind(PlayerInfo$OldRep, PlayerInfo$ThisRep,PlayerInfo$SmoothRep,apply(NAmat,1,sum),ParticipationR,NAbonusR,RowBonus)
  colnames(Output[[3]]) <- c("OldRep", "ThisRep", "SmoothRep", "NArow", "ParticipationR","RelativePart","RowBonus")   
  Output[[4]] <- rbind(AdjLoadings,DecisionOutcomes.Raw,ConReward,Certainty,apply(NAmat,2,sum),ParticipationC,ColBonus,DecisionOutcome.Final)
  rownames(Output[[4]]) <- c("First Loading","DecisionOutcomes.Raw","Consensus Reward","Certainty","NAs Filled","ParticipationC","Author Bonus","DecisionOutcome.Final")
  Output[[5]] <- (1-PercentNA) #Using this to set inclusion fees.
  Output[[6]] <- Avg.Certainty #Using this to set Catch Parameter
  
  return(Output)
}

#Long-Term
Chain <- function(X,Scales,N=2,ThisRep) {
  #Repeats factory process N times
  if(missing(ThisRep)) ThisRep <- ReWeight(rep(1,nrow(X)))
  
  if(missing(Scales)) { Scales <- matrix( c( rep(FALSE,ncol(X)),
                                             rep(0,ncol(X)),
                                             rep(1,ncol(X))), 3, byrow=TRUE, dimnames=list(c("Scaled","Min","Max"),colnames(M1)) )
  }
  
  Output <- vector("list")
  for(i in 1:N) {
    Output[[i]] <- Factory(X,Scales,Rep=ThisRep)
    ThisRep <- Output[[i]]$Agents[,"RowBonus"]
  }
  
  return(Output)
}


#Notes

#Voting Across Time
#Later Votes could count more
#! ...simple change = DecisionOutcome.Final becomes exponentially smoothed result of previous chains.
#! require X number of chains (blocks) before the outcome is officially determined .. or, continue next round if ~ .5, or Decisions.Raw is within a threshold ( .2 to .8)
# Would need:
# 1] Percent Voted
# 2] Time Dimension of blocks.