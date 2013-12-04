#CustomMath.r
#A collection of relatively basic functions.

MeanNA <- function(vec) {
  #Replaces NA instances with their mean instead
  m <- mean(vec, na.rm = TRUE)
  vec[is.na(vec)] <- m
  return(vec)
}

GetWeight <- function(vec,AddMean=FALSE) {
  #Takes a vector, absolute value, then proportional linear deviance from 0.
  new <- abs(vec)
  if(AddMean==1) new  <- new + mean(new)
  if(sum(new)==0) new <- new + 1
  new <- new/sum(new)
  return(new)
}

Catch <- function(x,m=0) {
  #x is the ConoutRAW, m is the length of the midpoint corresponding to .5 
  #The purpose here is to handle rounding for binary contracts
  if(x<(.5-(m/2))) return(0)
  else if(x>(.5+(m/2))) return(1)
  else return(.5)
}

Influence  <- function(weight) {
  #Takes a vector that sums to 1 and computes relative strength of the indicators above expected.
  #this is because by-default the conformity of each Author and Judge is expressed relatively.
  expected <- rep(1/length(weight),length(weight))
  return( weight / expected)
}

ReWeight <- function(vec,exclude=is.na(vec)) {
  #Get the relative influence of numbers, treat NA as influence-less
  out <- vec
  out[exclude] <- 0
  out <- out/sum(out)
  return(out)
}

ReverseMatrix <- function(M) {
  #Inverts a binary matrix
  return((M-1)*-1)
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