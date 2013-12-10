Trading Tests and Demo
========================================================
Paul Sztorc
Tue Dec 10 17:13:28 2013


```
## $Alice
## $Alice$Cash
## [1] 10
## 
## 
## $Bob
## $Bob$Cash
## [1] 50
```

```
## list()
```

```
## $Obama
## $Obama$Shares
## [1] 0 0
## 
## $Obama$Balance
## [1] 0.6931
## 
## $Obama$B
## [1] 1
## 
## $Obama$State
## [1] 0
## 
## 
## $Hillary
## $Hillary$Shares
## [1] 0 0 0 0
## 
## $Hillary$Balance
## [1] 4.852
## 
## $Hillary$B
## [1] 3.5
## 
## $Hillary$State
## [1] 0
```


This is an R Markdown document.


```r

# Tests/Demo
ShowPrices("Obama")
```

```
## [1] 0.5 0.5
```

```r
ShowPrices("Hillary")
```

```
## [1] 0.25 0.25 0.25 0.25
```

```r

QueryMove("Obama", 1, 0.6)  #
```

```
## [1] 0.4055
```

```r
QueryMove("Hillary", 3, 0.3)  #higher B increases liquidity
```

```
## [1] 0.8796
```

```r

QueryCost("Obama", 2, 1)
```

```
## [1] 0.6201
```

```r
QueryCost("Hillary", 1, 1)
```

```
## [1] 0.278
```


1 Trader, 1 Contract
------------------------

```r
# Tests
DisplayTest <- function() {
    print(Users$Alice)
    print(ShowPrices("Obama"))
    print(Markets$Obama$Shares)
}


DisplayTest()
```

```
## $Cash
## [1] 10
## 
## [1] 0.5 0.5
## [1] 0 0
```

```r

Buy("Alice", "Obama", 1, 0.6)
```

```
## [1] "Bought 0.405465108108164 for 0.22314355131421 ."
```

```
## [1] 0.4055 0.2231
```

```r
DisplayTest()
```

```
## $Cash
## [1] 9.777
## 
## $Obama
## State1 
## 0.4055 
## 
## [1] 0.6 0.4
## [1] 0.4055 0.0000
```

```r

Buy("Alice", "Obama", 1, 0.7)
```

```
## [1] "Bought 0.441832752279039 for 0.287682072451781 ."
```

```
## [1] 0.4418 0.2877
```

```r
DisplayTest()
```

```
## $Cash
## [1] 9.489
## 
## $Obama
## State1 
## 0.8473 
## 
## [1] 0.7 0.3
## [1] 0.8473 0.0000
```

```r

Sell("Alice", "Obama", 1, 0.6)
```

```
## [1] "Sold 0.441832752279039 for 0.287682072451781 ."
```

```
## [1] -0.4418 -0.2877
```

```r
DisplayTest()
```

```
## $Cash
## [1] 9.777
## 
## $Obama
## State1 
## 0.4055 
## 
## [1] 0.6 0.4
## [1] 0.4055 0.0000
```

```r

Sell("Alice", "Obama", 1, 0.5)  #reset
```

```
## [1] "Sold 0.405465108108164 for 0.22314355131421 ."
```

```
## [1] -0.4055 -0.2231
```

```r
DisplayTest()
```

```
## $Cash
## [1] 10
## 
## $Obama
## State1 
##      0 
## 
## [1] 0.5 0.5
## [1] 0 0
```

```r

Sell("Alice", "Obama", 1, 0.4)
```

```
## [1] "Insufficient Shares"
```

```r
DisplayTest()
```

```
## $Cash
## [1] 10
## 
## $Obama
## State1 
##      0 
## 
## [1] 0.5 0.5
## [1] 0 0
```

```r

# Needs Graphs.
```


Trades Revealing Effect of LMSR
-----------------------------------

```r

# Set 1

Sell("Alice", "Obama", 1, 0.5)  #reset
```

```
## [1] "Sold 0 for 0 ."
```

```
## [1] 0 0
```

```r
DisplayTest()
```

