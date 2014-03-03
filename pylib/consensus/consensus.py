# -*- coding: utf-8 -*-
"""
Created on Sun Mar  2 20:52:33 2014

@author: Psztorc
"""

import custommath
#CustomMathTest() #True

#Consensus Mechanism
#This is the mechanism that, theoretically,
 #   1] allows the software to determine the state of Decisions truthfully, and
 #   2] only allows an efficient number of most-traded-upon-Decisions.

#Alpha = Smoothing Parameter

# #Function Library
def GetRewardWeights(M, Rep=-1, Alpha=.1, Verbose=False):
    """Calculates the new reputations using Weighted Principal Components Analysis"""
    
    if type(Rep) is int:
        Rep = DemocracyCoin(Mat)     
    
    if Verbose:
        print("****************************************************")
        print("Begin 'GetRewardWeights'")
        print("Inputs...")
        print("Matrix:")
        print(M)
        print("")
        print("Reputation:")
        print(Rep)
        print("")
    
    Results = WeightedPrinComp(M,Rep)
    
    Rep = GetWeight(Rep)  #Need the old reputation back for the rest of this.
    
    FirstLoading = Results[0] #The first loading is designed to indicate which Decisions were more 'agreed-upon' than others. 
    FirstScore   = Results[1] #The scores show loadings on consensus (to what extent does this observation represent consensus?)
 
    if Verbose:
        print("First Loading:",end=' '); print(FirstLoading); print("First Score:",end=' '); print(FirstScore)
        
    #PCA, being an abstract factorization, is incapable of determining anything absolute.
    #Therefore the results of the entire procedure would theoretically be reversed if the average state of Decisions changed from TRUE to FALSE.
    #Because the average state of Decisions is a function both of randomness and the way the Decisions are worded, I quickly check to see which
    #  of the two possible 'new' reputation vectors had more opinion in common with the original 'old' reputation.
    #  I originally tried doing this using math but after multiple failures I chose this ad hoc way.
    
    Set1 =  FirstScore+abs(min(FirstScore))
    Set2 =  FirstScore-max(FirstScore) 
    
    Old = dot(Rep.T,M)
  
    New1 = GetWeight(dot(Set1,M))
    New2 = GetWeight(dot(Set2,M))
    
    #Difference in Sum of squared errors, if >0, then New1 had higher errors (use New2), and conversely if <0 use 1.
    RefInd = sum( (New1-Old)**2) -  sum( (New2-Old)**2)
    
    if(RefInd<=0):
        AdjPrinComp = Set1  
    if(RefInd>0):
        AdjPrinComp = Set2  
    
    if Verbose:
        print("")
        print("Estimations using: Previous Rep, Option 1, Option 2")
        print( vstack([Old, New1, New2]).T )
        print("")
        print("Previous period reputations, Option 1, Option 2, Selection")
        print( vstack([ Rep.T, Set1, Set2, AdjPrinComp]).T )
  
    #Declared here, filled below (unless there was a perfect consensus).
    RowRewardWeighted = Rep # (set this to uniform if you want a passive diffusion toward equality when people cooperate [not sure why you would]). Instead diffuses towards previous reputation (Smoothing does this anyway).
    if(max(abs(AdjPrinComp))!=0):
        RowRewardWeighted = GetWeight( AdjPrinComp * (Rep/mean(Rep)).T ) #Overwrite the inital declaration IFF there wasn't perfect consensus.
    #note: Rep/mean(Rep) is a correction ensuring Reputation is additive. Therefore, nothing can be gained by splitting/combining Reputation into single/multiple accounts.
          
    #Freshly-Calculated Reward (Reputation) - Exponential Smoothing
    #New Reward: RowRewardWeighted
    #Old Reward: Rep
    SmoothedR = Alpha*(RowRewardWeighted) + (1-Alpha)*Rep.T
      
    if Verbose:
        print("")
        print("Corrected for Additivity , Smoothed _1 period")
        print( vstack([RowRewardWeighted, SmoothedR]).T )
      
    #Return Data
    Out = {"FirstL":FirstLoading, "OldRep":Rep.T, "ThisRep":RowRewardWeighted, "SmoothRep":SmoothedR}  
    #Keep the factors and time information along for the ride, they are interesting.
    
    return(Out)
    
VotesUM = array([[1,1,0,0], 
               [1,0,0,0],
               [1,1,0,0],
               [1,1,1,0],
               [0,0,1,1],
               [0,0,1,1]])
