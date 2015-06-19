
rm(list=ls())

tryCatch(expr=setwd("~/GitHub/Truthcoin/lib"), error=function(e) setwd(choose.dir(caption="Failed to set working directory automatically. Choose 'lib' folder:")) )
source("market/Trading.R")

# Run intros in MarketTest.Rmd


Markets$Obama$Shares[1] <- 1
Markets$Obama$Shares[2] <- 1
Start <- ShowPrices("Obama")
sum(Markets$Obama$Shares)
ShowPrices("Obama")

QueryMove("Obama",2,P = .6, Iterations = 1)

Markets$Obama$Shares[2]  <- Markets$Obama$Shares[2] + QueryMove("Obama",2,P = .6, Iterations = 125)
ShowPrices("Obama")

Markets$Obama$Shares  <- QueryMove("Obama",2,P = .9)
ShowPrices("Obama")

Markets$Obama$Shares 

Vamp <- function(ID="Obama", P=.9, State=2, Iter=120) {
  
  # Setup
  for(i in 1:length( Markets[[ID]]$Shares )) {
    # Each state starts with exactly 1 share
    Markets[[ID]]$Shares[i] <<- 1
  }
  
  P1 <- ShowPrices(ID)[1][[1]]
  P2 <- ShowPrices(ID)[2][[1]]
  
  S1 <- Markets[[ID]]$Shares[1][[1]]
  S2 <- Markets[[ID]]$Shares[2][[1]]
  
  Count <- Iter
  
  while( Count != 0 ) {
    Markets[[ID]]$Shares <<- QueryMove(ID, State=State, P = P)
    
    P1 <- c(P1, ShowPrices(ID)[1][[1]] )
    P2 <- c(P2, ShowPrices(ID)[2][[1]] )
    
    S1 <- c(S1, Markets[[ID]]$Shares[1][[1]] )
    S2 <- c(S2, Markets[[ID]]$Shares[2][[1]] )
    
    Count <- Count - 1
    
  }
  
  return( data.frame(P1, P2, S1, S2) )
  
}

Test <- Vamp()
Test

MetaVamp <- function(ID="Obama", Ps=seq(.51,.99,by=.01)) {
  
  Expected <- 0
  Actual <- 0
  
  for(i in Ps) {
    
    DF <- Vamp(P = i, State = 2)
    LastRow <- nrow(DF)
    
    Expected <- c( Expected, DF[LastRow, "S2"] )
    Actual <- c( Actual, DF[2 , "S2"] )
    
  }
  
  Expected <- Expected[-1]
  Actual <- Actual[-1]
  
  Ratio <- Actual / Expected
  
  return( data.frame(Ps, Expected, Actual, Ratio) )
  
}

Test2 <- MetaVamp()
Test2


m3 <- lm(Ratio~Ps+I(Ps^2)+I(Ps^3), data=Test2)
summary(m3)

plot(Ratio~Ps, data=Test2)

Test3 <- MetaVamp(ID = "DemControl")

m4 <- lm(Ratio~Ps+I(Ps^2)+I(Ps^3), data=Test3)
summary(m4)

plot(Ratio~Ps, data=Test3)

summary(m3)
summary(m4)

m3 <- lm( I(1/Ratio) ~ Ps+I(Ps^2)+I(Ps^3), data=Test2)
summary(m3)
m4 <- lm( I(1/Ratio) ~ Ps+I(Ps^2)+I(Ps^3), data=Test3)
summary(m4)

Test2$Pd <- Test2$Ps - .9
Test2$Pr <- Test2$Ps / .9

m5 <- lm( I(1/Ratio) ~ Pd+I(Pd^2)+I(Pd^3), data=Test2)
summary(m5)

m5 <- lm( I(1/Ratio) ~ Pd+I(Pd^2), data=Test2)
summary(m5)

m6 <- lm( I(1/Ratio) ~ Pr+I(Pr^2)+I(Pr^3), data=Test2)
summary(m6)

# Conclusion: the fade-ins are identical, immune to the number of states & state-dimensionality




Fail1 <- ShowPrices("Obama")

Fail1/Goal

Markets$Obama$Shares
sum(Markets$Obama$Shares)



Markets$Obama$Shares <- (1/Alpha)*Markets$Obama$Shares

Markets$Obama$Shares[1] <- 13.72318
Markets$Obama$Shares[2] <- 14.00271
ShowPrices("Obama")

Markets$Obama$Shares <- rS
ShowPrices("Obama")
