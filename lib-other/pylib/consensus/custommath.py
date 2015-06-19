#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Supporting math for the consensus mechanism.

"""
from __future__ import division
from numpy import *
from numpy.linalg import *

def WeightedMedian(data, weights):
    """Calculate a weighted median.

    Args:
      data (list or numpy.array): data
      weights (list or numpy.array): weights

    """
    data, weights = array(data).squeeze(), array(weights).squeeze()
    s_data, s_weights = map(array, zip(*sorted(zip(data, weights))))
    midpoint = 0.5 * sum(s_weights)
    if any(weights > midpoint):
        w_median = median(data[weights == max(weights)])
    else:
        cs_weights = cumsum(s_weights)
        idx = where(cs_weights <= midpoint)[0][-1]
        if cs_weights[idx] == midpoint:
            w_median = mean(s_data[idx:idx+2])
        else:
            w_median = s_data[idx+1]
    return w_median

def Rescale(UnscaledMatrix, Scales):
    """Forces a matrix of raw (user-supplied) information
    (for example, # of House Seats, or DJIA) to conform to
    svd-appropriate range.

    Practically, this is done by subtracting min and dividing by
    scaled-range (which itself is max-min).

    """
    # Calulate multiplicative factors   
    InvSpan = []
    for scale in Scales:
        InvSpan.append(1 / float(scale["max"] - scale["min"]))

    # Recenter
    OutMatrix = ma.copy(UnscaledMatrix)
    cols = UnscaledMatrix.shape[1]
    for i in range(cols):
        OutMatrix[:,i] -= Scales[i]["min"]

    # Rescale
    NaIndex = isnan(OutMatrix)
    OutMatrix[NaIndex] = 0

    OutMatrix = dot(OutMatrix, diag(InvSpan))
    OutMatrix[NaIndex] = nan

    return OutMatrix

def MeanNa(Vec):
    """Takes masked array, replaces missing values with array mean."""
    MM = mean(Vec)
    Vec[where(Vec.mask)] = MM
    return(Vec)
    

def GetWeight(Vec, AddMean=0):
    """Takes an array (vector in practice), and returns proportional distance from zero."""
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
    
    
def DemocracyCoin(Mat):
    """For testing, easier to assume uniform coin distribution."""
    # print("NOTE: No coin distribution given, assuming democracy [one row, one vote].")
    Rep = GetWeight( array([[1]]*len(Mat) )) #Uniform weights if none were provided.
    return( Rep )
    

def WeightedCov(Mat,Rep=-1):
    """Takes 1] a masked array, and 2] an [n x 1] dimentional array of weights, and computes the weighted covariance
    matrix and center of a given array.
    Taken from http://stats.stackexchange.com/questions/61225/correct-equation-for-weighted-unbiased-sample-covariance"""
    if type(Rep) is int:
        Rep = DemocracyCoin(Mat)
    
    Coins = ma.copy(Rep)
    for i in range(len(Rep)):
        Coins[i] = (int( (Rep[i] * 1000000)[0] )) 
       
    Mean = ma.average(Mat, axis=0, weights=hstack(Coins)) # Computing the weighted sample mean (fast, efficient and precise)
    XM = matrix( Mat-Mean ) # xm = X diff to mean
    sigma2 = matrix( 1/(sum(Coins)-1) * ma.multiply(XM, Coins).T.dot(XM) ); # Compute the unbiased weighted sample covariance

    return( {'Cov':array(sigma2), 'Center':array(XM) } )
    
def WeightedPrinComp(Mat,Rep=-1):
    """Takes a matrix and row-weights and manually computes the statistical procedure known as Principal Components Analysis (PCA)
    This version of the procedure is so basic, that it can also be thought of as merely a singular-value decomposition on a weighted covariance matrix."""      
    wCVM = WeightedCov(Mat,Rep)
    SVD = svd(wCVM['Cov'])

    L = SVD[0].T[0]                      #First loading
    S = dot(wCVM['Center'],SVD[0]).T[0]   #First Score

    return(L,S)

if __name__ == "__main__":
    pass