Votes = ma.masked_array(VotesUM, isnan(VotesUM))
#
#x = GetRewardWeights(Votes)
#print(x)
#print("")
#print(vstack([x["OldRep"],x["ThisRep"],x["SmoothRep"]]))

def GetDecisionOutcomes(Mtemp, Rep=-1, Verbose=False):
    """Determines the Outcomes of Decisions based on the provided reputation (weighted vote)."""
    
    if type(Rep) is int:
        Rep = DemocracyCoin(Mat) 
        
    if Verbose:
        print("****************************************************") ; print("Begin 'GetDecisionOutcomes'")
    
    RewardWeightsNA = Rep
    DecisionOutcomes_Raw  = [] #Declare this (filled below)
    
    for i in range(Mtemp.shape[1]):
        #For each column:            
        Row = ReWeight( RewardWeightsNA[ -Mtemp[...,i].mask ] )   #The Reputation of the row-players who DID provide judgements, rescaled to sum to 1.
        Col =  Mtemp[ -Mtemp[...,i].mask ,i]                #The relevant Decision with NAs removed. ("What these row-players had to say about the Decisions they DID judge.")
        
        DecisionOutcomes_Raw.append(dot(Col,Row))            #Our Current best-guess for this Decision (weighted average)  
        
        if(Verbose):
            print("** **"); print("Column:", end=" "); print(i); print(Row); print(Col); print("Consensus:"); print(DecisionOutcomes_Raw[i])

    #Output
    return( array(DecisionOutcomes_Raw).T )
    

#a = GetDecisionOutcomes(Votes)
#print(a)
#
#M3 = ma.masked_array(Votes,isnan(Votes))
#M3.mask[1,1] = True
#
#print(GetDecisionOutcomes(M3,Verbose=True))

def FillNa(Mna, Rep=-1, CatchP=.1, Verbose=False):
    """Uses exisiting data and reputations to fill missing observations.
    Essentially a weighted average using all availiable non-NA data.
    How much should slackers who arent voting suffer? I decided this would depend on the global percentage of slacking."""
    
    if type(Rep) is int:
        Rep = DemocracyCoin(Mat) 
         
    Mnew = ma.copy(Mna) #Declare (in case no Missing values, Mnew and Mna will be the same)
     
    if(sum(Mna.mask)>0):
    #Of course, only do this process if there ARE missing values.
     
        if(Verbose):
            print("Missing Values Detected. Beginning presolve using availiable values.")
             
        #Decision Outcome - Our best guess for the Decision state (FALSE=0, Ambiguous=.5, TRUE=1) so far (ie, using the present, non-missing, values).
        DecisionOutcomes_Raw = GetDecisionOutcomes(Mna,Rep,Verbose)
         
        #Fill in the predictions to the original M
        NAmat = Mna.mask   #Defines the slice of the matrix which needs to be edited.
        Mnew[NAmat] = 0     #Erase the NA's
        
        #Slightly complicated:
        NAsToFill = dot( NAmat , diag(DecisionOutcomes_Raw[0]) )
        #   This builds a matrix whose columns j:
            #          NAmat was false (the observation wasn't missing)     ...  have a value of Zero
            #          NAmat was true (the observation was missing)         ...  have a value of the jth element of DecisionOutcomes.Raw (the 'current best guess') 
        Mnew = Mnew + NAsToFill
        #This replaces the NAs, which were zeros, with the predicted Decision outcome.
         
        if(Verbose):
            print("Missing Values:"); print(NAmat); print("Imputed Values:"); print(NAsToFill)
        
        #Appropriately force the predictions into their discrete (0,.5,1) slot. (continuous variables can be gamed).
        for i in range(Mnew.shape[0]):
            for j in range(Mnew.shape[1]):
                Mnew[i][j] = Catch(j,CatchP)
        
        if(Verbose):
            print("Binned:"); print(Mnew) ; print("*** ** Missing Values Filled ** ***")
            
    return(Mnew)
        
