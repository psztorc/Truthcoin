# Custom Math
# Paul Sztorc
# Written in R (v 3.1.1) using Rstudio (v 0.98.1028)

# A collection of relatively basic functions.


AsMatrix <- function(Vec) {
  # Takes a vector and transforms it into a 1 column matrix
  return(matrix(Vec,nrow=length(Vec)))
}

# Vector <- c(3,4,5)
# > Vector
# [1] 3 4 5
# > AsMatrix(Vector)
#       [,1]
# [1,]    3
# [2,]    4
# [3,]    5

MeanNA <- function(Vec) {
  # Replaces NA instances with their mean instead
  m <- mean(Vec, na.rm = TRUE)
  Vec[is.na(Vec)] <- m
  return(Vec)
}

# > MeanNA(c(3,4,6,7,8))
# [1] 3 4 6 7 8

# > MeanNA(c(3,NA,6,7,8))
# [1] 3 6 6 7 8

# > MeanNA(c(0,0,0,1,NA))
# [1] 0.00 0.00 0.00 1.00 0.25

# > MeanNA(c(0,0,NA,1,NA))
# [1] 0.0000000 0.0000000 0.3333333 1.0000000 0.3333333



GetWeight <- function(Vec,AddMean=FALSE) {
  # Takes a Vector, absolute value, then proportional linear deviance from 0.
  new <- abs(Vec)
  if(AddMean==1) new  <- new + mean(new)
  if(sum(new)==0) new <- new + 1
  new <- new/sum(new)
  return(new)
}

# > GetWeight(c(1,1,1,1))
# [1] 0.25 0.25 0.25 0.25
# > GetWeight(c(10,10,10,10))
# [1] 0.25 0.25 0.25 0.25
# > GetWeight(c(4,5,6,7))
# [1] 0.1818182 0.2272727 0.2727273 0.3181818
# > GetWeight(c(4,5,6,7),TRUE)
# [1] 0.2159091 0.2386364 0.2613636 0.2840909



Catch <- function(X,Tolerance=0) {
  # x is the ConoutRAW numeric, Tolerance is the length of the midpoint corresponding to .5 
  # The purpose here is to handle rounding for Binary Decisions (Scaled Decisions use weighted median)
  
  if(X<(.5-(Tolerance/2))) return(0)
  else if(X>(.5+(Tolerance/2))) return(1)
  else return(.5)
  
}

# > Catch(.4)
# [1] 0
# > Catch(.5)
# [1] 0.5
# > Catch(.6)
# [1] 1
# > Catch(.6,Tolerance=.1)
# [1] 1
# > Catch(.6,Tolerance=.2)
# [1] 0.5


