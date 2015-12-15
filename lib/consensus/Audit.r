
### Auditing
# The Goal: Reduce audit cost (it is currently a 'binding constraint').
# Making auditing between only a few choices.


# #Cleanup
# rm(list=ls())

# #Load everything
# tryCatch(expr=setwd("~/GitHub/Truthcoin/lib"), error=function(e) setwd(choose.dir(caption="Failed to set working directory automatically. Choose 'Truthcoin/lib' folder:")) )
# source(file="consensus/ConsensusMechanism.r")
# 
# Use <- function(package) { if(suppressWarnings(!require(package,character.only=TRUE))) install.packages(package,repos="http://cran.case.edu/") ; require(package,character.only=TRUE) }



# Setup
# 
# Data:
# 
R <- c(.40, .25, .10, .10, .05, .05, .05)

VM <- matrix( c(1, 0, 0, 0, 0,
                1, 0, 0, 0, 0,
                1, 0, 0, 0, 0,
                1, 0, 0, 0, 0,
                1, 0, 0, 0, 0,
                1, 0, 0, 0, 0,
                1, 0, 0, 0, 0), 7,5,byrow=TRUE)

VM2 <- matrix(c(1, 0, 0, 0, 0,
                1, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0), 7,5,byrow=TRUE)

VM3 <- matrix(c(1, 0, 0, 0, 0,
                1, 0, 0, 0, 0,
                0, 1, 0, 1, 0,
                0, 0, 0, 0, 1,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 1,
                0, 0, 0, 0, 1), 7,5,byrow=TRUE)

VM4 <- matrix(c(1, 0, 0, 0, 0,
                1, 0, 0, 0, 0,
                .5, 0, 0, 0, 0,
                .5, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0), 6,5,byrow=TRUE)

VM5 <- matrix(c(0.0, 1.0, 0.81, 0.20, 0.03,
                0.0, 1.0, 0.79, 0.20, 0.04, # confused
                0.0, 1.0, 0.80, 0.20, 0.02,
                0.0, 1.0, 0.80, 0.20, 0.03,
                0.0, 1.0, 0.80, 0.98, 0.55, # liars spamming
                0.0, 1.0, 0.80, 0.97, 0.56, # liars spamming
                0.0, 1.0, 0.80, 0.99, 0.57), # liars spamming
              7, 5, byrow=TRUE)

# drawing it out of the binary ballot - cuts everything in half
VM6 <- matrix(c(0.8, 0.0, 0.0, 0.25, 0.045,
                0.6, 0.5, 0.5, 0.20, 0.030,
                0.4, 1.0, 1.0, 0.15, 0.015),
              3, 5, byrow=TRUE)

R6a <- c(.34,.32,.34)

R2 <- c(.40, .20, .20, .17, .01, .01, .01)

# End Setup


GetUniqueBallots <- function(VoteMatrix, Reputation = DemocracyRep(VoteMatrix)) {
  Use('reshape2')
  # Takes a VoteMatrix and Reputation, and returns a minimal set of unique Ballots.
  
  Rep_VM <- matrix(c(Reputation,VoteMatrix), nrow = nrow(VoteMatrix))
  
  # Force Unique Names
  colnames(Rep_VM) <- c( "Rep", paste("D",1:(ncol(Rep_VM)-1), sep=".") )
  
  # Get the unique ballots ("unique"), but ignore non-unique VTC ownership ( " [,-1]" ).
  Map1 <- data.frame( unique(Rep_VM[,-1]) ) 
  
  # Relabel (for upcoming merge)
  names(Map1) <- colnames(Rep_VM)[-1] # Again, we're dropping "Rep"
  
  # Give each Ballot a LETTER label
  Map2 <- cbind( Map1, "BallotGroup"= factor(LETTERS[1:nrow(Map1)]) )

  # Vote Matrix, with labelled Ballots
  Merg <- merge(Rep_VM,Map2)
  MergSub <- Merg[,c("Rep","BallotGroup")]
  
  # Aggregate Ballots
  Map3 <- dcast(MergSub, formula = BallotGroup~., fun.aggregate = sum, value.var = "Rep") #
  names(Map3) <- c("BallotGroup","BallotRep")
  
  Merg2 <- merge(Map3,Map2)
  if( !is.null(colnames(VoteMatrix)) ) names(Merg2) <- c( names(Merg2)[1:2], colnames(VoteMatrix) ) # restore original column names (if the given VM had colnames)
  return(Merg2)
}