#q = FillNa(M3,Verbose=True)
        
        
##Putting it all together:
def Factory(M0, Rep=-1, CatchP=.1, MaxRow=5000, Verbose=False):
    
    #Main Routine
    #Fill the default reputations (egalitarian) if none are provided...unrealistic and only for testing.
    if type(Rep) is int:
        Rep = DemocracyCoin(Mat) 
        
    #Handle Missing Values
    Filled = FillNa(M0, Rep, CatchP, Verbose)
    
    ## Consensus - Row Players 
    #New Consensus Reward
    PlayerInfo = GetRewardWeights(Filled, Rep, .1, Verbose)
    AdjLoadings = PlayerInfo['FirstL']
  
    ##Column Players (The Decision Creators)
    #Calculation of Reward for Decision Authors
    # Consensus - "Who won?" Decision Outcome 
    DecisionOutcomes_Raw = dot( PlayerInfo['SmoothRep'] , Filled ) #Simple matrix multiplication ... highest information density at RowBonus, but need DecisionOutcomes.Raw to get to that
  
    # Quality of Outcomes - is there confusion?
    Certainty = abs(2*(DecisionOutcomes_Raw-.5))      # .5 is obviously undesireable, this function travels from 0 to 1 with a minimum at .5
    ConReward = GetWeight(Certainty)                  #Grading Authors on a curve.
    Avg_Certainty = mean(Certainty)                   #How well did beliefs converge?
  
    #The Outcome Itself
    DecisionOutcome_Final = []
    for i in DecisionOutcomes_Raw[0]:
        DecisionOutcome_Final.append(Catch(i,CatchP))
 
    if(Verbose):
        print("*Decision Outcomes Sucessfully Calculated*")
        print("Raw Outcomes, Certainty, AuthorPayoutFactor"); print( hstack([DecisionOutcomes_Raw,Certainty,ConReward]))
  
  
    ## Participation
  
    #Information about missing values
    NAmat = M0*0 
    NAmat[NAmat.mask] = 1 #indicator matrix for missing
  
    #Participation Within Decisions (Columns) 
    # % of reputation that answered each Decision
    ParticipationC = 1-dot(PlayerInfo['SmoothRep'] , NAmat)
  
    #Participation Within Agents (Rows) 
    # Many options
  
    # 1- Democracy Option - all Decisions treated equally.
    ParticipationR  = 1-( NAmat.sum(axis=1) / NAmat.shape[1] )
  
    #General Participation
    PercentNA = 1-mean(ParticipationC)
    #(Possibly integrate two functions of participation?) Chicken and egg problem...
  
    if(Verbose):
        print("*Participation Information*")
        print("Voter Turnout by question"); print( ParticipationC )
        print("Voter Turnout across questions"); print ( ParticipationR )
  
    ## Combine Information
    #Row
    NAbonusR = GetWeight(ParticipationR)
    RowBonus = (NAbonusR*(PercentNA))+(PlayerInfo['SmoothRep']*(1-PercentNA))
  
    #Column
    NAbonusC = GetWeight(ParticipationC)
    ColBonus = (NAbonusC*(PercentNA))+(ConReward*(1-PercentNA))  
  
    #Present Results
    Output = {"Original": M0, "Filled": Filled,
        "Agents": {
            "OldRep": PlayerInfo['OldRep'],
            "ThisRep": PlayerInfo['ThisRep'],
            "SmoothRep": PlayerInfo['SmoothRep'],
            "NArow": NAmat.sum(axis=1),
            "ParticipationR": ParticipationR,
            "RelativePart": NAbonusR,
            "RowBonus": RowBonus
            },
        "Decisions": {
            "First Loading": AdjLoadings,
            "DecisionOutcomes_Raw": DecisionOutcomes_Raw,
            "Consensus Reward": ConReward,
            "Certainty": Certainty,
            "NAs Filled": NAmat.sum(axis=0),
            "ParticipationC": ParticipationC,
            "Author Bonus": ColBonus,
            "DecisionOutcome_Final": DecisionOutcome_Final
            },
        "Participation": (1-PercentNA), #Using this to set inclusion fees.
        "Certainty": Avg_Certainty #Using this to set Catch Parameter)
        }
      
    return(Output)
  

q = Factory(Votes)
print(q)
z = q['Agents']['RowBonus']
print(z)

#Long-Term
def Chain(X,N=2,ThisRep=-1):
    #Repeats factory process N times
    if type(ThisRep) is int:
        ThisRep = DemocracyCoin(Mat) 
     
    Output = []
    for i in range(N):
        
        print(ThisRep) 
        Output.append( Factory(X,Rep=ThisRep) )
        ThisRep = (Output[i]['Agents']['RowBonus']).T
               
        
    return(Output)

q = Chain(Votes)
print(q)
print(len(q))

#Notes

#Voting Across Time
#Later Votes could count more
#! ...simple change = DecisionOutcome.Final becomes exponentially smoothed result of previous chains.
#! require X number of chains (blocks) before the outcome is officially determined .. or, continue next round if ~ .5, or Decisions.Raw is within a threshold ( .2 to .8)
# Would need:
# 1] Percent Voted
# 2] Time Dimension of blocks.