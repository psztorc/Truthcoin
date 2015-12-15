# Consensus Mechanism
# Paul Sztorc
# Written in R (v 3.1.1) using Rstudio (v 0.98.1028)

# This is the mechanism that, theoretically,
 #   1] allows the software to determine the state of Decisions truthfully, and
 #   2] only allows an efficient number of most-traded-upon-Decisions.


# To my knowledge, R does not feature 'automatic working directories' unless it is being run as a script
# try(setwd("~/GitHub/Truthcoin/lib/consensus"))
source("CustomMath.r")

## Functions:

DemocracyRep <- function(X) {
  # Run this if no Reputations were given...gives everyone an equal share and equal vote.
  
  Dem_Rep <- ReWeight(rep(1,nrow(X)))
  return( Dem_Rep )
}


BinaryScales <- function(X, IndexOnly=FALSE) {
  # Run this if no Scales were provided..assumes none were Scaled, all are Binary (0 or 1).
  
  Bin_Scales <- matrix( c( rep(FALSE,ncol(X)),
                       rep(0,ncol(X)),
                       rep(1,ncol(X))), 3, byrow=TRUE, dimnames=list(c("Scaled","Min","Max"),colnames(X)) )
  
  if(IndexOnly) return( as.logical( Bin_Scales["Scaled",] ) )
  return( Bin_Scales )
}