# GetUniqueBallots(VoteMatrix = VM3, R)
#   BallotGroup BallotRep D.1 D.2 D.3 D.4 D.5
# 1           A      0.65   1   0   0   0   0
# 2           B      0.10   0   1   0   1   0
# 3           C      0.20   0   0   0   0   1
# 4           D      0.05   0   0   0   0   0


# GetUniqueBallots(VoteMatrix = VM4)
#   BallotGroup BallotRep D.1 D.2 D.3 D.4 D.5
# 1           A 0.3333333 1.0   0   0   0   0
# 2           B 0.3333333 0.5   0   0   0   0
# 3           C 0.3333333 0.0   0   0   0   0

# GetUniqueBallots(VoteMatrix = VM5)
#   BallotGroup BallotRep D.1 D.2  D.3  D.4  D.5
# 1           A 0.1428571   0   1 0.81 0.20 0.03
# 2           B 0.1428571   0   1 0.79 0.20 0.04
# 3           C 0.1428571   0   1 0.80 0.20 0.02
# 4           D 0.1428571   0   1 0.80 0.20 0.03
# 5           E 0.1428571   0   1 0.80 0.98 0.55
# 6           F 0.1428571   0   1 0.80 0.97 0.56
# 7           G 0.1428571   0   1 0.80 0.99 0.57

# GetUniqueBallots(VM6,Reputation = R6a)
#   BallotGroup BallotRep D.1 D.2 D.3  D.4   D.5
# 1           A      0.34 0.8 0.0 0.0 0.25 0.045
# 2           B      0.32 0.6 0.5 0.5 0.20 0.030
# 3           C      0.34 0.4 1.0 1.0 0.15 0.015



# We have succeeded in paritioning the VoteMatrix into selections. Auditors need only choose their favorite Ballot.
# 
# Can we do better?
# 1. An attacker will likely distort many Decisions at once, to maximize the Attack Revenue.
# 2. Double-Factory will already sort out only the contested Decisions.
# 3. It takes effort for each Auditor to consider each Ballot. Fewer Ballots = Less Effort, Easier Audit.
# 4. Likely, some attacked-Decisions will be extremely-obviously false (a claim that Romney was elected in 2012).
# 
# Auditors should be doing MUCH less work than Voters.
# Reducing to an 0 / 1 Ballot Referendum easily allows reuse of the existing SVD consensus system.
# 
# Goal: Reduce many unique Ballots to a maximally-representative set of 2 or 3.
# Strategy: calculated 'Moved Reputation' and minimize it.
# 
# EasyAuditing
# ==========================



GetTravelMatrix <- function(UniqueBallotDf) {
  # Takes the results computed by 'GetUniqueBallots' and uses them to build a matrix describing how different the Ballots are from each other.
  
  nBals <- nrow(UniqueBallotDf)
  
  DistMat <- matrix(0, nBals, nBals,dimnames = list(UniqueBallotDf$BallotGroup, UniqueBallotDf$BallotGroup))
  
  for(i in 1:nBals) { # for each Ballot-Group A, B, C...
    for(j in 1:nBals) { # for each other Ballot-Group A, B, C...
      if(i!=j) { # Diagonals will always be zero
        
        RowDifference <- UniqueBallotDf[i,-1:-2] - UniqueBallotDf[j,-1:-2] # How different are these rows?
        Distance <- sum( abs( RowDifference ) ) # Aggregate distance
        DistMat[i,j] <- Distance
        
        }
      }
    }
  
  DistMat
  
  TravelMat <- diag(UniqueBallotDf$BallotRep) %*% DistMat
  row.names(TravelMat) <- colnames(TravelMat)
  
  return(TravelMat)
}


# GetTravelMatrix( GetUniqueBallots(VoteMatrix = VM3, R) )
#      A    B    C    D
# A 0.00 1.95 1.30 0.65
# B 0.30 0.00 0.30 0.20
# C 0.40 0.60 0.00 0.20
# D 0.05 0.10 0.05 0.00

# GetTravelMatrix( GetUniqueBallots(VoteMatrix = VM4) )
#           A         B         C
# A 0.0000000 0.1666667 0.3333333
# B 0.1666667 0.0000000 0.1666667
# C 0.3333333 0.1666667 0.0000000



