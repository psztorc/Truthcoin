# Consensus Mechanism
# This is the mechanism that, theoretically,
 #   1] allows the software to determine the state of Decisions truthfully, and
 #   2] only allows an efficient number of most-traded-upon-Decisions.


try(setwd("~/GitHub/Truthcoin/lib"))
# To my knowledge, R does not feature 'automatic working directories' unless it is being run as a script

source("consensus/CustomMath.r")

## Functions:

DemocracyRep <- function(X) {
  # Run this if no Reputations were given...gives everyone an equal share and equal vote.
  Rep <- ReWeight(rep(1,nrow(X)))
}


BinaryScales <- function(X) {
  # Run this if no Scales were provided..assumes none were Scaled, all are Binary (0 or 1).
  Scales <- matrix( c( rep(FALSE,ncol(X)),
                       rep(0,ncol(X)),
                       rep(1,ncol(X))), 3, byrow=TRUE, dimnames=list(c("Scaled","Min","Max"),colnames(X)) )
}

GetRewardWeights <- function(M, Rep=DemocracyRep(M), alpha=.1, Verbose=FALSE) {
  #Calculates the new reputations using WPCA
  
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
  
  # The two options
  Set1 <-  FirstScore+abs(min(FirstScore))
  Set2 <-  FirstScore-max(FirstScore)   
  
  Old <- Rep%*%M
  
  New1 <- GetWeight(Set1)%*%M
  New2 <- GetWeight(Set2)%*%M
  
  #Difference in Sum of squared errors, if >0, then New1 had higher errors (use New2), and conversely if <0 use 1.
  RefInd <- sum( (New1-Old)^2) -  sum( (New2-Old)^2)
  
  if(RefInd<=0) AdjPrinComp <- Set1  
  if(RefInd>0)  AdjPrinComp <- Set2  
  
  if(Verbose) {
    print("")
    print(paste(" %% Reference Index %% :",RefInd))
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

# M <- matrix(nrow=3,byrow=TRUE,data=c(1,0,1,0,
#                                      1,0,1,0,
#                                      1,0,0,1))
# 
# M2 <- matrix(nrow=3,byrow=TRUE,data=c(.80, .1, .72, 0,
#                                       .80, .1, .62, 0,
#                                       .43, .1, .00, 1))

# > GetRewardWeights(M)
# $FirstL
# [1]  0.0000000  0.0000000 -0.7071068  0.7071068
# $OldRep
# [1] 0.3333333 0.3333333 0.3333333
# $ThisRep
# [1] 0.5 0.5 0.0
# $SmoothRep
# [1] 0.35 0.35 0.30
# 
# > GetRewardWeights(M, Rep=c(.2,.2,.6))
# $FirstL
# [1]  0.0000000  0.0000000 -0.7071068  0.7071068
# $OldRep
# [1] 0.2 0.2 0.6
# $ThisRep
# [1] 0 0 1
# $SmoothRep
# [1] 0.18 0.18 0.64
# 
# > GetRewardWeights(M2)
# $FirstL
# [1] -0.2934226  0.0000000 -0.5338542  0.7930340
# $OldRep
# [1] 0.3333333 0.3333333 0.3333333
# $ThisRep
# [1] 0.5105984 0.4894016 0.0000000
# $SmoothRep
# [1] 0.3510598 0.3489402 0.3000000
# 
# > GetRewardWeights(M2, Rep=c(.2,.2,.6), alpha=.5)
# $FirstL
# [1] -0.2935984  0.0000000 -0.5330507  0.7935092
# $OldRep
# [1] 0.2 0.2 0.6
# $ThisRep
# [1] 0.00000000 0.01362912 0.98637088
# $SmoothRep
# [1] 0.1000000 0.1068146 0.7931854


GetDecisionOutcomes <- function(Mtemp, Rep = DemocracyRep(Mtemp), ScaledIndex, Verbose=FALSE) {
  # Determines the Outcomes of Decisions based on the provided reputation (weighted vote)
    
  if(Verbose) { print("****************************************************") ; print("Begin 'GetDecisionOutcomes'")}
  
  DecisionOutcomes.Raw  <- 1:ncol(Mtemp) # Declare this (filled below)
  
  for(i in 1:ncol(Mtemp)) {    
    #For each column:    
    Row <- ReWeight(Rep[!is.na(Mtemp[,i])]) # The Reputation of the row-players who DID provide judgements, rescaled to sum to 1.
    Col <- Mtemp[!is.na(Mtemp[,i]),i]       # The relevant Decision with NAs removed. ("What these row-players had to say about the Decisions they DID judge.")
    
    #Discriminate Based on Contract Type
    if(!ScaledIndex[i]) DecisionOutcomes.Raw[i] <- Row %*% Col                   # Our Current best-guess for this Binary Decision (weighted average) 
    if(ScaledIndex[i]) DecisionOutcomes.Raw[i] <- weighted.median(w=Row, x=Col)  # Our Current best-guess for this Scaled Decision (weighted median)
   
    if(Verbose) { print("** **"); print("Column:"); print(i); print(AsMatrix(Row)); print(Col); print("Consensus:"); print(DecisionOutcomes.Raw[i]) }
  }
  
  #Output
  return(DecisionOutcomes.Raw)
}

# M <- matrix( data=c(
#       1,    1,    0,    0,    0.5356322, 6.689658e-01,
#       1,    0,    0,    0,    0.4574713,           NA,
#       1,    1,    0,    0,    0.5356322, 6.689658e-01,
#       1,    1,    1,    0,    0.5747126,           NA,
#       0,    0,    1,    1,    1.0000000, 8.333333e-05,
#       0,    0,    1,    1,    1.0000000, 9.999167e-01),
#   nrow=6,byrow=TRUE)

# > GetDecisionOutcomes(Mtemp=M, ScaledIndex=c(FALSE, FALSE, FALSE, FALSE, TRUE, TRUE))
# [1] 0.6666667 0.5000000 0.5000000 0.3333333 0.5551724 0.6689658
# > GetDecisionOutcomes(Mtemp=M, ScaledIndex=c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE))
# [1] 0.6666667 0.5000000 0.5000000 0.3333333 0.6839080 0.6689658
# > GetDecisionOutcomes(Mtemp=M, ScaledIndex=c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE), Rep=c(.2,.2,.1,.4,.04,.06))
# [1] 1.0000000 0.7000000 0.5000000 0.1000000 0.5820690 0.6517202


FillNa <- function(Mna, Rep = DemocracyRep(Mna), ScaledIndex = BinaryScales(Mna), CatchP=.1, Verbose=FALSE) { 
  # Uses exisiting data and reputations to fill missing observations.
  # Essentially a weighted average using all availiable non-NA data.
  # How much should slackers who arent voting suffer? I decided this would depend on the global percentage of slacking.
    
  Mnew <- Mna # Declare (in case no Missing values, Mnew, MnewC, and Mna will be the same)
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

# M <- matrix( data=c(
#       1,    1,     0,     0,    0.5356322, 6.689658e-01,
#       1,    0,    NA,    NA,    0.4574713,           NA,
#       1,    NA,    0,    NA,    0.5356322, 6.689658e-01,
#       1,    1,     1,    NA,    0.5747126,           NA,
#       0,    NA,    1,    NA,    1.0000000, 8.333333e-05,
#       0,    0,     1,     1,    NA,        9.999167e-01),
#   nrow=6,byrow=TRUE)

# > FillNa(M,ScaledIndex=c(FALSE,FALSE,FALSE,FALSE,TRUE,TRUE))
#       [,1] [,2] [,3] [,4]      [,5]         [,6]
# [1,]    1  1.0    0  0.0 0.5356322 6.689658e-01
# [2,]    1  0.0    1  0.5 0.4574713 6.689658e-01
# [3,]    1  0.5    0  0.5 0.5356322 6.689658e-01
# [4,]    1  1.0    1  0.5 0.5747126 6.689658e-01
# [5,]    0  0.5    1  0.5 1.0000000 8.333333e-05
# [6,]    0  0.0    1  1.0 0.5356322 9.999167e-01
# > FillNa(M,ScaledIndex=c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE))
#       [,1] [,2] [,3] [,4] [,5] [,6]
# [1,]    1  1.0    0  0.0  0.5    1
# [2,]    1  0.0    1  0.5  0.5    1
# [3,]    1  0.5    0  0.5  0.5    1
# [4,]    1  1.0    1  0.5  1.0    1
# [5,]    0  0.5    1  0.5  1.0    0
# [6,]    0  0.0    1  1.0  1.0    1



#Putting it all together:
Factory <- function(M0, Scales = BinaryScales(M0), Rep = DemocracyRep(M0), CatchP=.1, MaxRow=5000, Verbose=FALSE) {
  # Main Routine

  ScaledIndex=as.logical( Scales["Scaled",] )
  MScaled <- Rescale(M0, Scales)
  
  #Handle Missing Values  
  Filled <- FillNa(MScaled, Rep, ScaledIndex, CatchP, Verbose)

  ## Consensus - Row Players 
  # New Consensus Reward
  PlayerInfo <- GetRewardWeights(Filled,Rep,.1,Verbose)
  AdjLoadings <- PlayerInfo$FirstL
  
  ## Column Players (The Decision Creators)
  # Calculation of Reward for Decision Authors
  # Consensus - "Who won?" Decision Outcome 
  DecisionOutcomes.Raw <- PlayerInfo$SmoothRep %*% Filled #Declare (all binary), Simple matrix multiplication ... highest information density at RowBonus, but need DecisionOutcomes.Raw to get to that
  for(i in 1:ncol(Filled)) {    #slow implementation.. 'for loop' bad on R, much faster on python
    #Discriminate Based on Contract Type
    if(ScaledIndex[i]) DecisionOutcomes.Raw[i] <- weighted.median(Filled[,i], w=PlayerInfo$SmoothRep)  #Our Current best-guess for this Scaled Decision (weighted median)
  }
  
  #The Outcome Itself
  #Discriminate Based on Contract Type
  DecisionOutcome.Adj <- mapply(Catch,DecisionOutcomes.Raw,Tolerance=CatchP) #Declare first (assumes all binary) 
  DecisionOutcome.Adj[ScaledIndex] <- DecisionOutcomes.Raw[ScaledIndex]      #Replace Scaled with raw (weighted-median)
  DecisionOutcome.Final <- t( Scales["Max",] - Scales["Min",] ) %*% diag( DecisionOutcome.Adj )    #Rescale these back up.
  DecisionOutcome.Final <- DecisionOutcome.Final + Scales["Min",]                                        #Recenter these back up.
  
  # Quality of Outcomes - is there confusion?
  Certainty <- vector("numeric",ncol(Filled))
  #Discriminate Based on Contract Type
  # Scaled first:
  DecisionOutcome.Final
  for(i in 1:ncol(Filled)) { #For each Decision
    Certainty[i] <- sum( PlayerInfo$SmoothRep [ DecisionOutcome.Adj[i] == Filled[,i] ] )  # Sum of, the reputations which, met the condition that they voted for the outcome which was selected for this Decision.
  }
  
  ConReward <- GetWeight(Certainty)   #Grading Authors on a curve. -not necessarily the best idea? may just use Certainty instead
  Avg.Certainty <- mean(Certainty)    #How well did beliefs converge?
  
 
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


# M1 <-  rbind(
#   c(1,1,0,0),
#   c(1,0,0,0),
#   c(1,1,0,0),
#   c(1,1,1,0),
#   c(0,0,1,1),
#   c(0,0,1,1))
# 
# row.names(M1) <- c("True", "Distort 1", "True", "Distort 2", "Liar", "Liar")
# colnames(M1) <- c("C1.1","C2.1","C3.0","C4.0")

# > Factory(M1)
# $Original
#           C1.1 C2.1 C3.0 C4.0
# True         1    1    0    0
# Distort 1    1    0    0    0
# True         1    1    0    0
# Distort 2    1    1    1    0
# Liar         0    0    1    1
# Liar         0    0    1    1
# 
# $Filled
#           C1.1 C2.1 C3.0 C4.0
# True         1    1    0    0
# Distort 1    1    0    0    0
# True         1    1    0    0
# Distort 2    1    1    1    0
# Liar         0    0    1    1
# Liar         0    0    1    1
# 
# $Agents
#              OldRep   ThisRep SmoothRep NArow ParticipationR RelativePart  RowBonus
# True      0.1666667 0.2823757 0.1782376     0              1    0.1666667 0.1782376
# Distort 1 0.1666667 0.2176243 0.1717624     0              1    0.1666667 0.1717624
# True      0.1666667 0.2823757 0.1782376     0              1    0.1666667 0.1782376
# Distort 2 0.1666667 0.2176243 0.1717624     0              1    0.1666667 0.1717624
# Liar      0.1666667 0.0000000 0.1500000     0              1    0.1666667 0.1500000
# Liar      0.1666667 0.0000000 0.1500000     0              1    0.1666667 0.1500000
# 
# $Decisions
#                             C1.1       C2.1      C3.0      C4.0
# First Loading         -0.5395366 -0.4570561 0.4570561 0.5395366
# DecisionOutcomes.Raw   0.7000000  0.5282376 0.4717624 0.3000000
# Consensus Reward       0.5000000  0.0000000 0.0000000 0.5000000
# Certainty              0.7000000  0.0000000 0.0000000 0.7000000
# NAs Filled             0.0000000  0.0000000 0.0000000 0.0000000
# ParticipationC         1.0000000  1.0000000 1.0000000 1.0000000
# Author Bonus           0.5000000  0.0000000 0.0000000 0.5000000
# DecisionOutcome.Final  1.0000000  0.5000000 0.5000000 0.0000000
# 
# $Participation
# [1] 1
# 
# $Certainty
# [1] 0.35



# MS <- matrix( data=c(
#       1,    1,    0,    0,    233,   16027.59,
#       1,    0,    0,    0,    199,         NA,
#       1,    1,    0,    0,    233,   16027.59,
#       1,    1,    1,    0,    250,         NA,
#       0,    0,    1,    1,    435,    8001.00,
#       0,    0,    1,    1,    435,   19999.00),
#   nrow=6,byrow=TRUE)
# 
# Scales <- matrix( c( rep(FALSE,ncol(MS)),
#                      rep(0,ncol(MS)),
#                      rep(1,ncol(MS))), 3, byrow=TRUE, dimnames=list(c("Scaled","Min","Max"),colnames(MS2)) )
# 
# Scales["Scaled",5] <- 1
# Scales["Max",5] <- 435
# Scales["Scaled",6] <- 1
# Scales["Min",6] <- 8000
# Scales["Max",6] <- 20000
# 
# > Factory(M0=MS,Scales=Scales)
# $Original
#      [,1] [,2] [,3] [,4] [,5]     [,6]
# [1,]    1    1    0    0  233 16027.59
# [2,]    1    0    0    0  199       NA
# [3,]    1    1    0    0  233 16027.59
# [4,]    1    1    1    0  250       NA
# [5,]    0    0    1    1  435  8001.00
# [6,]    0    0    1    1  435 19999.00
# 
# $Filled
#      [,1] [,2] [,3] [,4]      [,5]         [,6]
# [1,]    1    1    0    0 0.5356322 6.689658e-01
# [2,]    1    0    0    0 0.4574713 6.689658e-01
# [3,]    1    1    0    0 0.5356322 6.689658e-01
# [4,]    1    1    1    0 0.5747126 6.689658e-01
# [5,]    0    0    1    1 1.0000000 8.333333e-05
# [6,]    0    0    1    1 1.0000000 9.999167e-01
# 
# $Agents
#         OldRep    ThisRep SmoothRep NArow ParticipationR RelativePart  RowBonus
# [1,] 0.1666667 0.27512698 0.1775127     0      1.0000000    0.1764706 0.1774530
# [2,] 0.1666667 0.22080941 0.1720809     1      0.8333333    0.1470588 0.1706477
# [3,] 0.1666667 0.27512698 0.1775127     0      1.0000000    0.1764706 0.1774530
# [4,] 0.1666667 0.21600171 0.1716002     1      0.8333333    0.1470588 0.1701944
# [5,] 0.1666667 0.00000000 0.1500000     0      1.0000000    0.1764706 0.1515162
# [6,] 0.1666667 0.01293492 0.1512935     0      1.0000000    0.1764706 0.1527356
# 
# $Decisions
#                             [,1]        [,2]       [,3]      [,4]        [,5]          [,6]
# First Loading         -0.5223889 -0.43411264 0.44195128 0.5223889   0.2463368 -9.880889e-02
# DecisionOutcomes.Raw   0.6987065  0.52662557 0.47289366 0.3012935   0.5356322  6.689658e-01
# Consensus Reward       0.2850531  0.00000000 0.00000000 0.2850531   0.1448406  2.850531e-01
# Certainty              0.6987065  0.00000000 0.00000000 0.6987065   0.3550254  6.987065e-01
# NAs Filled             0.0000000  0.00000000 0.00000000 0.0000000   0.0000000  2.000000e+00
# ParticipationC         1.0000000  1.00000000 1.00000000 1.0000000   1.0000000  6.563189e-01
# Author Bonus           0.2788520  0.01012676 0.01012676 0.2788520   0.1466709  2.753716e-01
# DecisionOutcome.Final  1.0000000  0.50000000 0.50000000 0.0000000 233.0000000  1.602759e+04
# 
# $Participation
# [1] 0.9427198
# 
# $Certainty
# [1] 0.4085242
# 
# > Factory(M0=MS,Scales=Scales,Rep=c(.05,.05,.05,.05,.10,.70))
# $Original
#      [,1] [,2] [,3] [,4] [,5]     [,6]
# [1,]    1    1    0    0  233 16027.59
# [2,]    1    0    0    0  199       NA
# [3,]    1    1    0    0  233 16027.59
# [4,]    1    1    1    0  250       NA
# [5,]    0    0    1    1  435  8001.00
# [6,]    0    0    1    1  435 19999.00
# $Filled
#      [,1] [,2] [,3] [,4]      [,5]         [,6]
# [1,]    1    1    0    0 0.5356322 6.689658e-01
# [2,]    1    0    0    0 0.4574713 9.999167e-01
# [3,]    1    1    0    0 0.5356322 6.689658e-01
# [4,]    1    1    1    0 0.5747126 9.999167e-01
# [5,]    0    0    1    1 1.0000000 8.333333e-05
# [6,]    0    0    1    1 1.0000000 9.999167e-01
# $Agents
#      OldRep    ThisRep  SmoothRep NArow ParticipationR RelativePart   RowBonus
# [1,]   0.05 0.00000000 0.04500000     0      1.0000000    0.1764706 0.04702833
# [2,]   0.05 0.01235137 0.04623514     1      0.8333333    0.1470588 0.04779064
# [3,]   0.05 0.00000000 0.04500000     0      1.0000000    0.1764706 0.04702833
# [4,]   0.05 0.01332745 0.04633275     1      0.8333333    0.1470588 0.04788674
# [5,]   0.10 0.11962886 0.10196289     0      1.0000000    0.1764706 0.10311239
# [6,]   0.70 0.85469232 0.71546923     0      1.0000000    0.1764706 0.70715357
# $Decisions
#                             [,1]       [,2]      [,3]      [,4]        [,5]         [,6]
# First Loading         -0.5369880 -0.4210132 0.4240200 0.5369880   0.2540098 4.149213e-02
# DecisionOutcomes.Raw   0.1825679  0.1363327 0.8637649 0.8174321   1.0000000 9.999167e-01
# Consensus Reward       0.1638874  0.1731571 0.1731767 0.1638874   0.1638874 1.620038e-01
# Certainty              0.8174321  0.8636673 0.8637649 0.8174321   0.8174321 8.080371e-01
# NAs Filled             0.0000000  0.0000000 0.0000000 0.0000000   0.0000000 2.000000e+00
# ParticipationC         1.0000000  1.0000000 1.0000000 1.0000000   1.0000000 9.074321e-01
# Author Bonus           0.1639706  0.1730973 0.1731166 0.1639706   0.1639706 1.618743e-01
# DecisionOutcome.Final  0.0000000  0.0000000 1.0000000 1.0000000 435.0000000 1.999900e+04
# $Participation
# [1] 0.984572
# $Certainty
# [1] 0.8312943




#Long-Term
Chain <- function(X, Scales = BinaryScales(X), N = 2, ThisRep = DemocracyRep(X)) {
  # Repeats factory process N times

  Output <- vector("list")
  for(i in 1:N) {
    Output[[i]] <- Factory(X,Scales,Rep=ThisRep)
    ThisRep <- Output[[i]]$Agents[,"RowBonus"]
  }
  
  return(Output)
}

# Double-Factory (much more reliable)

DoubleFactory <- function(X, Scales = BinaryScales(X), Rep = DemocracyRep(X), CatchP=.1, MaxRow=5000, Phi=.65, Verbose=FALSE) {
  # see http://forum.truthcoin.info/index.php/topic,102.msg289.html#msg289
  
  WaveOne <- Factory(X,Scales,Rep,CatchP,MaxRow,Verbose)
  
  Safe  <- ( WaveOne$Decisions["Certainty",] ) >= Phi # all those contracts which were unanimous for a subset of proportion ("Phi")
  
  if(Verbose) {
    print(" Wave One Complete.")
    print( sum(Safe)/ncol(X) )
  }
  
  WaveTwo <- Factory( X[,Safe] ,
                      Scales[,Safe],
                      Rep,CatchP,MaxRow,Verbose)
  
  return(WaveTwo)
}
