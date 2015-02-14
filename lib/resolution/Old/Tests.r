#Tests and Explanations

#Function Library
try(setwd("~/Shared Files/DPM/Latest"))
source(file="ConsensusMechanism.r")

#Declare List
Scenarios <- vector("list")
SLabels <- vector("list")

#[1] Design Case
SLabels$Base <- "Basic Case - 14/24 [58%] Honest"

M1 <-  rbind(
    c(1,1,0,0),
    c(1,0,0,0),
    c(1,1,0,0),
    c(1,1,1,0),
    c(0,0,1,1),
    c(0,0,1,1))
  
row.names(M1) <- c("True", "Confused 1", "True", "Confused 2", "Liar", "Liar")
colnames(M1) <- c("C1.1","C2.1","C3.0","C4.0")

Scenarios$Base <- M1
#


# [2] Reversed Matrix
SLabels$Reversed <- "Basic Case - 14/24 [58%] Honest, reversed wording"
M2 <- ReverseMatrix(M1)
Scenarios$Reversed <- M2
#


# [3] Deviance: Deranged Nonconformist
SLabels$Deviance <- "Punishment from Deviating from Stable"

M3 <- rbind(M1[c(1,3),],
            M1[c(1,3),],
            "Liar"=c(0,0,1,1))

Scenarios$Deviance <- M3
#


# [4] Coalitional Deviance: Using a group to game the system.
SLabels$CoalitionalDeviance <- "Targeting Contract (#3) with <50% Conspirators (including 1 AntiTruth Diver)"
SLabels$CoalitionalDeviance2 <- "Targeting Contract (#3) with <50% Conspirators (including 1 AntiTeam Diver)"

 M4b <- rbind("True"=c(1,1,0,0),
              "True"=c(1,1,0,0),
              "True"=c(1,1,0,0),
              "True"=c(1,1,0,0),
              "True"=c(1,1,0,0),
              "True"=c(1,1,0,0),
              "Diver"=c(0,0,1,1), #Diver
              "Liar"=c(1,1,1,0),
              "Liar"=c(1,1,1,0),
              "Liar"=c(1,1,1,0), #4 conspirators           
              "Liar"=c(1,1,1,0)) # + 1 Diver     = 5 <6    

M4c <- M4b
M4c["Diver",3] <- 0 #Diver negatively correlated with his team

M4d <- rbind(M4c,"FailSafe"=c(.5,.5,.5,.5))


Scenarios$CoalitionalDeviance  <- M4b
Scenarios$CoalitionalDeviance2  <- M4c
#


# [5] Clueless: Passing on a Contract - "I have no idea"
SLabels$CluelessControl <- c("Having no idea - 'passing' on a contract [control]")  
SLabels$CluelessTest <- c("Having no idea - 'passing' on a contract [test]")  

M3a <- rbind(M1[1,],M1[1,],M1[1,],M1[1,],M1[1,],M1[1,],M1[1,]) #bigger reference case
row.names(M3a) <- rep("True",nrow(M3a))

M3m <- M3a
M3m[2,2] <- NA 

Scenarios$CluelessControl <- M3a 
Scenarios$CluelessTest <- M3m 
#

 
# [6] Inchoerence
SLabels$Incoherence <- c("Punishing Incoherence - I KNOW that this contract is spam/nonsense") 
SLabels$Incoherence2 <- c("Punishing Incoherence - I KNOW that this contract is spam/nonsense [2]") 

M6 <- M3a
M6[-3,2]  <- .5 #Incoherent

M6b <- M6
M6b[7,2]  <- 0 #Incentive examination

Scenarios$Inchoherence <- M6
Scenarios$Inchoherence2 <- M6b
#
  

# [7] Unanimous: Perfect Consensus Bug
SLabels$Unanimous <- c("Having everyone agree perfectly (desireable) crashes PCA") 

PerCon <- rbind(M1[1,], M1[1,], M1[1,], M1[1,])

Scenarios$PerCon <- PerCon
#


# [8] Contract Gaming
SLabels$Gaming <- c("Gaming the Contracts") 

M9 <- cbind(M1,"C0.5"=.5,"C0.5"=.5,"C0.5"=.5,"C0.5"=.5,"C0.5"=.5,"C0.5"=.5,"C0.5"=.5,"C0.5"=.5)
M9[5:6,5:12] <- c(0,1,1,0)
M9 <- rbind(M9,M9,M9,M9)

Scenarios$Gaming <- M9
#