### Now, our pooling algorithm


GetChosen <- function(TravMat, ExtractN = 2) {
  # Takes a matrix of travel-distances ("from" row-Ballot "to" column-Ballot) and finds the two nearest destinations (columns)
  
  Use('combinat')
  
  Options <- combn(colnames(TravMat), ExtractN)
  
  # If there is exactly one option, we know will chose it. Also, there will be no columns (as there will be no matrix, just a vector). 
  if( is.null(ncol(Options)) ) return(Options)
  
  BallotPairs <- vector("numeric", ncol(Options))
  
  # Get Chosen
  for(i in 1:ncol(Options)) {
    
    ThisDestination <- Options[,i]
    
    # remove rows where the rowname matched the entries in this Option-column
    # "In a world where these Ballots are staying put (not going from anywhere to anwhere)."
    
    TravMatTemp <- TravMat[ , colnames(TravMat) %in% ThisDestination ]   # everyone must come to these rows
    TravMatTemp <- TravMatTemp[ !( row.names(TravMatTemp) %in% ThisDestination ) ,] # these rows aren't going anywhere
    
    if(class(TravMatTemp) =="numeric") {
      # In this case, we've removed all rows except one.
      BallotPairs[i] <- sum(TravMatTemp) # Total distance
      }
    
    if(class(TravMatTemp) =="matrix") {
      # Normal case
      ColMins <- apply( TravMatTemp, 1, function(x) x[which.min(x)]) # shortest path to a destination
      BallotPairs[i] <- sum(ColMins) # Total distance
      }
    
    # If TravMatTemp is of a different class, it is probably empty (and we can leave the distances at zero).
    }
  
  Chosen <- Options[ , which.min(BallotPairs) ]
  return(Chosen)
}

# GetChosen( GetTravelMatrix( GetUniqueBallots(VoteMatrix = VM3, R) ) )
# [1] "A" "C"
# 
# GetChosen( GetTravelMatrix( GetUniqueBallots(VoteMatrix = VM4) ) ) 
# [1] "A" "C"


GetAuditChoices <- function(VoteMatrix, Reputation = DemocracyRep(VoteMatrix), Phi = .80) {
  # Putting it all together.
  
  # Call our functions.
  Ballots <- GetUniqueBallots(VoteMatrix, Reputation)
  Distance <- GetTravelMatrix(Ballots)
  
  # Filter small fish / spam Ballots ( because I will be doing combinatorial math next)
  SeriousCandidates <- Distance[, Ballots$BallotRep >= .05 ] # might change ".05" to the Branch's (1-Phi)
  
  # Grab the most-representative choices, and don't stop grabbing until you have enough
  CumulativeReputation <- 0
  ExtractN <- 2
  while(CumulativeReputation < Phi) {  # ".80" should definitly be Phi
    Chosen <- GetChosen(SeriousCandidates, ExtractN)
    CumulativeReputation <- sum( Ballots[ Ballots$BallotGroup %in% Chosen , "BallotRep" ] )
    ExtractN <- ExtractN + 1
  }
  
  # For simplicity
  InChosen <- ( row.names(Distance) %in% Chosen )
  
  # Create two dataframes
  Choices <- Ballots[ InChosen , ]
  NonChoices <- Ballots[ !(InChosen) , ]
  
  # Get some info to tell people which Ballots contain which.
  NonChDist <- as.matrix( Distance[ !(InChosen) , InChosen ] )
  
  NonChoices$SurrogateChoice <- apply( NonChDist, 1, function(x) colnames(NonChDist)[which.min(x)] )
  
  return(list("Choices"=Choices,"NonChoices"=NonChoices))
  
}

# GetAuditChoices(VM4)
# 
# GetAuditChoices(VM3, R) 
# GetAuditChoices(VM3, R2) 
# 
# GetAuditChoices(VM5)
# GetAuditChoices(VM5, R2)
# 
# GetAuditChoices(VM6, R6a) 
# Here, we've succeeded in drawing the 'real' ballot (B) off, using 68% of the votes. However, B still has a surrogate choice ("C")
# B will deterministically have a unique surrogate choice (not a "Tie") unless every single Decision was scaled and had a real outcome of exactly ".5" (which is nearly impossible).




