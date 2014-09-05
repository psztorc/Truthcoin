
# Testing the SVD empirically via Website
# Paul Sztorc

## Load Data ##
print("Loading data..")

tryCatch(expr=setwd("~/GitHub/Truthcoin/lib"), error=function(e) setwd(choose.dir(caption="Failed to set working directory automatically. Choose 'Truthcoin/lib' folder:")) )

DataFile <- "demo/input/Questions_VoteMatrix.csv"
Data <- read.csv(DataFile, stringsAsFactors= FALSE, row.names=1)

print("Load Complete.")
print(" ")

## Get VoteMatrix ##
print("Getting Votes..")

ToMatrix <- function(DF) {
  RowNames <- row.names(DF)
  DFn <- data.frame ( lapply( DF, as.numeric) ) # make all observations numbers
  Matrix <- as.matrix(DFn,ncol = ncol(DF)) # save in matrix format
  row.names(Matrix) <- RowNames  # restore row names (lost during as.numeric)
  return(Matrix)
}

# Remove header info
VoteData <- Data[-1:-4,]
VoteMatrix <- ToMatrix(VoteData)

print(VoteMatrix)
print(" ")


## Rescale ##
print("Rescaling the Scaled Decisions..")

# Scaled claims must become range(0,1)

Scaled <- Data["Qtype",] == "S" # which of these are scaled at all?

# Rescale
ScaleData <- Data[c("Min", "Max"),Scaled] # get the scales from the 'Qtype' row, and nothing else
ScaleMatrix <- ToMatrix(ScaleData)


RescaledVoteMatrix <- VoteMatrix # declare destination data
for(i in 1:ncol(ScaleMatrix)) { # for each scaled decision
  
  ThisQ <- colnames(ScaleMatrix)[i]
  ThisColumn <- RescaledVoteMatrix[ , colnames(RescaledVoteMatrix)==ThisQ ] # match the right column
  RescaledColumn <- (ThisColumn - ScaleMatrix["Min",i]) / (ScaleMatrix["Max",i] - ScaleMatrix["Min",i])  # "rescale"
  
  RescaledVoteMatrix[ , colnames(RescaledVoteMatrix)==ThisQ ] <- RescaledColumn # Overwrite
}

print("Rescale Complete.")
print(" ")


## Do Computations ##

# Load what we need
print("Loading SVD Consensus Mechanism..")
source("consensus/ConsensusMechanism.r")

# I've already rescaled, but we still need to pass the boolean - must fix this.
ScaleData <- matrix( c( rep(FALSE,ncol(RescaledVoteMatrix)),
              rep(0,ncol(RescaledVoteMatrix)),
              rep(1,ncol(RescaledVoteMatrix))), 3, byrow=TRUE, dimnames=list(c("Scaled","Min","Max"),colnames(RescaledVoteMatrix)) )

ScaleData[1,] <- Scaled

# Get the Resuls
print("Calculating Results..")
SvdResults <- Factory(RescaledVoteMatrix,Scales = ScaleData)

print("Writing Output .csvs..")
print(" ")

write.csv(SvdResults$Original, file="demo/output/OriginalVoteMatrix.csv")
write.csv(SvdResults$Agents, file="demo/output/agents.csv")
write.csv(SvdResults$Decisions, file="demo/output/decisions.csv")

print("Loading Plot Functions..")
source("consensus/PlotJ.r")

print("Making Plot..")
Plot <- PlotJ(RescaledVoteMatrix, Scales = ScaleData)


svg("demo/output/plot.svg",width = 8.5,height = 11)
Plot
dev.off()

print("Plot Complete.")

print("Done!")