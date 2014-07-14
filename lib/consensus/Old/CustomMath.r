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
  if(X<(.5-(Tolerance/2))) return(0)
  else if(X>(.5+(Tolerance/2))) return(1)
  else return(.5)
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