# [9] Handling Missing Values
SLabels$Missing1 <- c("A minority of players give missing values to 1 contract")
SLabels$Missing2 <- c("A majority of players give missing values to a minority of their contracts")
SLabels$Missing3 <- c("All players give missing values to a minority of their contracts")
SLabels$Missing4 <- c("Some players give missing values to a majority of their contracts")
SLabels$Missing5 <- c("All players give missing values to a majority of their contracts")

M10a <- cbind(M1,"C0"=c(0,NA,0,NA,1,1))

M10b <- cbind(M10a, "C1"=c(1,1,1,NA,0,0), "C1"=c(NA,NA,NA,0,1,1))
M10b <- rbind(M10b,M10b)

M10c <- M10b
M10c[5,1] <- NA ; M10c[6,2] <- NA ; M10c[11,1] <- NA ; M10c[12,2] <- NA ;

M10d <- M10b[-11:-12,]
M10d[5,3:6] <- NA ; M10d[6,1:4] <- NA ; 
M10d[7:8,1:2] <- NA ; M10d[2,2:3] <- NA;

M10e <- rbind(M1,M1)
M10e <- cbind(M10e[,1],M10e,M10e)

M10e[1,1:5] <- NA
M10e[2,2:6] <- NA
M10e[3,3:7] <- NA
M10e[4,4:8] <- NA
M10e[5,5:9] <- NA
M10e[6,c(6:9,1)] <- NA
M10e[7,c(7:9,1:2)] <- NA
M10e[8,c(8:9,1:3)] <- NA
M10e[9,c(9,1:4)] <- NA
M10e[10,1:5] <- NA
M10e[11,2:6] <- NA
M10e[12,3:7] <- NA

Scenarios$Missing1 <- M10a
Scenarios$Missing2 <- M10b
Scenarios$Missing3 <- M10c
Scenarios$Missing4 <- M10d
Scenarios$Missing5 <- M10e
#


# [10] Riven Judgements
SLabels$Riven <- "Separate but equal subgroups, and their recombination. [1]" 
SLabels$Riven2 <- "Separate but equal subgroups, and their recombination. [2]" 

Mg <- rbind( cbind(M1,   M1*NA, M1*NA),
             cbind(M1*NA,M1,    M1*NA),
             cbind(M1*NA,M1*NA, M1))

Mg2 <- Mg
Mg2[7,1] <- 1


Scenarios$Riven <- Mg
Scenarios$Riven2 <- Mg2
#



### * Test Results and Commentary * ###

Factory(Scenarios$Base)
CompareIncentives(Scenarios$Base)
#Good.
Chain(X=Scenarios$Base)
#Very good. Conforms quickly to a correct prediction.
#I'm thinking one block per day, assuming we smooth difficulty correctly.

Factory(Scenarios$Reversed)
all.equal(Factory(Scenarios$Reversed)$Agents,Factory(Scenarios$Base)$Agents) #TRUE
#Identical incentive structure, despite reversed inputs and outputs.
#Good.

Factory(Scenarios$Deviance)
#Biggest Deviator gets CRUSHED to zero. High-Stakes!
#Good.

Factory(Scenarios$CoalitionalDeviance)
#Success: An attempted <51% attack which failed.

