

# Relationship between price movements and underlying moments

# 

rm(list=ls())

N <- 1000
install.packages('moments')
library(moments)

World <- rnorm(N, mean = 5, sd = 8)
RealMu <- mean(World)
RealSd <- sd(World)
RealSkew <- skewness(World)
RealKurt <- kurtosis(World)



ThisWorld <- sample(World, size = N, replace = FALSE)


# Mean - easy
DF <- data.frame("T"=1:N, "Obs"=ThisWorld, "cSum"=cumsum(ThisWorld))
DF$xHat <- DF$cSum / DF$T
DF$MuError <- (DF$xHat-RealMu)/RealMu
head(DF)

# now we want the SD
SD <- rep(NA,N)
for(i in 2:nrow(DF)) {
  Slice <- DF$Obs[1:i]
  SD_Slice <- sd(Slice)
  SD[i] <- SD_Slice
}

# Can we 'cheat' and tease out the sd?

SD_hat <- rep(NA,N)
for(i in 2:nrow(DF)) {
  X <- DF$Obs[1:i]
  Par1 <- mean(X)
  Par2 <- mean( (X^2) )
  Yhat <- ( Par2 - (Par1^2) )^(1/2)
  SD_hat[i] <- Yhat
}

plot(SD_hat,main = "Standard Deviation")
abline(h=RealSd)
abline(v=30,lty=2)



# How about Skewness

Skew <- rep(NA,N)
for(i in 3:nrow(DF)) {
  Slice <- DF$Obs[1:i]
  Skew_Slice <- skewness(Slice)
  Skew[i] <- Skew_Slice
}


Skew_hat <- rep(NA,N)
for(i in 3:nrow(DF)) {
  X <- DF$Obs[1:i]
  Par1 <- mean(X)
  Par2 <- mean( (X^2) )
  Par3 <- mean( (X^3) )
  SD <- ( Par2 - (Par1^2) )^(1/2)
  Skew_Slice <- ( Par3 - (3*Par1*(SD^2)) - (Par1^3) ) / (SD^3)
  Skew_hat[i] <- Skew_Slice
}

plot(Skew_hat,main = "Skewness")
abline(h=RealSkew)
abline(v=30,lty=2)

# Interesting: Skewness consistently underestimated in this trial



# Last, kurtosis

Kurt <- rep(NA,N)
for(i in 4:nrow(DF)) {
  Slice <- DF$Obs[1:i]
  Kurt_Slice <- kurtosis(Slice)
  Kurt[i] <- Kurt_Slice
}


Kurt_hat <- rep(NA,N)
for(i in 4:nrow(DF)) {
  X <- DF$Obs[1:i]
  Par1 <- mean(X)
  Par2 <- mean( (X^2) )
  Par3 <- mean( (X^3) )
  Par4 <- mean( (X^4) )
  SD <- ( Par2 - (Par1^2) )^(1/2)
  S4 <- Par4 - (4*Par1)*Par3 + (6*(Par1^2))*Par2 - (4*(Par1^3))*Par1 + (Par1^4)
  Kurt_Slice <- S4 / (SD^4)
  Kurt_hat[i] <- Kurt_Slice
}

plot(Kurt_hat,main = "Kurtosis")
abline(h=RealKurt)
abline(v=30,lty=2)


# The "Taleb" Criticism .. even in this toy setup kurtosis is dominated by one observation
Kurt_hat[180:250]
Kurt_hat[190:191]