weighted.median <- function(x, w, na.rm=TRUE, ties=NULL) {
  # Thanks to https://stat.ethz.ch/pipermail/r-help/2002-February/018614.html
  if (missing(w))
    w <- rep(1, length(x));
  
  # Remove values that are NA's
  if (na.rm == TRUE) {
    keep <- !(is.na(x) | is.na(w));
    x <- x[keep];
    w <- w[keep];
  } else if (any(is.na(x)))
    return(NA);
  
  # Assert that the weights are all non-negative.
  if (any(w < 0))
    stop("Some of the weights are negative; one can only have positive
         weights.");
  
  # Remove values with weight zero. This will:
  #  1) take care of the case when all weights are zero,
  #  2) make sure that possible tied values are next to each others, and
  #  3) it will most likely speed up the sorting.
  n <- length(w);
  keep <- (w > 0);
  nkeep <- sum(keep);
  if (nkeep < n) {
    x <- x[keep];
    w <- w[keep];
    n <- nkeep;
  }
  
  # Are any weights Inf? Then treat them with equal weight and all others
  # with weight zero.
  wInfs <- is.infinite(w);
  if (any(wInfs)) {
    x <- x[wInfs];
    n <- length(x);
    w <- rep(1, n);
  }
  
  # Are there any values left to calculate the weighted median of?
  if (n == 0)
    return(NA);
  
  # Order the values and order the weights accordingly
  ord <- order(x);
  x <- x[ord];
  w <- w[ord];
  
  wcum <- cumsum(w);
  wsum <- wcum[n];
  wmid <- wsum / 2;
  
  # Find the position where the sum of the weights of the elements such that
  # x[i] < x[k] is less or equal than half the sum of all weights.
  # (these two lines could probably be optimized for speed).
  lows <- (wcum <= wmid);
  k  <- sum(lows);
  
  # Two special cases where all the weight are at the first or the
  # last value:
  if (k == 0) return(x[1]);
  if (k == n) return(x[n]);
  
  # At this point we know that:
  #  1) at most half the total weight is in the set x[1:k],
  #  2) that the set x[(k+2):n] contains less than half the total weight
  # The question is whether x[(k+1):n] contains *more* than
  # half the total weight (try x=c(1,2,3), w=c(1,1,1)). If it is then
  # we can be sure that x[k+1] is the weighted median we are looking
  # for, otherwise it is any function of x[k:(k+1)].
  
  wlow  <- wcum[k];    # the weight of x[1:k]
  whigh <- wsum - wlow;  # the weight of x[(k+1):n]
  if (whigh > wmid)
    return(x[k+1]);
  
  if (is.null(ties) || ties == "weighted") {  # Default!
    (wlow*x[k] + whigh*x[k+1]) / wsum;
  } else if (ties == "max") {
    x[k+1];
  } else if (ties == "min") {
    x[k];
  } else if (ties == "mean") {
    (x[k]+x[k+1])/2;
  } else if (ties == "both") {
    c(x[k], x[k+1]);
  }
}

# > weighted.median(x=c(3,4,5),w=c(.2,.2,.6))
# [1] 5
# > weighted.median(x=c(3,4,5),w=c(.2,.2,.5))
# [1] 5
# > weighted.median(x=c(3,4,5),w=c(.2,.2,.4))
# [1] 4.5



Rescale <- function(UnscaledMatrix, ScalingData) {
  # Forces a matrix of raw (user-supplied) information (for example, # of House Seats, or DJIA) to conform to svd-appropriate range.
  # Practically, this is done by subtracting min and dividing by scaled-range (which itself is max-min).
  
  # Calulate multiplicative factors
  InvSpan = ( 1/ ( ScalingData["Max",] - ScalingData["Min",]) )
  
  #Recenter
  OutMatrix <- sweep(UnscaledMatrix, 2, ScalingData["Min",])
  
  #Rescale
  NaIndex <- is.na(OutMatrix) #NA-Preempt
  OutMatrix[NaIndex] <- 0
  OutMatrix <- OutMatrix %*% diag(InvSpan)
  OutMatrix[NaIndex] <- NA #Restore NA's
  
  #Relabel
  row.names(OutMatrix) <- row.names(UnscaledMatrix)
  colnames(OutMatrix) <- colnames(UnscaledMatrix)
  
  return(OutMatrix)
}

# Scales <- matrix( data=c( 0,    0,    0,    0,      1,          1,
#                           0,    0,    0,    0,      0,       8000,
#                           1,    1,    1,    1,    435,     20000 ), nrow=3, byrow=TRUE)
#                   
# colnames(Scales) <- c("C1.1", "C2.1", "C3.0", "C4.0", "C5.233", "C6.1602759")
# row.names(Scales) <- c("Scaled", "Min", "Max")  
# 
# Scales
# 
# M <- matrix( data=c(
#       1,    1,    0,    0,    233,   16027.59,
#       1,    0,    0,    0,    199,         NA,
#       1,    1,    0,    0,    233,   16027.59,
#       1,    1,    1,    0,    250,         NA,
#       0,    0,    1,    1,    435,    8001.00,
#       0,    0,    1,    1,    435,   19999.00),
#   nrow=6,byrow=TRUE)
#   
# colnames(M) <- c("C1.1", "C2.1", "C3.0", "C4.0", "C5.233", "C6.1602759")
# row.names(M) <- paste("Voter",1:6)
# 
# Rescale(M,Scales)
# 
# C1.1 C2.1 C3.0 C4.0    C5.233   C6.1602759
# Voter 1    1    1    0    0 0.5356322 6.689658e-01
# Voter 2    1    0    0    0 0.4574713           NA
# Voter 3    1    1    0    0 0.5356322 6.689658e-01
# Voter 4    1    1    1    0 0.5747126           NA
# Voter 5    0    0    1    1 1.0000000 8.333333e-05
# Voter 6    0    0    1    1 1.0000000 9.999167e-01



Influence  <- function(Weight) {
  # Takes a normalized Vector (one that sums to 1), and computes relative strength of the indicators.
  # this is because by-default the conformity of each Author and Judge is expressed relatively.
  
  Expected <- rep(1/length(Weight),length(Weight))
  return( Weight / Expected)
}

# > Influence(c(.25,.25,.25,.25))
# [1] 1 1 1 1
# > Influence(c(.3,.3,.4))
# [1] 0.9 0.9 1.2
# > Influence(c(.99,.0025,.0025,.0025,.0025))
# [1] 4.9500 0.0125 0.0125 0.0125 0.0125


ReWeight <- function(Vec,exclude=is.na(Vec)) {
  # Get the relative influence of numbers, treat NA as influence-less
  
  if(!identical(Vec,abs(Vec))) {
    print("Warning: Expected all positive.")
  }
    
  Out <- Vec
  Out[exclude] <- 0
  Out <- Out/sum(Out)
  return(Out)
}

# > ReWeight(c(1,1,1,1))
# [1] 0.25 0.25 0.25 0.25
# > ReWeight(c(NA,1,NA,1))
# [1] 0.0 0.5 0.0 0.5
# > ReWeight(c(2,4,6,12))
# [1] 0.08333333 0.16666667 0.25000000 0.50000000
# > ReWeight(c(2,4,NA,12))
# [1] 0.1111111 0.2222222 0.0000000 0.6666667


ReverseMatrix <- function(Mat) {
  #Inverts a binary matrix
  return((Mat-1)*-1)
}

# M <- matrix(
#   nrow=3,
#   byrow=TRUE,
#   data=c(
#     0,0,1,
#     1,1,0,
#     0,0,0))
# 
#       [,1] [,2] [,3]
# [1,]    0    0    1
# [2,]    1    1    0
# [3,]    0    0    0
# > ReverseMatrix(M)
#       [,1] [,2] [,3]
# [1,]    1    1    0
# [2,]    0    0    1
# [3,]    1    1    1



WeightedPrinComp <- function(X, Weights, Verbose=FALSE) {
  # Takes Matrix X and vector of row-weights "Weights"
  # Manually computes the statistical procedure known as Principal Components Analysis (PCA)
  # This version of the procedure is so basic, that it can also be thought of as merely a singular-value decomposition on a weighted covariance matrix.
  
  if(missing(Weights)) {
    Weights <- ReWeight(rep(1,nrow(X)))
  } 
  
  if(length(Weights)!=nrow(X)) {
    print("Error: Weights must be equal to nrow(X)")
    return(NULL)
  }
  
  wCVM <- cov.wt(x=X, wt=Weights) # Weighted Covariance Matrix
  
  # http://en.wikipedia.org/wiki/Singular_value_decomposition
  L <- svd(wCVM$cov)$u[,1]                                           # extract first Loading (first column of U matrix)
  S <- as.vector( scale(X, center=wCVM$center, scale=FALSE) %*% L)   # manually calculate the first Score, using the input matrix, covariance matrix, and first loading
  # (center subtracts the weight-adjusted-means from X's columns)
  # (scale=FALSE means that no scaling is done)
  # %*% is matrix multiplication
  
  if(Verbose) {
    Ls <- svd(wCVM$cov)$u # the entire u matrix
    Ss <- scale(X, center=wCVM$center, scale=FALSE) %*% Ls # all of the scores
    print("Loadings: ")
    print(Ls)
    print(" ")
    print("Scores:")
    print(Ss)
    print(" ")
  }
  
  Out <- list("Scores"=S,"Loadings"=L)
  return(Out)
}

# M <- matrix(
#   nrow=3,
#   byrow=TRUE,
#   data=c(
#     0,0,1,
#     1,1,0,
#     0,0,0))
# 
# M2 <- cbind(M,c(.7,.5,.2))

# > WeightedPrinComp(M)
# $Scores
# [1]  0.7251092 -0.9905177  0.2654084
# $Loadings
# [1] -0.6279630 -0.6279630  0.4597008
# 
# 
# > WeightedPrinComp(M,c(.33333,.33333,.33333))
# $Scores
# [1]  0.7251092 -0.9905177  0.2654084
# $Loadings
# [1] -0.6279630 -0.6279630  0.4597008
# 
# > WeightedPrinComp(M,c(.1,.1,.8))
# $Scores
# [1]  0.2762801 -1.2732354  0.1246194
# $Loadings
# [1] -0.6989274 -0.6989274  0.1516607
# 
# > WeightedPrinComp(M2)
# $Scores
# [1]  0.7385624 -0.9866042  0.2480418
# $Loadings
# [1] -0.62428014 -0.62428014  0.46733010  0.04638101
# 
# > WeightedPrinComp(M2,c(.1,.1,.8))
# $Scores
# [1]  0.1269693 -1.2954637  0.1460618
# $Loadings
# [1] -0.69461121 -0.69461121  0.06807931 -0.17434371
