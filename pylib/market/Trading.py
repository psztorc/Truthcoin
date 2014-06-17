# -*- coding: utf-8 -*-
"""
Created on Sat Mar  8 20:39:36 2014

@author: Psztorc
"""

# "import Markets"
runfile('C:/Users/Psztorc/Documents/GitHub/Truthcoin/pylib/market/Markets.py', wdir=r'C:/Users/Psztorc/Documents/GitHub/Truthcoin/pylib/market')


### Trading Protocol and Market Maker ###


#Global Parameter
global FeeRate
FeeRate = .01


## Simple Market Info ##
def ShowPrices(ID):
    """Takes a Market and ID and returns the current market price."""
    S = exp(Markets[ID]['Shares']/Markets[ID]['B'])
    return(S/sum(S))


def QueryMove(ID,State,P):
    """How many shares would I need to buy of'ID'-'State' to move the probability to 'P'?"""
    
    State = State - 1  #Python counting from zero
    S = exp(Markets[ID]['Shares']/Markets[ID]['B'])
    
    #Need to exclude a state (more complicated to code in Python but fasters)
    Temp = ma.array(S, mask=False)
    Temp.mask[State] = True
    
    Sstar = Markets[ID]['B']* ( log(P/(1-P)) + log(sum(Temp)) )
    Marginal = Sstar - Markets[ID]['Shares'][State]
    return(Marginal)



def QueryCost(ID,State,S):
    """What price will the market-maker demand for a purchase of S shares? """ 
    
    State = State - 1  #Python counting from zero
    B = Markets[ID]['B']
  
    #Original Case
    S0 = copy( Markets[ID]['Shares'] )
    LMSR = B*log(sum(exp(S0/B)))
  
    #Proposed Adjustment
    S1 = copy(S0)
    S1[State] = S1[State] + S
    LMSR2 = B*log(sum(exp(S1/B)))
  
    return( LMSR2-LMSR )



def QueryMoveCost(ID,State,P):
    """How much would it cost to set the probability to P?"""
    NewS = QueryMove(ID,State,P) 
    return( QueryCost(ID,State, NewS ) )




QueryMoveCost('Obama2012',1,.7)
QueryMoveCost('Obama2012',1,.7)


## User Accounts ##
global Users

Users = {} #Critical Step...creates (blank) user-space.

def CreateAccount(Name,Qfunds):
    """Creates an account filled with money.
    Obviously, this is a crucial step which will require (!) verification of Bitcoin payments, an X-confirmation delay, etc. For testing we allow unconstrained (free/infinite) cash.
    These accounts have simple toy names, actual accounts will probably be the bitcoin addresses themselves."""
    Users.update( {Name : {'Cash': Qfunds}})
    
CreateAccount('Bob',10)
CreateAccount('Alice',200)




## Buying and Selling Shares ##

def Buy(uID,ID,State,P,Verbose=True):
    """Takes User Id, Market Id, Market State, and Probability Target, and deducts funds from the user such that
    the relevant market's state is the probability target."""
  
    #Calculate Required Cost
    BaseCost = QueryMoveCost(ID,State,P) #trade cost assuming no fees
    Fee = BaseCost*FeeRate               #fees for buying only (global parameter set at top)
    TotalCost = BaseCost + Fee           #Total cost including Fee

    MarginalShares = QueryMove(ID,State,P)
    if MarginalShares<0:
        return("Price already exceeds target. Sell shares or buy a Mutually Exclusive State (MES).")
    if Verbose:
        print("Calulating Required Shares..." + str(MarginalShares))
        print("Determining Cost of Trade..." + str(BaseCost))
        print("Fee: " + str(Fee))
      
    #Reduce Funds, add Shares
    if Users[uID]['Cash'] < TotalCost:
        return("Insufficient Funds")
    StateName = 'State ' + str(State) # As far as the user is concerned, State 1 is the first state (not State 0 as python is concerned)
    Users[uID]['Cash'] =  Users[uID]['Cash'] - TotalCost 
    #Is there an entry for this already?
    try:
        OldShares = Users[uID][ID][StateName]
        Users[uID][ID][StateName] = OldShares + MarginalShares
    except KeyError: # (first time buying in this state)
        OldShares = 0
        try:
            Users[uID][ID].update( {StateName: MarginalShares} )
        except KeyError: # (first time buying in this market)
            Users[uID].update( {ID: {StateName: MarginalShares}} )
    
    #Credit Funds, add Shares
    Markets[ID]['Balance'] = Markets[ID]['Balance'] + BaseCost
    Markets[ID]['FeeBalance'] = Markets[ID]['FeeBalance'] + Fee
    FlatMarket = copy(Markets[ID]['Shares']).flatten()
    FlatMarket[(State-1)] = FlatMarket[(State-1)] + MarginalShares
    Markets[ID]['Shares'] = FlatMarket.reshape( Markets[ID]['Shares'].shape ) #restore original shape
  
    if Verbose:
        print("Bought " + str(MarginalShares) + " for " + str(TotalCost) + ".")
    return((MarginalShares,TotalCost))
    
def Sell(uID,ID,State,P,Verbose=True):
    """Takes User Id, Market Id, Market State, and Probability Target, and deducts funds from the user such that
    the relevant market's state is the probability target."""
  
    #Calculate Required Cost
    BaseCost = QueryMoveCost(ID,State,P) #trade cost assuming no fees
    TotalCost = BaseCost                 #No fees for selling

    MarginalShares = QueryMove(ID,State,P)
    if MarginalShares>0:
        return("Price already exceeds target. Sell shares or buy a Mutually Exclusive State (MES).")
    if Verbose:
        print("Calulating Required Shares..." + str(MarginalShares))
        print("Determining Cost of Trade..." + str(BaseCost))
      
    #Reduce Shares, add Funds
    StateName = 'State ' + str(State) # As far as the user is concerned, State 1 is the first state (not State 0 as python is concerned)  
    try:
        OldShares = Users[uID][ID][StateName]
    except KeyError:
        return("Zero Shares")
    if OldShares < (-1*MarginalShares): #Remember, 'marginal shares' are negative when selling.
        return("Insufficient Shares")
    Users[uID][ID][StateName] = OldShares + MarginalShares #Reduce Shares (shares are negative)    
    Users[uID]['Cash'] =  Users[uID]['Cash'] - TotalCost   #Add Funds (costs are negative)

    #Remove Funds and Shares from Market
    Markets[ID]['Balance'] = Markets[ID]['Balance'] + BaseCost
    FlatMarket = copy(Markets[ID]['Shares']).flatten()
    FlatMarket[(State-1)] = FlatMarket[(State-1)] + MarginalShares
    Markets[ID]['Shares'] = FlatMarket.reshape( Markets[ID]['Shares'].shape ) #restore original shape
  
    if Verbose:
        print("Sold " + str(-1*MarginalShares) + " for " + str(-1*TotalCost) + ".")
    return((MarginalShares,TotalCost))



Buy('Bob','Obama2012',1,.7,True)
ShowPrices('Obama2012')
Sell('Bob','Obama2012',1,.5,True)
ShowPrices('Obama2012')

Buy('Bob','Obama2012',1,.7,True)
ShowPrices('Obama2012')
Buy('Bob','Obama2012',1,.9,True)
ShowPrices('Obama2012')
Sell('Bob','Obama2012',1,.5,True)
ShowPrices('Obama2012')

Sell('Bob','Obama2012',1,.4,True)
ShowPrices('Obama2012')
Buy('Bob','Obama2012',1,.9999,True)
ShowPrices('Obama2012')

#Upon maturation (Voting), shares get swapped for currency.