#CustomMath.r
#A collection of relatively basic functions.

MeanNA <- function(Vec) {
  #Replaces NA instances with their mean instead
  m <- mean(Vec, na.rm = TRUE)
  Vec[is.na(Vec)] <- m
  return(Vec)
}

GetWeight <- function(Vec,AddMean=FALSE) {
  #Takes a Vector, absolute value, then proportional linear deviance from 0.
  new <- abs(Vec)
  if(AddMean==1) new  <- new + mean(new)
  if(sum(new)==0) new <- new + 1
  new <- new/sum(new)
  return(new)
}

Catch <- function(X,Tolerance=0) {
  #x is the ConoutRAW numeric, Tolerance is the length of the midpoint corresponding to .5 
  #The purpose here is to handle rounding for binary contracts
  
  #This function must be substantially altered to support scaled contracts.
  
  if(X<(.5-(Tolerance/2))) return(0)
  else if(X>(.5+(Tolerance/2))) return(1)
  else return(.5)
  
}


GetModes <- function(X, Weights) {
#   ModeCalc <- as.numeric(  names( which.max( table(X)) ) )
#   
#   TopThree <- sort( table(X), decreasing=TRUE)[1:3]
  
  Tab <- aggregate(x=Weights, by= list(X), FUN='sum')
  SortedTab <- Tab[order(Tab[,2], decreasing=TRUE),]
  
  TopThree <- SortedTab[1:3,1]
  
  return(TopThree)
}



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

Rescale <- function(UnscaledMatrix, ScalingData) {
  #Calulate multiplicative factors
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


Influence  <- function(Weight) {
  #Takes a normalized Vector (one that sums to 1), and computes relative strength of the indicators.
  #this is because by-default the conformity of each Author and Judge is expressed relatively.
  Expected <- rep(1/length(Weight),length(Weight))
  return( Weight / Expected)
}

ReWeight <- function(Vec,exclude=is.na(Vec)) {
  #Get the relative influence of numbers, treat NA as influence-less
  out <- Vec
  out[exclude] <- 0
  out <- out/sum(out)
  return(out)
}

ReverseMatrix <- function(Mat) {
  #Inverts a binary matrix
  return((Mat-1)*-1)
}

WeightedPrinComp <- function(X,Weights=ReWeight(rep(1,nrow(M))) ) {
  #Manually computes the statistical procedure known as Principal Components Analysis (PCA)
  #This version of the procedure is so basic, that it can also be thought of as merely a singular-value decomposition on a weighted covariance matrix.
  
  wCVM <- cov.wt(x=X,wt=Weights)
  
  L <- svd(wCVM$cov)$u[,1]
  S <- as.vector(scale(X,center=wCVM$center,scale= FALSE) %*% L)
  
  Out <- list("Scores"=S,"Loadings"=L)
  return(Out)
}