Factory(Scenarios$CoalitionalDeviance2)
# Oh, no: A Sucessful <51% attack 'Friendly Fire' ...will have to address this.

  #Pre-Analytics
  CompareIncentives(X=Scenarios$CoalitionalDeviance2)
  
  row.names( Scenarios$CoalitionalDeviance2 )[7] <- "Liar"
  CompareIncentives(X=Scenarios$CoalitionalDeviance2)

  # [1] Success: 'Symmetric Friendly Fire'  (ie Team truth forms a coalition of their own)
  Scenarios$CoalitionalDeviance3 <- Scenarios$CoalitionalDeviance2
  Scenarios$CoalitionalDeviance3[6,] <- c(0,0,1,1)

  CompareIncentives(X=Scenarios$CoalitionalDeviance3)
  Chain(Scenarios$CoalitionalDeviance3,N=100)
  #Team 'True' wins via symmetry-exploitation

  # [2] Success: 'Cold Feet 1' (a single player abandons the coalition)
  Scenarios$CoalitionalDeviance4 <- Scenarios$CoalitionalDeviance2
  Scenarios$CoalitionalDeviance4[8,] <- c(1,1,0,0)
  
  CompareIncentives(X=Scenarios$CoalitionalDeviance4)
  Ss <- Chain(Scenarios$CoalitionalDeviance4,N=70)[[70]]$Agents
  Ss <- data.frame(NewRep=as.numeric(Ss[,"NewRep"]),Group=row.names(Ss))
  aggregate(.~Group,data=Ss, FUN=sum)

  Scenarios$CoalitionalDeviance5 <- Scenarios$CoalitionalDeviance2
  Scenarios$CoalitionalDeviance5[8,] <- c(1,1,0,0)
  Scenarios$CoalitionalDeviance5[9,] <- c(1,1,0,0)

  CompareIncentives(X=Scenarios$CoalitionalDeviance5)
  Ss <- Chain(Scenarios$CoalitionalDeviance5,N=50)[[50]]$Agents
  Ss <- data.frame(NewRep=as.numeric(Ss[,"NewRep"]),Group=row.names(Ss))
  aggregate(.~Group,data=Ss, FUN=sum)
  #Notice after 50 rounds, the devil [=King of Liars] has actually become the two bottommost liars, as they represent the most significant source of confusion.
  #Team 'True' wins via stoicism

  #[3] Recursive Friendly Fire - a sub-coalition forms to defect, but a sub-coalition of this coalition forms to defect again.
  Scenarios$CoalitionalDeviance6 <- rbind(c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1), #10
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1),
                                          c(1,1,0,0,1), #15 (60%)
                                          
                                          #Coalition 1, backstabbing Truth to game contract 3
                                          c(0,0,0,1,0), #1 - Friendly Fire
                                          c(1,1,1,0,1),
                                          c(1,1,1,0,1),
                                          c(1,1,1,0,1),
                                          c(1,1,1,0,1),
                                          c(1,1,1,0,1), #6 (24%)
                                          
                                          #Coalition 2, 'backstabbing' Coalition 1 to game contract 4
                                          c(0,0,1,0,0), #1 - Friendly Fire
                                          c(1,1,0,1,1),
                                          c(1,1,0,1,1),
                                          c(1,1,0,1,1)) #4 (16%)

  row.names(Scenarios$CoalitionalDeviance6) <- c(rep('Truth',15),rep('Lie 1',6),rep('Lie 2',4))
  Factory(Scenarios$CoalitionalDeviance6)
  CompareIncentives(Scenarios$CoalitionalDeviance6)
  #fantastic sucess...Lie 2 loses less

  #clearly, the Nash Equilibrium
  Scenarios$CoalitionalDeviance7 <- Scenarios$CoalitionalDeviance6[1:21,]
  Scenarios$CoalitionalDeviance7 <- rbind(Scenarios$CoalitionalDeviance7, rbind(
                                                                              'Truth 2'=c(1,1,0,0,1),
                                                                              'Truth 2'=c(1,1,0,0,1),
                                                                              'Truth 2'=c(1,1,0,0,1),
                                                                              'Truth 2'=c(1,1,0,0,1)))
  Factory(Scenarios$CoalitionalDeviance7)
  CompareIncentives(Scenarios$CoalitionalDeviance7)

  # [4] Passive - Sideways expansion by 2 contracts
  Scenarios$CoalitionalDeviance8 <- cbind(Scenarios$CoalitionalDeviance2,Scenarios$CoalitionalDeviance2[,1:2])
  Factory(Scenarios$CoalitionalDeviance8)
  CompareIncentives(Scenarios$CoalitionalDeviance8)   
  #Success, larger number of contracts makes this attack improbable.

  Scenarios$CoalitionalDeviance9 <- cbind(Scenarios$CoalitionalDeviance2,
                                          Scenarios$CoalitionalDeviance2,
                                          Scenarios$CoalitionalDeviance2,
                                          Scenarios$CoalitionalDeviance2[,-3])
  Factory(Scenarios$CoalitionalDeviance9)
  CompareIncentives(Scenarios$CoalitionalDeviance9)
  #The attack must expand proportionally.


Factory(Scenarios$CluelessControl)
Factory(Scenarios$CluelessTest)
#Finding: 2 falls from tie at 5th .11 to a tie at 7th with .07; no impact on other results: success.

#Note: Must be a discrete set of options: c(1,0,NA,.5)    ---- !!! by extention, Catch must be implemented in FillNA. Indeed, in this example our lazy character is punished twice.
#otherwise there will likely be pragmatic individuals who rationally deviate to answers like ~.85 or ~.92 or some nonsense. [obviously]

Factory(Scenarios$Inchoherence)
Factory(Scenarios$Inchoherence2)
#interesting behavior, but incentive compatible, particularly given low Schelling Salience
#incentive to switch to the consensus .5

