# -*- coding: utf-8 -*-
"""
Spyder Editor
WinPython-64bit-3.3.3.3

Note: "Imported NumPy 1.8.0, SciPy 0.13.3, Matplotlib 1.3.1, guidata 1.6.1, guiqwt 2.3.2"
"""


def MeanNa(Vec):
    """Takes masked array, replaces missing values with array mean."""
    MM = mean(Vec)
    Vec[where(Vec.mask)] = MM
    return(Vec)
    

def GetWeight(Vec, AddMean=0):
    """Takes a vector, and returns proportional distance from zero."""
    New = abs(Vec)       #Absolute Value
    if AddMean == 1:     #Add the mean to each element of the vector
        New = New + mean(New)
    if sum(New) == 0:    #Catch an error here
        New = New + 1
    New = New/sum(New)   #Normalize
    return(New)


def Catch(X,Tolerance=0):
    """Forces continuous values into bins at 0, .5, and 1"""
    if X < (.5-(Tolerance/2)):
        return(0)
    elif X > (.5+(Tolerance/2)):
        return(1)
    else:
        return(.5)
     

def Influence(Weight):
    """Takes a normalized Vector (one that sums to 1), and computes relative strength of the indicators."""
    N = len(Weight)
    Expected = [[1/N]]*N
    Out = []
    for i in range(1, N):
        Out.append(Weight[i]/Expected[i])
    return(Out)


def ReWeight(Vec):
    """Get the relative influence of numbers, treat NaN as influence-less."""
    Out = Vec
    Exclude = isnan(Vec)
    Out[Exclude] = 0      #set missing to 0
    Out = Out / sum(Out)  #normalize
    return(Out)
    
               
def ReverseMatrix(Mat):  #tecnically an array now, sorry about the terminology confusion
    return( (Mat-1) * -1 )
    

def WeightedCov(Mat,Coins=-1):
    """Taken from http://stats.stackexchange.com/questions/61225/correct-equation-for-weighted-unbiased-sample-covariance
    Python does things a little differently with the weights, so lets call them what they are: Coins."""
    
    if Coins == -1:
        print("NOTE: No coin distribution given, assuming democracy.")
        Coins= [[1]]*len(Mat) #Uniform weights if none were provided.
        
    Mean = ma.average(Mat,axis=0, weights=hstack(Coins)) # Computing the weighted sample mean (fast, efficient and precise)
    XM = matrix( Votes-Mean ) # xm = X diff to mean
    sigma2 = matrix( 1/(sum(Coins)-1) * ma.multiply(XM, Coins).T.dot(XM) ); # Compute the unbiased weighted sample covariance

    return( {'Cov':array(sigma2), 'Center':array(XM) } )
    
    
def WeightedPrinComp(Mat,Coins=-1):
    """Manually computes the statistical procedure known as Principal Components Analysis (PCA)
    This version of the procedure is so basic, that it can also be thought of as merely a singular-value decomposition on a weighted covariance matrix."""      
    wCVM = WeightedCov(Mat)
    SVD = svd(wCVM['Cov'])

    L = SVD[0].T[0]                      #First loading
    S = dot(wCVM['Center'],SVD[0]).T[0]   #First Score

    return(L,S)
    

def CustomMathTest():
    """Runs the functions in custommath.py to make sure that they are working properly."""    
    
    def CheckEqual(iterator):
        return len(set(iterator)) <= 1
    
    print("")
    print(" ..Testing.. ")
    print("")
    
    Tests = []

    #Setup
    c = [1,2,3,nan,3]
    c2 = ma.masked_array(c,isnan(c))
    #Python has a less-comfortable handling of missing values.
    c3 = [2,3,-1,4,0]
    

    print("Testing MeanNa...")
    Expected = [1.0, 2.0, 3.0, 2.25, 3.0]
    Actual = MeanNa(c2)
    print(Expected)
    print(Actual)
    print(CheckEqual(Actual==Expected))
    Tests.append(CheckEqual(Actual==Expected))
    print("")
    
    print("Testing Catch...")
    Expected = [0,1,.5,0]
    Actual = [Catch(.4),Catch(.6),Catch(.4,.3),Catch(.4,.1)]
    print(Expected)
    print(Actual)
    print(Actual==Expected)
    Tests.append((Actual==Expected))
    print("")
    
    print("Testing Influence...")
    Expected = [array([ 0.88888889]), array([ 1.33333333]), array([ 1.]), array([ 1.33333333])]
    Actual = Influence(GetWeight(c2))
    print(Expected)
    print(Actual)
    Out = []
    Flag=False
    for i in range(len(Actual)):                  #rounding problems require an approximation
        Out.append( (Actual[i]-Expected[i])**2)
    if(sum(Out)<.000000000001):
        Flag=True
    print(Flag)
    Tests.append(Flag)    
    print("")
    
    print("Testing ReWeight...")
    Expected = [0.08888888888888889,  0.17777777777777778,  0.26666666666666666,  0.2, 0.26666666666666666]
    Actual = ReWeight(c2)
    print(Expected)
    print(Actual)
    print(CheckEqual(Actual==Expected))
    Tests.append(CheckEqual(Actual==Expected))
    print("")
    
    Votes = array([[1,1,0,0], 
                   [1,0,0,0],
                   [1,1,0,0],
                   [1,1,1,0],
                   [0,0,1,1],
                   [0,0,1,1]]) 
                
    print("Testing ReverseMatrix...")
    Expected = array([[0, 0, 1, 1],
                   [0, 1, 1, 1],
                   [0, 0, 1, 1],
                   [0, 0, 0, 1],
                   [1, 1, 0, 0],
                   [1, 1, 0, 0]])
    Actual = ReverseMatrix(Votes)
    print(Expected)
    print(Actual)
    Flag=False
    if(sum(Expected==Actual)==24):
        Flag=True
    print(Flag)
    Tests.append(Flag)
    print("")           
    
    print("Testing WeightedPrinComp...")
    Expected = array([-0.81674714, -0.35969107, -0.81674714, -0.35969107,  1.17643821, 1.17643821])
    Actual = WeightedPrinComp(Votes)[1]
    Out = []
    Flag=False
    for i in range(len(Actual)):                 #rounding problems require an approximation
        Out.append( (Actual[i]-Expected[i])**2)
    if(sum(Out)<.000000000001):
        Flag=True 
    print(Flag)
    Tests.append(Flag) 
    print("")    
    
    print(" *** TEST RESULTS ***")
    print(Tests)
    print(CheckEqual(Tests))
    
    return(CheckEqual(Tests))

#CustomMathTest()