GetDecisionOutcomes <- function(Mtemp, Rep = DemocracyRep(Mtemp), ScaledIndex = BinaryScales(Mtemp, TRUE), Verbose=FALSE) {
  # Determines the (raw) Outcomes of Decisions based on the provided reputation (weighted vote)
  
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



GetRewardWeights <- function(M, Rep=DemocracyRep(M), ScaledIndex = BinaryScales(M, TRUE), alpha=.1, Tol=.2, Verbose=FALSE, RBCR=6) {
  # Calculates the new reputations using WPCA
  
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

  Results <- WeightedPrinComp(M,Rep)
  
  FirstLoading <- Results$Loadings #The first loading is designed to indicate which Decisions were more 'agreed-upon' than others. 
  FirstScore   <- Results$Scores   #The scores show loadings on consensus (to what extent does this observation represent consensus?)
  
  if(Verbose) { print("First Loading:"); print(FirstLoading); print("First Score:"); print(AsMatrix(FirstScore)) }
  

  # Skip all of this if there is pefect consensus (ie, all people agree).
  
  # Declared here, filled below (unless there was a perfect consensus).
  NewRep <- Rep # By default, reputations don't change if everyone agrees.
  
  if( ! sum(abs(FirstScore))==0 ) {
    
    ## Choosing Among Two Score-Persepectives
    
    # Now we have some work to do on the FirstScore.
    
    # PCA, being an abstract factorization, is incapable of determining anything absolute.
    # Therefore the results of the entire procedure would theoretically be reversed if the average state of Decisions changed from TRUE to FALSE.
    # Because the average state of Decisions is a function both of randomness and the way the Decisions are worded, I check to see which of the
    # two possible 'new' reputation vectors had more opinion in common with the original 'old' reputation.
    
    
    
    # The two options:
    Option1 <-  FirstScore + abs( min(FirstScore) )
    Option2 <-  abs( FirstScore - max(FirstScore) )
    
    # For each option:
    
    Score_Reflect <- function( Component, Previous_Reputation ) {
      # Takes an adjusted score, and breaks it at a median point.
      
      # Only if there actually is a median point.
      if( length( unique(Component) ) <= 2 ) return(Component)
      
      # If the Reps are calculated directly, there is an exploit in generating "sacrificial variance" and passing it to a teammate.
      # Although initially the sac-var is zero-sum (pointless), after reweighting it can become helpful to attackers.
      
      # Instead, a simple adjustment:
      MedianFactor <- weighted.median(Component, w = Previous_Reputation) # Which component is in the center?
      # This central value will be the next maximum, NOT the value opposite the most-deviant.
      
      # By how much does the component exceed the Median?
      Reflection <- Component - MedianFactor  
      # Where does the Component exceed the Median?
      Excessive <- ( Reflection > 0 )
      
      # Declare and Fill Answer
      AdjPrinComp <- Component
      AdjPrinComp[ Excessive ] <- Component[ Excessive ] - (  Reflection[ Excessive ] * 0.5  ) # Mixes in some of the old method.
      # Check: max(Component) == MedianFactor # TRUE
      
      return(AdjPrinComp)
    }
    
    
    NewScore_1 <- Score_Reflect(Option1, Rep)
    NewScore_2 <- Score_Reflect(Option2, Rep)
    
    # Now, by what criteria do we compare the options?
    # (This should be easy, because one option will be the opposite of truth, but it deserves some thought nonetheless.)
  
    Method <- RBCR # All of these work very well, but I'm pretty sure that Method 6 is the best.
    
    if( Method == 1 ) {
      # Statistics Method
      # "Which set would produce more representative results?"
      
      New1 <- GetWeight(Set1) %*% M  # reweight to the reputation units first, then calculate what outcomes would resolve to using this Rep
      New2 <- GetWeight(Set2) %*% M 
      
      RefInd <- sum( (New1-Old)^2 ) -  sum( (New2-Old)^2 ) # squared errors
      
    }
    
    if( Method == 2 ) {
      # Mathematics Method
      # "Which set moves the results the shortest distance?"
      
      New1 <- Set1 %*% M # Do not change units at all (only shift one observation to zero, and remove negatives).
      New2 <- Set2 %*% M # Notice that Set1 and Set2 already have the same max and min.
      
      RefInd <- sum( abs(New1-Old)) -  sum( abs(New2-Old))  # Raw errors, no squaring.
      
    }
    
    if( Method == 3 ) {
      # Rank Method
      # "Which set moves the direction the least?"
      
      rOld <- rank(Old)
      
      # Same as method 2, but focusing only on rank order. The logic being that we are focusing on the measurement of a single direction here.
      New1 <- rank( (GetWeight(Set1) %*% M) + 0.01*Old ) # I add Old because rank will erase data if final values are non-unique values
      New2 <- rank( (GetWeight(Set2) %*% M) + 0.01*Old )
      
      RefInd <- sum( abs(New1-rOld) ) - sum( abs(New2-rOld) )  # Raw errors, no squaring.
      
      if(RefInd==0) { # If the ranks are a tie, go back to Method 1
      
        New1 <- GetWeight(Set1) %*% M
        New2 <- GetWeight(Set2) %*% M
        
        RefInd <- sum( (New1-Old)^2 ) -  sum( (New2-Old)^2 ) # squared errors
      }
    }
    
    if( Method == 4 ) {
      # Norm Method - Operating Logic Unknown
      
      # Caluclate Potential Outcomes
      New1 <- GetDecisionOutcomes(M, GetWeight(Set1), ScaledIndex)
      New2 <- GetDecisionOutcomes(M, GetWeight(Set2), ScaledIndex) 
      
      # Absolute Differences in Outcome
      Choice1 <- abs( New1 - Old )
      Choice2 <- abs( New2 - Old )
      
      # Absolute Relevance of Dissagreement
      Dissent <- abs(FirstLoading)
      
      RefInd <- (Choice1 %*% Dissent) - (Choice2 %*% Dissent)
    }
    
    if( Method == 5 | Method == 6 ) {
      # Use Old Reputation to calculate outcomes.
      # Examine each voter's agreement with these outcomes.
      # Collapse this agreement using this period's Loading.
      
      # Old Outcomes
      Old_raw <- GetDecisionOutcomes(M, Rep, ScaledIndex) # Outcomes under the previous period's reputation
      # Bin non-scaled modes into < 0, .5, 1 > using Catch()
      Old_c <- vapply(Old_raw, FUN = Catch, Tolerance = Tol, FUN.VALUE = 1)
      Old_f <- Old_c ;  Old_f[ScaledIndex] <- Old_raw[ScaledIndex]
      
      # Build distance matrix: absolute value of difference between "Group Outcomes (using Old)" and "Individual Outcomes"
      Distance <- abs(  M - ( array(1, dim(M)) %*% diag(Old_f) )  )
      
      # Separately, build index of question-cohesion
      Dissent <- abs(FirstLoading) # FirstLoading is higher when people disagree, lower when people agree, zero for perfect agreement.
      Dissent[Dissent==0] <- NA # Remove Zeros (zeros are irrelevant, not infinitely important), avoid division-by-zero problems
      Mainstream <- ReWeight( 1/Dissent )
      
      # Integrate the Two
      NonCompliance <- Distance %*% t(t(Mainstream))
      Compliance <- ReWeight(  abs( NonCompliance - max(NonCompliance) )  )
      
      # Compare - Which score has more error when it is matched up against compliance?
      Choice1 <- sum( (GetWeight(NewScore_1) - Compliance)^2 )  # Reweight is absolutely required here, as the components will always sum to different values.
      Choice2 <- sum( (GetWeight(NewScore_2) - Compliance)^2 ) 
  
      # When RefInd becomes positive, switch to Set2.
      RefInd <- Choice1 - Choice2  # When Choice1 has greater error, this will be positive.
      
    }
    
    # Rep/mean(Rep) is a correction ensuring Reputation is additive. Therefore, nothing can be gained by splitting/combining Reputation into single/multiple accounts.
    Rep1 <- GetWeight( (NewScore_1 * Rep/mean(Rep)) )
    Rep2 <- GetWeight( (NewScore_2 * Rep/mean(Rep)) )
    
    # The Reference Index is a measurement of error, if >0, then New1 had higher errors (use New2), and conversely if <0 use 1.
    if(RefInd <  0 ) NewRep <- Rep1
    if(RefInd >= 0 ) NewRep <- Rep2
    
  }
  

  if(Verbose) {
  
    print("")
    print(paste(" %% Reference Index %% :",RefInd))
    print("Estimations using: Previous Rep, Option 1, Option 2")
    print(  cbind( AsMatrix(Old_f), AsMatrix( GetDecisionOutcomes(M, Rep1, ScaledIndex) ), AsMatrix( GetDecisionOutcomes(M, Rep2, ScaledIndex) ) )  )
    print("")
    print("Previous period reputations, Option 1, Option 2, Raw1, Raw2, Selection")
    print(  cbind( AsMatrix(Rep), AsMatrix(Rep1), AsMatrix(Rep2), AsMatrix(NewScore_1), AsMatrix(NewScore_2), AsMatrix(NewRep) )  )
    
  }
  
  
  # Freshly-Calculated Reward (Reputation) - Exponential Smoothing
  # New Reward: NewRep
  # Old Reward: Rep
  SmoothedR <- alpha*(NewRep) + (1-alpha)*Rep
  
  if(Verbose) {
    print("")
    print("Corrected for Additivity , Smoothed _1 period")
    print( cbind( AsMatrix(NewRep), AsMatrix(SmoothedR)) )
  }
  
  # Return Data
  Out <- list("FirstL"=FirstLoading,"OldRep"=Rep,"ThisRep"=NewRep,"SmoothRep"=SmoothedR)  # Keep the factors and time information along for the ride, they are interesting.
  return(Out)
}

# M <- matrix(nrow=3,byrow=TRUE,data=c(1,0,1,0,
#                                      1,0,1,0,
#                                      1,0,0,1))
# 
# M2 <- matrix(nrow=3,byrow=TRUE,data=c(.80, .1, .72, 0,
#                                       .80, .1, .62, 0,
#                                       .43, .1, .00, 1))
# 
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
# > GetRewardWeights(M, Rep=c(.2,.2,.6), Tol = .1)
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
# [1] 0.505356 0.494644 0.000000
# $SmoothRep
# [1] 0.3505356 0.3494644 0.3000000
# 
# > GetRewardWeights(M2, Rep=c(.2,.2,.6), alpha=.5, Verbose = TRUE)
# [1] "****************************************************"
# [1] "Begin 'GetRewardWeights'"
# [1] "Inputs..."
# [1] "Matrix:"
# [,1] [,2] [,3] [,4]
# [1,] 0.80  0.1 0.72    0
# [2,] 0.80  0.1 0.62    0
# [3,] 0.43  0.1 0.00    1
# [1] ""
# [1] "Reputation:"
# [,1]
# [1,]  0.2
# [2,]  0.2
# [3,]  0.6
# [1] ""
# [1] "First Loading:"
# [1] -0.2935984  0.0000000 -0.5330507  0.7935092
# [1] "First 
# [1] "Previous period reputations, Option 1, Option 2, Raw1, Raw2, Selection"
# [,1]       [,2]      [,3]       [,4]      [,5]       [,6]
# [1,]  0.2 0.00000000 0.5105824 0.00000000 0.6429686 0.00000000
# [2,]  0.2 0.01362912 0.4894176 0.05330507 0.6163160 0.01362912
# [3,]  0.6 0.98637088 0.0000000 1.28593716 0.0000000 0.98637088
# [1] ""
# [1] "Corrected for Additivity , Smoothed _1 period"
# [,1]      [,2]
# [1,] 0.00000000 0.1000000
# [2,] 0.01362912 0.1068146
# [3,] 0.98637088 0.7931854
# $FirstL
# [1] -0.2935984  0.0000000 -0.5330507  0.7935092
# 
# $OldRep
# [1] 0.2 0.2 0.6
# 
# $ThisRep
# [1] 0.00000000 0.01362912 0.98637088
# 
# $SmoothRep
# [1] 0.1000000 0.1068146 0.7931854


# Score:"
# [,1]
# [1,] -0.7822233
# [2,] -0.7289182
# [3,]  0.5037139
# [1] ""
# [1] " %% Reference Index %% : -1.26355970920342"
# [1] "Estimations using: Previous Rep, Option 1, Option 2"
# [,1]        [,2]      [,3]
# [1,]  0.5 0.435042774 0.8000000
# [2,]  0.0 0.100000000 0.1000000
# [3,]  0.0 0.008450054 0.6710582
# [4,]  0.5 0.986370881 0.0000000
# [1] ""

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
    MnewC[,!ScaledIndex] <- apply(Mnew[,!ScaledIndex], c(1,2), function(x) Catch(x,Tolerance = CatchP) )
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
Factory <- function(M0, Scales = BinaryScales(M0), Rep = DemocracyRep(M0), CatchP=.2, MaxRow=5000, Verbose=FALSE, RBCR = 6) {
  # Main Routine

  ScaledIndex=as.logical( Scales["Scaled",] )
  MScaled <- Rescale(M0, Scales)
  
  #Handle Missing Values  
  Filled <- FillNa(MScaled, Rep, ScaledIndex, CatchP, Verbose)

  ## Consensus - Row Players 
  # New Consensus Reward
  PlayerInfo <- GetRewardWeights(M = Filled, Rep, ScaledIndex, alpha = .1, Tol = CatchP, Verbose, RBCR)
  AdjLoadings <- PlayerInfo$FirstL
  
  ## Column Players (The Decision Creators)
  # Calculation of Reward for Decision Authors
  # Consensus - "Who won?" Decision Outcome 
  DecisionOutcomes.Raw <- PlayerInfo$SmoothRep %*% Filled # Declare (all binary), Simple matrix multiplication ... highest information density at RowBonus, but need DecisionOutcomes.Raw to get to that
  for(i in 1:ncol(Filled)) {    # slow implementation.. 'for loop' bad on R, much faster on python
    # Discriminate Based on Contract Type
    if(ScaledIndex[i]) DecisionOutcomes.Raw[i] <- weighted.median(Filled[,i], w=PlayerInfo$SmoothRep)  #Our Current best-guess for this Scaled Decision (weighted median)
  }
  
  # The Outcome Itself
  # Discriminate Based on Contract Type
  DecisionOutcome.Adj <- mapply(Catch,DecisionOutcomes.Raw,Tolerance=CatchP) # Declare first (assumes all binary) 
  DecisionOutcome.Adj[ScaledIndex] <- DecisionOutcomes.Raw[ScaledIndex]      # Replace Scaled with raw (weighted-median)
  DecisionOutcome.Final <- t( Scales["Max",] - Scales["Min",] ) %*% diag( DecisionOutcome.Adj )    # Rescale these back up.
  DecisionOutcome.Final <- DecisionOutcome.Final + Scales["Min",]                                  # Recenter these back up.
  
  
  # Quality of Outcomes - is there confusion?
  
  Certainty <- vector("numeric",ncol(Filled))
  # For each Decision
  for(i in 1:ncol(Filled)) { 
    # Sum of, the reputations which, met the condition that they voted for the outcome which was selected for this Decision.
    Certainty[i] <- sum( PlayerInfo$SmoothRep [ DecisionOutcome.Final[i] == Filled[,i] ] )
  }
  Avg.Certainty <- mean(Certainty)    # How well did beliefs converge?
  
  # Stability of Voter Reports is not the same as "Clear Instructions" (one can be 'certain' that something was 'unclear' if you all agree it was).
  # Want to discourage .5's
  Resolveable <- Filled!=.5
  MaxClairity <- Rep %*% Resolveable # All of the answers for .5 are an instant-veto on Clairity. If 30% said 'unclear' can't do better than 70%.
  Clarity <- MaxClairity * Certainty
  
  ConReward <- GetWeight(Clarity)   # Grading Authors on a curve. -not necessarily the best idea?

 
  if(Verbose) {
    print("*Decision Outcomes Sucessfully Calculated*")
    Temp <- rbind(DecisionOutcomes.Raw, Certainty, ConReward)
    row.names(Temp) <- c("Raw Outcomes", "Certainty", "AuthorPayoutFactor")
    print(Temp)
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
  # Row
  NAbonusR <- GetWeight(ParticipationR)
  RowBonus <- (NAbonusR*(PercentNA))+(PlayerInfo$SmoothR*(1-PercentNA))
  
  # Column
  NAbonusC <- GetWeight(ParticipationC)
  ColBonus <- (NAbonusC*(PercentNA))+(ConReward*(1-PercentNA))  
  
  # Present Results
  Output <- vector("list",6) #Declare
  names(Output) <- c("Original","Filled","Agents","Decisions","Participation","Certainty")
  
  Output[[1]] <- M0
  Output[[2]] <- Filled
  Output[[3]] <- cbind(PlayerInfo$OldRep, PlayerInfo$ThisRep,PlayerInfo$SmoothRep,apply(NAmat,1,sum),ParticipationR,NAbonusR,RowBonus)
  colnames(Output[[3]]) <- c("OldRep", "ThisRep", "SmoothRep", "NArow", "ParticipationR","RelativePart","RowBonus")   
  Output[[4]] <- rbind(AdjLoadings,DecisionOutcomes.Raw,ConReward,Certainty,apply(NAmat,2,sum),ParticipationC,ColBonus,DecisionOutcome.Final)
  rownames(Output[[4]]) <- c("First Loading","DecisionOutcomes.Raw","Consensus Reward","Certainty","NAs Filled","ParticipationC","Author Bonus","DecisionOutcome.Final")
  Output[[5]] <- (1-PercentNA) # Using this to set inclusion fees.
  Output[[6]] <- Avg.Certainty # Using this to set Catch Parameter
  
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
# colnames(M1) <- c("D1.1","D2.1","D3.0","D4.0")
# 
# > Factory(M1)
# $Original
# D1.1 D2.1 D3.0 D4.0
# True         1    1    0    0
# Distort 1    1    0    0    0
# True         1    1    0    0
# Distort 2    1    1    1    0
# Liar         0    0    1    1
# Liar         0    0    1    1
# 
# $Filled
# D1.1 D2.1 D3.0 D4.0
# True         1    1    0    0
# Distort 1    1    0    0    0
# True         1    1    0    0
# Distort 2    1    1    1    0
# Liar         0    0    1    1
# Liar         0    0    1    1
# 
# $Agents
# OldRep   ThisRep SmoothRep NArow ParticipationR RelativePart  RowBonus
# True      0.1666667 0.2823757 0.1782376     0              1    0.1666667 0.1782376
# Distort 1 0.1666667 0.2176243 0.1717624     0              1    0.1666667 0.1717624
# True      0.1666667 0.2823757 0.1782376     0              1    0.1666667 0.1782376
# Distort 2 0.1666667 0.2176243 0.1717624     0              1    0.1666667 0.1717624
# Liar      0.1666667 0.0000000 0.1500000     0              1    0.1666667 0.1500000
# Liar      0.1666667 0.0000000 0.1500000     0              1    0.1666667 0.1500000
# 
# $Decisions
# D1.1       D2.1      D3.0      D4.0
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
# 
# 
# 
# MS <- matrix( data=c(
#       1,    1,    0,    0,    233,   16027.59,
#       1,    0,    0,    0,    199,         NA,
#       1,    1,    0,    0,    233,   16027.59,
#       1,    1,    1,    0,    250,         NA,
#       0,    0,    1,    1,    435,    8001.00,
#       0,    0,    1,    1,    435,   19999.00),
#   nrow=6,byrow=TRUE, dimnames=list( rownames(M1), paste("D",1:6,sep=".")))
# 
# 
# Scales <- matrix( data=c(
#             0, 0, 0, 0,   1,     1,
#             0, 0, 0, 0,   0,  8000,
#             1, 1, 1, 1, 435, 20000),  
#       nrow=3, byrow=TRUE, dimnames=list( c("Scaled","Min","Max"), colnames(MS)) )
# 
# 
# > Factory(M0=MS,Scales=Scales)
# $Original
# D.1 D.2 D.3 D.4 D.5      D.6
# True        1   1   0   0 233 16027.59
# Distort 1   1   0   0   0 199       NA
# True        1   1   0   0 233 16027.59
# Distort 2   1   1   1   0 250       NA
# Liar        0   0   1   1 435  8001.00
# Liar        0   0   1   1 435 19999.00
# 
# $Filled
# D.1 D.2 D.3 D.4       D.5          D.6
# True        1   1   0   0 0.5356322 6.689658e-01
# Distort 1   1   0   0   0 0.4574713 6.689658e-01
# True        1   1   0   0 0.5356322 6.689658e-01
# Distort 2   1   1   1   0 0.5747126 6.689658e-01
# Liar        0   0   1   1 1.0000000 8.333333e-05
# Liar        0   0   1   1 1.0000000 9.999167e-01
# 
# $Agents
# OldRep    ThisRep SmoothRep NArow ParticipationR RelativePart  RowBonus
# True      0.1666667 0.27512698 0.1775127     0      1.0000000    0.1764706 0.1774530
# Distort 1 0.1666667 0.22080941 0.1720809     1      0.8333333    0.1470588 0.1706477
# True      0.1666667 0.27512698 0.1775127     0      1.0000000    0.1764706 0.1774530
# Distort 2 0.1666667 0.21600171 0.1716002     1      0.8333333    0.1470588 0.1701944
# Liar      0.1666667 0.00000000 0.1500000     0      1.0000000    0.1764706 0.1515162
# Liar      0.1666667 0.01293492 0.1512935     0      1.0000000    0.1764706 0.1527356
# 
# $Decisions
# D.1         D.2        D.3       D.4         D.5           D.6
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
#           D.1 D.2 D.3 D.4 D.5      D.6
# True        1   1   0   0 233 16027.59
# Distort 1   1   0   0   0 199       NA
# True        1   1   0   0 233 16027.59
# Distort 2   1   1   1   0 250       NA
# Liar        0   0   1   1 435  8001.00
# Liar        0   0   1   1 435 19999.00
# 
# $Filled
#           D.1 D.2 D.3 D.4       D.5          D.6
# True        1   1   0   0 0.5356322 6.689658e-01
# Distort 1   1   0   0   0 0.4574713 9.999167e-01
# True        1   1   0   0 0.5356322 6.689658e-01
# Distort 2   1   1   1   0 0.5747126 9.999167e-01
# Liar        0   0   1   1 1.0000000 8.333333e-05
# Liar        0   0   1   1 1.0000000 9.999167e-01
# 
# $Agents
#           OldRep    ThisRep  SmoothRep NArow ParticipationR RelativePart   RowBonus
# True        0.05 0.00000000 0.04500000     0      1.0000000    0.1764706 0.04702833
# Distort 1   0.05 0.01235137 0.04623514     1      0.8333333    0.1470588 0.04779064
# True        0.05 0.00000000 0.04500000     0      1.0000000    0.1764706 0.04702833
# Distort 2   0.05 0.01332745 0.04633275     1      0.8333333    0.1470588 0.04788674
# Liar        0.10 0.11962886 0.10196289     0      1.0000000    0.1764706 0.10311239
# Liar        0.70 0.85469232 0.71546923     0      1.0000000    0.1764706 0.70715357
# 
# $Decisions
#                              D.1        D.2       D.3       D.4         D.5          D.6
# First Loading         -0.5369880 -0.4210132 0.4240200 0.5369880   0.2540098 4.149213e-02
# DecisionOutcomes.Raw   0.1825679  0.1363327 0.8637649 0.8174321   1.0000000 9.999167e-01
# Consensus Reward       0.1638874  0.1731571 0.1731767 0.1638874   0.1638874 1.620038e-01
# Certainty              0.8174321  0.8636673 0.8637649 0.8174321   0.8174321 8.080371e-01
# NAs Filled             0.0000000  0.0000000 0.0000000 0.0000000   0.0000000 2.000000e+00
# ParticipationC         1.0000000  1.0000000 1.0000000 1.0000000   1.0000000 9.074321e-01
# Author Bonus           0.1639706  0.1730973 0.1731166 0.1639706   0.1639706 1.618743e-01
# DecisionOutcome.Final  0.0000000  0.0000000 1.0000000 1.0000000 435.0000000 1.999900e+04
# 
# $Participation
# [1] 0.984572
# 
# $Certainty
# [1] 0.8312943




# Double-Factory (more reliable)

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


# M1 is defined above

# > DoubleFactory(M1)
# $Original
#           D1.1 D4.0
# True         1    0
# Distort 1    1    0
# True         1    0
# Distort 2    1    0
# Liar         0    1
# Liar         0    1
# 
# $Filled
#           D1.1 D4.0
# True         1    0
# Distort 1    1    0
# True         1    0
# Distort 2    1    0
# Liar         0    1
# Liar         0    1
# 
# $Agents
#              OldRep ThisRep SmoothRep NArow ParticipationR RelativePart RowBonus
# True      0.1666667    0.25     0.175     0              1    0.1666667    0.175
# Distort 1 0.1666667    0.25     0.175     0              1    0.1666667    0.175
# True      0.1666667    0.25     0.175     0              1    0.1666667    0.175
# Distort 2 0.1666667    0.25     0.175     0              1    0.1666667    0.175
# Liar      0.1666667    0.00     0.150     0              1    0.1666667    0.150
# Liar      0.1666667    0.00     0.150     0              1    0.1666667    0.150
# 
# $Decisions
#                             D1.1      D4.0
# First Loading         -0.7071068 0.7071068
# DecisionOutcomes.Raw   0.7000000 0.3000000
# Consensus Reward       0.5000000 0.5000000
# Certainty              0.7000000 0.7000000
# NAs Filled             0.0000000 0.0000000
# ParticipationC         1.0000000 1.0000000
# Author Bonus           0.5000000 0.5000000
# DecisionOutcome.Final  1.0000000 0.0000000
# 
# $Participation
# [1] 1
# 
# $Certainty
# [1] 0.7


# M2 <- matrix( data=c(
#   c(0.5, 0.5, 1,  0),
#   c(0.5, 0.0, 1,  0),
#   c(0.5, 1.0, 1,  0),
#   c(1.0,  NA, 1, NA),
#   c(0.5, 1.0, 1,  1),
#   c(0.0, 0.0, 1,  1)), nrow=6, byrow=TRUE, dimname=list(paste("V",1:6,sep="."), colnames(M1)) )
# 
# > DoubleFactory(M2)
# $Original
#     D1.1 D3.0 D4.0
# V.1  0.5    1    0
# V.2  0.5    1    0
# V.3  0.5    1    0
# V.4  1.0    1   NA
# V.5  0.5    1    1
# V.6  0.0    1    1
# 
# $Filled
#     D1.1 D3.0 D4.0
# V.1  0.5    1    0
# V.2  0.5    1    0
# V.3  0.5    1    0
# V.4  1.0    1    0
# V.5  0.5    1    1
# V.6  0.0    1    1

# $Agents
#        OldRep    ThisRep SmoothRep NArow ParticipationR RelativePart  RowBonus
# V.1 0.1666667 0.22833653 0.1728337     0      1.0000000    0.1764706 0.1730484
# V.2 0.1666667 0.22833653 0.1728337     0      1.0000000    0.1764706 0.1730484
# V.3 0.1666667 0.22833653 0.1728337     0      1.0000000    0.1764706 0.1730484
# V.4 0.1666667 0.27166347 0.1771663     1      0.6666667    0.1176471 0.1736514
# V.5 0.1666667 0.04332693 0.1543327     0      1.0000000    0.1764706 0.1556401
# V.6 0.1666667 0.00000000 0.1500000     0      1.0000000    0.1764706 0.1515632
# 
# $Decisions
#                             D1.1      D3.0      D4.0
# First Loading         -0.4241554 0.0000000 0.9055894
# DecisionOutcomes.Raw   0.5135832 1.0000000 0.3043327
# Consensus Reward       0.1168147 0.5208482 0.3623371
# Certainty              0.6728337 1.0000000 0.6956673
# NAs Filled             0.0000000 0.0000000 1.0000000
# ParticipationC         1.0000000 1.0000000 0.8228337
# Author Bonus           0.1308368 0.5110099 0.3581533
# DecisionOutcome.Final  0.5000000 1.0000000 0.0000000
# 
# $Participation
# [1] 0.9409446
# 
# $Certainty
# [1] 0.7895003
