#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Consensus mechanism for Truthcoin.

This is the mechanism that, theoretically:
  1. Allows the software to determine the state of Decisions truthfully, and
  2. Only allows an efficient number of most-traded-upon-Decisions.

"""
from __future__ import division, print_function
from numpy import *
from numpy.linalg import *
from numpy.random import random_integers
from custommath import *

__author__     = "Paul Sztorc and Jack Peterson"
__maintainer__ = "Paul Sztorc"
__email__      = "truthcoin@gmail.com"

# Alpha = Smoothing Parameter

# Function Library
def GetRewardWeights(M, Rep=-1, Alpha=.1, Verbose=False):
    """Calculates the new reputations using Weighted Principal Components Analysis"""
    
    if type(Rep) is int:
        Rep = DemocracyCoin(M)     
    
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

    New1 = dot(GetWeight(Set1), M)
    New2 = dot(GetWeight(Set2), M)
    
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


def GetDecisionOutcomes(Mtemp, ScaledIndex, Rep=-1, Verbose=False):
    """Determines the Outcomes of Decisions based on the provided reputation (weighted vote)."""

    if type(Rep) is int:
        Rep = DemocracyCoin(Mtemp)

    if Verbose:
        print('****************************************************')
        print("Begin 'GetDecisionOutcomes'")

    RewardWeightsNA = Rep
    DecisionOutcomes_Raw = []

    # For each column:
    for i in range(Mtemp.shape[1]):

        # The Reputation of the row-players who DID provide
        # judgements, rescaled to sum to 1.
        Row = ReWeight(RewardWeightsNA[-Mtemp[..., i].mask])

        # The relevant Decision with NAs removed.
        # ("What these row-players had to say about the Decisions
        # they DID judge.")
        Col = Mtemp[-Mtemp[..., i].mask, i]

        # Discriminate Based on Contract Type
        if not ScaledIndex[i]:
            # Our Current best-guess for this Binary Decision (weighted average)
            DecisionOutcomes_Raw.append(dot(Col, Row))
        else:
            # Our Current best-guess for this Scaled Decision (weighted median)
            wmed = WeightedMedian(Row[:,0], Col)
            DecisionOutcomes_Raw.append()

        if Verbose:
            print('** **')
            print('Column:')
            print(i)
            print(Row)
            print(Col)
            print('Consensus:')
            print(DecisionOutcomes_Raw[i])

    # Output
    return array(DecisionOutcomes_Raw).T


def FillNa(Mna, ScaledIndex, Rep=-1, CatchP=.1, Verbose=False):
    """Uses exisiting data and reputations to fill missing observations.
    Essentially a weighted average using all availiable non-NA data.
    How much should slackers who arent voting suffer? I decided this would
    depend on the global percentage of slacking.
    """
    if type(Rep) is int:
        Rep = DemocracyCoin(Mat)

    # Declare (in case no Missing values, Mnew and Mna will be the same)
    Mnew = ma.copy(Mna)

    # Of course, only do this process if there ARE missing values.
    if sum(Mna.mask) > 0:
        if Verbose:
            print('Missing Values Detected. Beginning presolve using availiable values.')

        # Decision Outcome -
        # Our best guess for the Decision state (FALSE=0, Ambiguous=.5, TRUE=1)
        # so far (ie, using the present, non-missing, values).
        DecisionOutcomes_Raw = GetDecisionOutcomes(Mna, ScaledIndex, Rep, Verbose)

        # Fill in the predictions to the original M
        NAmat = Mna.mask  # Defines the slice of the matrix which needs to be edited.
        Mnew[NAmat] = 0  # Erase the NA's

        # Slightly complicated:
        NAsToFill = dot(NAmat, diag(DecisionOutcomes_Raw[0]))
        
        # This builds a matrix whose columns j:
        #   NAmat was false (the observation wasn't missing) - have a value of Zero
        #   NAmat was true (the observation was missing)     - have a value of the jth element of DecisionOutcomes.Raw (the 'current best guess')
        Mnew = Mnew + NAsToFill
        # This replaces the NAs, which were zeros, with the predicted Decision outcome.
        if Verbose:
            print('Missing Values:')
            print(NAmat)
            print('Imputed Values:')
            print(NAsToFill)

        # Appropriately force the predictions into their discrete
        # (0,.5,1) slot. (continuous variables can be gamed).
        rows, cols = Mnew.shape
        for i in range(rows):
            for j in range(cols):
                if not ScaledIndex[j]:
                    Mnew[i][j] = Catch(Mnew[i][j], CatchP)

        if Verbose:
            print('Binned:')
            print(Mnew)
            print('*** ** Missing Values Filled ** ***')

    return Mnew


def Factory(M0, Scales=None, Rep=-1, CatchP=.1, MaxRow=5000, Verbose=False):
    """Main routine: putting it all together.

    Args:
      M0 (ma.masked_array): votes matrix; rows = voters, columns = Decisions.
      Scales (list): list of dicts for each Decision
        {
          scaled (bool): True if scalar, False if binary (boolean)
          min (float): minimum allowed value (0 if binary)
          max (float): maximum allowed value (1 if binary)
        }

    Returns:
      dict: consensus results

    """
    # Fill the default reputations (egalitarian) if none are provided...
    # unrealistic and only for testing.
    if type(Rep) is int:
        Rep = DemocracyCoin(M0)

    # Fill the default scales (binary) if none are provided.
    # In practice, this would also never be used.
    if Scales is None:
        ScaledIndex = [False] * M0.shape[1]
        MScaled = M0
    else:
        ScaledIndex = [scale["scaled"] for scale in Scales]
        MScaled = Rescale(M0, Scales)

    # Handle Missing Values
    Filled = FillNa(MScaled, ScaledIndex, Rep, CatchP, Verbose)

    # Consensus - Row Players
    # New Consensus Reward
    PlayerInfo = GetRewardWeights(Filled, Rep, .1, Verbose)
    AdjLoadings = PlayerInfo['FirstL']

    # Column Players (The Decision Creators)
    # Calculation of Reward for Decision Authors
    # Consensus - "Who won?" Decision Outcome    
    # Simple matrix multiplication ... highest information density at RowBonus,
    # but need DecisionOutcomes.Raw to get to that
    DecisionOutcomes_Raw = dot(PlayerInfo['SmoothRep'], Filled).squeeze()

    # Discriminate Based on Contract Type
    ncols = Filled.shape[1]
    for i in range(ncols):
        # Our Current best-guess for this Scaled Decision (weighted median)
        if ScaledIndex[i]:
            DecisionOutcomes_Raw[i] = WeightedMedian(Filled[:,i], PlayerInfo["SmoothRep"])

    # .5 is obviously undesireable, this function travels from 0 to 1
    # with a minimum at .5
    Certainty = abs(2 * (DecisionOutcomes_Raw - .5))

    # Grading Authors on a curve.
    ConReward = GetWeight(Certainty)

    # How well did beliefs converge?
    Avg_Certainty = mean(Certainty)

    # The Outcome Itself
    # Discriminate Based on Contract Type
    DecisionOutcome_Adj = []
    for i, raw in enumerate(DecisionOutcomes_Raw):
        DecisionOutcome_Adj.append(Catch(raw, CatchP))
        if ScaledIndex[i]:
            DecisionOutcome_Adj[i] = raw

    DecisionOutcome_Final = []
    for i, raw in enumerate(DecisionOutcomes_Raw):
        DecisionOutcome_Final.append(DecisionOutcome_Adj[i])
        if ScaledIndex[i]:
            DecisionOutcome_Final[i] *= (Scales[i]["max"] - Scales[i]["min"])

    if Verbose:
        print('*Decision Outcomes Sucessfully Calculated*')
        print('Raw Outcomes, Certainty, AuthorPayoutFactor')
        print(hstack([DecisionOutcomes_Raw, Certainty, ConReward]))

    # Participation
    # Information about missing values
    NAmat = M0 * 0
    NAmat[NAmat.mask] = 1  # indicator matrix for missing

    # Participation Within Decisions (Columns)
    # % of reputation that answered each Decision
    ParticipationC = 1 - dot(PlayerInfo['SmoothRep'], NAmat)

    # Participation Within Agents (Rows)
    # Many options
    # 1- Democracy Option - all Decisions treated equally.
    ParticipationR = 1 - NAmat.sum(axis=1) / NAmat.shape[1]

    # General Participation
    PercentNA = 1 - mean(ParticipationC)

    # (Possibly integrate two functions of participation?) Chicken and egg problem...
    if Verbose:
        print('*Participation Information*')
        print('Voter Turnout by question')
        print(ParticipationC)
        print('Voter Turnout across questions')
        print(ParticipationR)

    # Combine Information
    # Row
    NAbonusR = GetWeight(ParticipationR)
    RowBonus = NAbonusR * PercentNA + PlayerInfo['SmoothRep'] * (1 - PercentNA)

    # Column
    NAbonusC = GetWeight(ParticipationC)
    ColBonus = NAbonusC * PercentNA + ConReward * (1 - PercentNA)

    # Present Results
    Output = {  # Using this to set inclusion fees
                # Using this to set Catch Parameter
        'Original': M0.base,
        'Filled': Filled.base,
        'Agents': {
            'OldRep': PlayerInfo['OldRep'][0],
            'ThisRep': PlayerInfo['ThisRep'][0],
            'SmoothRep': PlayerInfo['SmoothRep'][0],
            'NArow': NAmat.sum(axis=1).base,
            'ParticipationR': ParticipationR.base,
            'RelativePart': NAbonusR.base,
            'RowBonus': RowBonus.base,
            },
        'Decisions': {
            'First Loading': AdjLoadings,
            'DecisionOutcomes_Raw': DecisionOutcomes_Raw,
            'Consensus Reward': ConReward,
            'Certainty': Certainty,
            'NAs Filled': NAmat.sum(axis=0),
            'ParticipationC': ParticipationC,
            'Author Bonus': ColBonus,
            'DecisionOutcome_Final': DecisionOutcome_Final,
            },
        'Participation': 1 - PercentNA,
        'Certainty': Avg_Certainty,
        }

    return Output


#Long-Term
def Chain(X,N=2,ThisRep=-1):
    #Repeats factory process N times
    if type(ThisRep) is int:
        ThisRep = DemocracyCoin(X) 
     
    Output = []
    for i in range(N):
        
        print(ThisRep) 
        Output.append( Factory(X,Rep=ThisRep) )
        ThisRep = (Output[i]['Agents']['RowBonus']).T
    
    return(Output)


def DisplayResults(FactorObject):
    """Prints the results in a more-readable format. Requires pandas."""
    
    import pandas
    
    q=FactorObject #shorten for convenience
    
    print("")
    print(" Original V.Matrix: ")
    print(q['Original'])
    
    print("")
    print(" Filled V.Matrix: ")
    print(q['Filled'])
    
    print("")
    print("Agents:")
    qA = q['Agents']
    ALabels = qA.keys()
    AData = vstack([ qA["OldRep"],
                   qA["ThisRep"],
                   qA["SmoothRep"],
                   qA["NArow"],
                   qA["ParticipationR"],
                   qA["RelativePart"],
                   qA["RowBonus"]])
    print( pandas.DataFrame(AData,ALabels).T )
    
    print("")
    print("Decisions: ")
    qD = q['Decisions']
    DLabels = qD.keys()
    DData = vstack([ qD["ParticipationC"],
                   qD["First Loading"],
                   qD["Consensus Reward"],
                   qD["DecisionOutcomes_Raw"],
                   qD["Author Bonus"],
                   qD["Certainty"],
                   qD["NAs Filled"],
                   qD["DecisionOutcome_Final"]])             
    print( pandas.DataFrame(DData,DLabels) )
    
    print("")
    print(" Participation: ",end='')
    print(q["Participation"])
    
    print("")
    print(" Certainty: ",end='')
    print(q["Certainty"])
    
    return( q["Participation"] ) #simple estimate of sucess 

def TestConsensus():
    """Verifies function works as required. If False, check comments below for full expected results."""
    
    VotesUM = array([[1,1,0,0], 
               [1,0,0,0],
               [1,1,0,0],
               [1,1,1,0],
               [0,0,1,1],
               [0,0,1,1]])            
    Votes = ma.masked_array(VotesUM, isnan(VotesUM))
    
    Actual = DisplayResults(Factory(Votes))
    Expected = 0.228237569613

    return( round(Actual, 11) == round(Expected, 11) )


if __name__ == "__main__":
    ### TEST
    global Votes
    VotesUM = array([[1,1,0,0], 
                   [1,0,0,0],
                   [1,1,0,0],
                   [1,1,1,0],
                   [0,0,1,1],
                   [0,0,1,1]])            
    Votes = ma.masked_array(VotesUM, isnan(VotesUM))

    TestConsensus()

    ## Speed Test
    import time

    print(time.asctime())
    InitVotesL = random_integers(0,1,(10000*100)).reshape(10000,100)
    VotesL = ma.masked_array(InitVotesL, isnan(InitVotesL))
    print(time.asctime())

    print(time.asctime())
    DisplayResults(Factory(Votes))
    print(time.asctime())

    print(time.asctime())
    DisplayResults(Factory(VotesL))
    print(time.asctime())

    
# "Official" Answers
    
#NOTE: No coin distribution given, assuming democracy [one row, one vote].
#
# Original V.Matrix: 
#[[1 1 0 0]
# [1 0 0 0]
# [1 1 0 0]
# [1 1 1 0]
# [0 0 1 1]
# [0 0 1 1]]
#
# Filled V.Matrix: 
#[[1 1 0 0]
# [1 0 0 0]
# [1 1 0 0]
# [1 1 1 0]
# [0 0 1 1]
# [0 0 1 1]]
#
#Agents:
#   ParticipationR  RowBonus    OldRep  SmoothRep  NArow   ThisRep  \
#0        0.166667  0.282376  0.178238          0      1  0.166667   
#1        0.166667  0.217624  0.171762          0      1  0.166667   
#2        0.166667  0.282376  0.178238          0      1  0.166667   
#3        0.166667  0.217624  0.171762          0      1  0.166667   
#4        0.166667  0.000000  0.150000          0      1  0.166667   
#5        0.166667  0.000000  0.150000          0      1  0.166667   
#
#   RelativePart  
#0      0.178238  
#1      0.171762  
#2      0.178238  
#3      0.171762  
#4      0.150000  
#5      0.150000  
#
#[6 rows x 7 columns]
#
#Decisions: 
#                              0         1         2         3
#ParticipationC         1.000000  1.000000  1.000000  1.000000
#First Loading         -0.539537 -0.457056  0.457056  0.539537
#Consensus Reward       0.438140  0.061860  0.061860  0.438140
#DecisionOutcomes_Raw   0.700000  0.528238  0.471762  0.300000
#Author Bonus           0.438140  0.061860  0.061860  0.438140
#Certainty              0.400000  0.056475  0.056475  0.400000
#NAs Filled             0.000000  0.000000  0.000000  0.000000
#DecisionOutcome_Final  1.000000  0.500000  0.500000  0.000000
#
#[8 rows x 4 columns]
#
# Participation: 1.0
#
# Certainty: 0.228237569613
