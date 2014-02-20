# -*- coding: utf-8 -*-
"""
Spyder Editor
WinPython-64bit-3.3.3.3

Note: "Imported NumPy 1.8.0, SciPy 0.13.3, Matplotlib 1.3.1, guidata 1.6.1, guiqwt 2.3.2"
"""

c = [1,2,3,nan,3]
c2 = ma.masked_array(c,isnan(c))
#Python has a less-comfortable handling of missing values.

c3 = [2,3,-1,4,0]

def MeanNa(Vec):
    """Takes masked array, replaces missing values with array mean."""
    MM = mean(Vec)
    Vec[where(Vec.mask)] = MM
    return(Vec)
    
q = MeanNa(c2)
print(q)

def GetWeight(Vec, AddMean=0):
    """Takes a vector, and returns proportional distance from zero."""
    New = abs(Vec)       #Absolute Value
    if AddMean == 1:     #Add the mean to each element of the vector
        New = New + mean(New)
    if sum(New) == 0:    #Catch an error here
        New = New + 1
    New = New/sum(New)   #Normalize

    return(New)

q = GetWeight(c2)
print(q)

def Catch(X,Tolerance=0):
    """Forces continuous values into bins at 0, .5, and 1"""
    if X < (.5-(Tolerance/2)):
        return(0)
    elif X > (.5+(Tolerance/2)):
        return(1)
    else:
        return(.5)
     
Catch(.4)
Catch(.6)
Catch(.4,.3)
Catch(.4,.1)


def Influence(Weight):
    """Takes a normalized Vector (one that sums to 1), and computes relative strength of the indicators."""
    N = len(Weight)
    Expected = [[1/N]]*N
    print(Expected)
    Out = []
    for i in range(1, N):
        Out.append(Weight[i]/Expected[i])
    return(Out)


print(Influence(GetWeight(c2)))

def ReWeight(Vec):
    """Get the relative influence of numbers, treat NaN as influence-less."""
    Out = Vec
    Exclude = isnan(Vec)
    Out[Exclude] = 0      #set missing to 0
    Out = Out / sum(Out)  #normalize
    return(Out)
    
ReWeight(c2)




Votes = array([[1,1,0,0], #Use array for missing values later
               [1,0,0,0],
               [1,1,0,0],
               [1,1,1,0],
               [0,0,1,1],
               [0,0,1,1]])   
               
def ReverseMatrix(Mat):  #tecnically an array now, sorry about the terminology confusion
    return( (Mat-1) * -1 )
    
ReverseMatrix(Votes)
    

def WeightedCov(X,Coins=-1):
    """Taken from http://stats.stackexchange.com/questions/61225/correct-equation-for-weighted-unbiased-sample-covariance
    Python does things a little differently with the weights, so lets call them what they are: Coins."""
    if Coins == -1:
        print("NOTE: No coin distribution given, assuming democracy.")
        Coins= [[1]]*len(X) #Uniform weights if none were provided.
        
    Mean = ma.average(X,axis=0, weights=hstack(Coins)) # Computing the weighted sample mean (fast, efficient and precise)
    XM = matrix( Votes-Mean ) # xm = X diff to mean
    sigma2 = matrix( 1/(sum(Coins)-1) * ma.multiply(XM, Coins).T.dot(XM) ); # Compute the unbiased weighted sample covariance

    return(sigma2,XM)
    
def WeightedPrinComp(X,Coins=-1):
    """Manually computes the statistical procedure known as Principal Components Analysis (PCA)
    This version of the procedure is so basic, that it can also be thought of as merely a singular-value decomposition on a weighted covariance matrix."""      
    wCVM = WeightedCov(Votes)
    SVD = svd(wCVM[0])

    L = SVD[0].T[0] #First loading
    S =  (wCVM[1] * SVD[0]).T[0]  #First Score

    return(L,S)
    
R1 = WeightedPrinComp(Votes)
R2 = WeightedPrinComp(ReverseMatrix(Votes))

print(R1)
print(R2)



    