```
## $Cash
## [1] 10
## 
## $Obama
## State1 
##      0 
## 
## [1] 0.5 0.5
## [1] 0 0
```

```r

dLMSR <- data.frame(rbind(c(Buy("Alice", "Obama", 1, 0.6), 0.6), c(Buy("Alice", 
    "Obama", 1, 0.7), 0.7), c(Buy("Alice", "Obama", 1, 0.8), 0.8), c(Buy("Alice", 
    "Obama", 1, 0.9), 0.9), c(Buy("Alice", "Obama", 1, 0.999), 0.999)))
```

```
## [1] "Bought 0.405465108108164 for 0.22314355131421 ."
## [1] "Bought 0.441832752279039 for 0.287682072451781 ."
## [1] "Bought 0.538996500732687 for 0.405465108108165 ."
## [1] "Bought 0.810930216216329 for 0.693147180559945 ."
## [1] "Bought 4.70953020131233 for 4.60517018598809 ."
```

```r

colnames(dLMSR) <- c("Shares", "Cost", "mPrice")
plot(Cost ~ mPrice, main = "Cost of moving the price up by 10%", data = dLMSR)
lines(dLMSR$mPrice, dLMSR$Cost)
```

![plot of chunk LMRSEffect](figure/LMRSEffect1.png) 

```r

# Setting the probability to 1 is always impossible (very realistic)
Buy("Alice", "Obama", 1, 1)
```

```
## [1] "Insufficient Funds"
```

```r
QueryMoveCost("Obama", 1, 1)
```

```
## [1] Inf
```

```r




# Set 2

Sell("Alice", "Obama", 1, 0.5)  #reset
```

```
## [1] "Sold 6.90675477864855 for 6.21460809842219 ."
```

```
## [1] -6.907 -6.215
```

```r
DisplayTest()
```

```
## $Cash
## [1] 10
## 
## $Obama
## State1 
##      0 
## 
## [1] 0.5 0.5
## [1] 0 0
```

```r

Users$Alice$Cash <- 1000  #lots of cash



dLMSR2 <- data.frame(rbind(c(Buy("Alice", "Obama", 1, 0.9), 0.9), c(Buy("Alice", 
    "Obama", 1, 0.99), 0.99), c(Buy("Alice", "Obama", 1, 0.999), 0.999), c(Buy("Alice", 
    "Obama", 1, 0.9999), 0.9999), c(Buy("Alice", "Obama", 1, 0.99999), 0.99999), 
    c(Buy("Alice", "Obama", 1, 0.999999), 0.999999)))
```

```
## [1] "Bought 2.19722457733622 for 1.6094379124341 ."
## [1] "Bought 2.39789527279837 for 2.30258509299404 ."
## [1] "Bought 2.31163492851396 for 2.30258509299405 ."
## [1] "Bought 2.30348558832741 for 2.30258509299416 ."
## [1] "Bought 2.30267509794882 for 2.30258509299849 ."
## [1] "Bought 2.30259409301024 for 2.30258509296074 ."
```

```r

colnames(dLMSR2) <- c("Shares", "Cost", "mPrice")
dLMSR2 <- dLMSR2[-1, ]
dLMSR2$CumCost <- cumsum(dLMSR2$Cost)

plot(mPrice ~ CumCost, main = "Price impact from spending 2.302", data = dLMSR2)
lines(dLMSR2$CumCost, dLMSR2$mPrice)
```

![plot of chunk LMRSEffect](figure/LMRSEffect2.png) 




```r

Users$Alice
```

```
## $Cash
## [1] 986.9
## 
## $Obama
## State1 
##  13.82
```

```r
FinalSell("Alice", "Obama", 1, 1, 9.21024)
```

```
## [1] "FinalSold 9.21024 for 9.21024 ."
```

```
## [1] -9.21 -9.21
```

```r
Users$Alice
```

```
## $Cash
## [1] 996.1
## 
## $Obama
## State1 
##  4.605
```

```r
Markets$Obama
```

```
## $Shares
## [1] 4.605 0.000
## 
## $Balance
## [1] 4.605
## 
## $B
## [1] 1
## 
## $State
## [1] 0
```


