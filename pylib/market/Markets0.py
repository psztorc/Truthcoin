# -*- coding: utf-8 -*-
"""
Created on Fri Mar  7 14:15:52 2014

@author: Psztorc
"""

#To do:
#Reconcile hashes with R
#Ensure that Decisions / Markets have been decomposed correctly.

### Market Structure/Example ###

#Load
import hashlib

def Md5(X):
    """MD5 hashes severl different objects"""
    if type(X) is dict:
        Out = hashlib.md5( str(X).encode() ).hexdigest()
    elif type(X) is str:
        try:
            Out = hashlib.md5(X).hexdigest()
        except TypeError: #thrown if object lacks encoding
            Out = hashlib.md5(X.encode()).hexdigest()
    return(Out)
        
    
  
q = Md5("Test string")
print(q)


## Functions to Define/Set Attributes of Markets



## Sample Markets ##
C1 = {'Market':nan,     #hash of c1[-1:-5]
           'Size':nan,         #size of c1[-1:-2] in bytes 
           'Shares':nan,       #initially, zero of course
           'Balance':nan,      #funds in escrow for this Market
           'FeeBalance':nan,   #Transaction Fees Collected
           'State':-2,        # -2 indicates active (ie neither trading nor judging are finished).
           'B':1,            #Liquidity Parameter
           'OwnerAd':"1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",  #the Bitcoin address of the creator of this Market
           'Title':"Obama2012",                             #title - not necessarily unique
           'Description':"Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
           #in practice, this will probably be pretty long.
           'Tags':("Politics, UnitedStates, President, Winner"), #ordinal descriptors
           'D_State': array([                                                       #JSON would probably be easier....
                               [ #d1
                                   ["Did Barack H Obama win the United States 2012 presidential election?",.5] #replace with hash
                               ]      
                           ])
}

C2 = {'Market':nan,
           'Size':nan,
           'Shares':nan,
           'Balance':nan,
           'FeeBalance':nan,
           'State':-2,
           'B':2,
           'OwnerAd':"1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
           'Title':"Dems2016",                 
           'Description':"Democratic Control of the United States federal government following 2016 election.\nThis Market ...",
           'Tags':("Politics, UnitedStates, President, Congress"),

           'D_State': array([
                               [ #d1
                                   ["Did the Democratic Party Candidate win the United States presidential election in 2016?",.5]
                               ],
                               
                               [ #d2
                                   ["Did the Democratic Party win (only) a majority of Senate seats?",.5],
                                   ["Did the Democratic Party win (only) a three-fifths supermajority of Senate seats (60+)?",.5],
                                   ["Did the Democratic Party win a two-thirds supermajority of Senate seats (67+)?",.5]
                               ],
                               
                               [ #d3
                                   ["Did the Democratic Party win (only) a majority of House seats?",.5],
                                   ["Did the Democratic Party win a two-thirds supermajority of House seats (67+)?",.5]
                               ]
                            ])
}




def GetId(NewMarket):
    """md5 hashes the Market, ignoring the hash field for reproduceability, and the shares/balance fields for consistency."""
    
    AllKeys = ['Market', 'Size', 'Shares', 'Balance', 'FeeBalance', 'State', 'B', 'OwnerAd', 'Title', 'Description', 'Tags', 'D_State']
    Stable_Keys = AllKeys[7:]
    StableSet = dict([(i, NewMarket[i]) for i in Stable_Keys]) #The dict with unstable fields removed.
    
    return( Md5(StableSet) )
    
GetId(C1)
GetId(C2)

def GetSize(NewMarket,Verbose=False):
    """ Size of the Market in bytes. This may be requried to prevent spam/abuse.  """
  
    AllKeys = list(NewMarket.keys())
    Unstable_Keys = ['Market', 'Size']
    StableSet = dict([(i, NewMarket[i]) for i in AllKeys if i not in Unstable_Keys]) #The dict with unstable fields removed.
    if Verbose:
        print("Getting Bytes...")
        print(StableSet)
      
    ByteLength = len( str(StableSet).encode('utf-8') )
    return(ByteLength)

GetSize(C1,True) #458
GetSize(C2,True) #848

def GetDim(Market,Raw=True):
    """Infers, from the D_state ("decision space") the Market Outcome-space."""    
    Out = []
    if Raw:      
        for i in Market['D_State']:
            Out.append( (len(i) + 1) ) #each question corresponds to one partition of the space, thus for each dimension N questions yeilds N+1 states
    else:
        for i in Market['D_State']:
            Out.append(len(i))

    return(Out)
  
GetDim(C1)
GetDim(C2)