Factory(Scenarios$PerCon)
#No problems.

Factory(Scenarios$Gaming)
CompareIncentives(Scenarios$Gaming)
#more or less what i expected


Factory(Scenarios$Missing1)
Factory(Scenarios$Missing2)
Factory(Scenarios$Missing3)
Factory(Scenarios$Missing4)
Factory(Scenarios$Missing5)
#Works


Factory(Scenarios$Riven)
Factory(Scenarios$Riven2)
#

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



# [ Additive Reputation ] Is reputation completely additive? - Yes, now.

Mar1 <- M1
r1 <- rep(1/6,6)

Mar2 <- M1[-6,]
r2 <- c(1/6, 1/6, 1/6, 1/6, 2/6)

Mar3 <- M1[c(1,2,4,5),]
r3 <- c( 2/6, 1/6, 1/6, 2/6)

Mar4 <- M1[c(1,2,4,5,6),]
r4 <- c( 2/6, 1/6, 1/6, 1/6, 1/6)

Factory(Mar1,Rep=r1)$Agents
Factory(Mar2,Rep=r2)$Agents
Factory(Mar3,Rep=r3)$Agents
Factory(Mar4,Rep=r4)$Agents

#Is reputation additive? Yes (excluding NA-born effects, we could correct with Rep/mean(Rep) but NA is not part of equilibrium so it shouldnt matter).


Factory(Mg)$Agents[,c("OldRep","ThisRep","SmoothRep")]
Factory(Mg2)$Agents[,c("OldRep","ThisRep","SmoothRep")]
#True 1 of group 2 skyrockets ahead, as desired.

#upon reflection, I dont think this 'problem' is particularly bad.




# [ Scaling - What are the computational limits (on a normal machine)?]
#Many improvements can be made, of course.

TestLimit <- function(n1,n2,AddNa=1) {
  M_huge <- matrix(round(runif(n1*n2)),n1,n2)
  if(AddNa==1) M_huge[sample(1:(n1*n2),size=(n1*n2)/3)] <- NA
  print(Factory(M_huge))
}



system.time(print("1"))
system.time(TestLimit(100,10))
system.time(TestLimit(1000,100))
# user  system elapsed 
# 0.66    0.00    0.65

# system.time(TestLimit(10000,1000))
# user  system elapsed 
# 135.03    0.67  135.84

# system.time(TestLimit(100000,100))
# user  system elapsed 
# 86.28    0.13   86.42 

# system.time(TestLimit(100000,10))
# user  system elapsed 
# 5.66    0.03    5.66 
# registerDoParallel(cores=4)

# Ten million - 10,000,000. That's pretty big
# 
# system.time(TestLimit(5000,500))
# user  system elapsed 
# 13.53    0.02   13.52 

#Solutions

# [1] - cap the number of rows
  # in its current state, it is basically unlimited - unrealistic
  # the first 100,000 votes are probably decentralized enough ...how low should this number go? (can be a f[ncol(Vmatrix)])
  # given that reputation is fully additive, this would discourage the spreading of reputations
  # this would also solve the "dust bust" question (ie suck up any accounts with tiny dust amounts of reputation)
  # can add the slow retarget to make this grow over the next thousand years (every 4 years?)

#after simply listing the specifics of this solution I realize it is the best candidate

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

# [20 - Discourage "Obvious Outcome" Contracts by fee for open interest (more disagreement)]

### 




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

# temp <- unlist(lapply(1:100,FUN=function(x) Ask(M10a)))
# hist(temp)

#see Governance
# # [12] Create a New contract...it should cost(?)
# NewContract <- function(M) { #This is going to rely on a time dimension I havent implemented yet
# }
# 
# OpenInterest <- function(M,c) {
#   
# }

# [11] [Done] Ask
# [12] NewContract
# [13] Open Interest - Two disagreeing parties each pay Ai (i in 1,2 ; Sum(A)=1) to mint two new coins -- eventually redeemable for 0 and 1-FEEepsilon .

# [14] Subsidized Events - Principals paying Agents to influence the outcome of contracts.


# [14a] A market for an event will allow it's occurance to be noted by the Factory after it's occurance.
# [14b] Partition a 'Verification Space' (private information known only to the agent: date, time, colour, etc).
# [14c] Allow private bets within the Verification Space - possibly a second set of Colored Coins "specical coin".
# [14d] At EoC, people collect proportional to their holdings of insider-information coins.
# [14e] Assurance contracts to allow anyone to fund a 'club good' event.



#Plot
PlotJ(M1)