def GetSpace(Market, Verbose=False):
    """Takes a Market, specifically its D_States, and constructs the array of possible ending states."""
    Dim = GetDim(Market)
    if Verbose:
        print("Market Dimention(s):", end='')
        print(Dim)

    #Set Names - Currently unused
    Names = []  
    for i in range(len(Dim)):
        NameTemp1 = []
        for j in range(Dim[i]):
            if j==0: #for the first of each dimention
                NameTemp2 = "kAll: No" #Null space
            else:
                NameTemp2 = "k" + str(j) + ": Yes"
                
            NameTemp1.append(NameTemp2)
        Names.append(NameTemp1)

    JSpace = zeros( Dim )
    return(JSpace)


def FillMarketInfo(NewMarket,B=1):
    """Takes a basic, unfinished Market and fills out some details like the 'size', 'hash', etc. Also calulates the required seed capital for a given B level.
    For security and simplicity the Market is hashed after the 'B' (and initial balance) are set. Then one only needs to verify that the balance was truly established.
    Other fields, such as 'balance' and 'share', which would change constantly and rapidly, are calcualted from the base ("blank") Market.
    Size is calculated second-to-last on the final Market to account for exponentially increasing Share space."""
    CtrNew = copy(NewMarket)
  
    NewMarket['Shares'] = GetSpace(NewMarket) 

    #AMM seed capital requirement is given as b*log(N), where N is the number of states the Market must support.
    Nstates = prod(GetDim(NewMarket))
    NewMarket['Balance'] = NewMarket['B']*log(Nstates)
  
    NewMarket['Size'] = GetSize(NewMarket)
    NewMarket['Market'] = GetId(NewMarket)
    return(NewMarket)
    


C1f = FillMarketInfo(C1)
GetId(C1) == GetId(C1f) #True
C2f = FillMarketInfo(C2)
GetId(C2) == GetId(C2f) #True




#def GetDecisionRows(Market):
#    '''Takes a Market and returns the set of Decisions that will need to be made.'''
#
#    #Build IDs for UJ
#    Dim <- GetDim(Market,0)
#    UJ_ID <- vector(length=0)
#  
#    for(i in 1:length(Dim)) UJ_ID <- c(UJ_ID, rep(i,Dim[i]) )
#
#    Dvec <- (1:length(Dim))[UJ_ID] #Dimensions
#    Svec <- unlist( lapply(X=GetDim(Market,0),FUN=function(x) 1:x) ) #State-dividers
#
#    DfStates <- data.frame("IDc"=Market$Market,
#                         "IDd"=Dvec,
#                         "IDs"=Svec,
#                         "T"=Market$EventOverBy,
#                         "UJ"=unlist(Market$D.State),
#                         "J"=.5)
#    return(DfStates)
#
#GetDecisionRows(C1)
#GetDecisionRows(C2)
#
##Assume some results
#
#Results <- GetDecisionRows(C2)
#Results$J <- c(0,0,0,0,0,1)
#Results
#
#MapJudgement <- function(Results,Market) {
#  
#  #Filter on correct Market.
#  # (hasnt been done yet)
#  
#  #Market undecided - kick out to -1
#  if(sum(Results$J==.5)>0) return(-2)
#  
#  #Decided Markets ...traverse the OutComeSpace
#  Results$T <- Results$IDs*Results$J + 1  # +1 for index.. R does not count from zero
#  PreState <- 1:length(GetDim(Market))
#  for(i in 1:length(PreState)) PreState[i] <- max(Results$T[Results$IDd==i])
#  
#  State <- GetSpace(Market)[PreState[1],PreState[2],PreState[3]]
#  return(State)
#  
#}
#
#MapJudgement(Results,C2)



## Marketplace Creation ##
# - Where shares exist. (!) replace 'Markets' with Cmatrix eventually.
global Markets

Markets = {} #Critical Step...creates (blank) marketplace. Would erase the existing marketplace if called twice.

def CreateMarket(Title,
                 B=1,
                 D_State=array([                                                       
                                   [ #d1
                                       ["Did Barack H Obama win the United States 2012 presidential election?",.5]
                                   ]      
                               ]),
                 Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
                 Tags=("Politics, UnitedStates, President, Winner"),
                 OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh" ):
                     

    #Create Object
    TempMarket = { 'Market':nan,'Shares':nan,'Balance':nan,'FeeBalance':0,'State':-2,'B':B,'Size':nan,'OwnerAd':OwnerAd,'Title':Title,
                       'Description':Description,'Tags':Tags,'D_State':D_State }
  
    #Prepare Object
    Temp2 = FillMarketInfo(TempMarket)
    
              
    #Add a new Market to the global 'Markets' variable.
    #Use 'Title' for testing/understanding. I anticipate we will actually use the hash for uniqueness.  
    #Markets[[Temp2$Market]] <<- Temp2 
    Markets[Title] = Temp2.copy()

print(Markets)
CreateMarket("Obama2012")
print(Markets)
CreateMarket("Hillary2016", B=2.5, D_State=C2['D_State'],Description="Hillary and friends.", Tags=("Politics, UnitedStates, President, Congress, Winner") )