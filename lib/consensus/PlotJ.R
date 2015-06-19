
# Graphical Display of VoteMatrix Data
# Paul Sztorc
# Written in R (v 3.1.1) using Rstudio (v 0.98.1028)

if(!require(ggplot2)) install.packages('ggplot2')
if(!require(reshape2)) install.packages('reshape2')

if(!exists("Factory")) print("You have not loaded ConsensusMechanism.r")

PlotJ <- function(M, Scales = BinaryScales(M), Rep = DemocracyRep(M), Title="Plot of Judgement Space", TextSize=10) { 
  
  require(ggplot2)
  require(reshape2)
  try(detach("package:reshape", unload=TRUE), silent = TRUE) # if reshape and reshape2 are both loaded, there are errors...
  
  # Need Row Names..provide if missing
  if( is.null(row.names(M)) ) {
    cat( "\nGenerating row names...")
    row.names(M) <- paste("Voter", 1:nrow(M), sep=".")
  }
  
  # Non-unique row names, while valid, make for a confusing graphic.
  if( length(row.names(M)) > length(unique(row.names(M))) ) {
    cat( "\nForcing unique row names...")
    row.names(M) <- paste(1:nrow(M), row.names(M), sep=".")
  }
  
  # Use the SVD-Consensus
  Results <- Factory(M, Scales, Rep, CatchP=0)

  # Get Dimensions and Labels (who voted for what?)
  mResults <- melt(Results[["Filled"]])
  mResults$value <- factor( round(mResults$value, 4))
  mResults$Var1  <- factor(mResults$Var1)
  
  # Get Scores (opacity)
  SC <- data.frame(Var1=row.names(M), GainLoss = Results[["Agents"]][,"RowBonus"] - Results[["Agents"]][,"OldRep"])
  
  # Format Data
  DF <- merge(mResults,SC)
  names(DF) <- c("Voter","Decision","Outcome","Scores" ) # Purely to help code-readers understand R's ggplot below.
  
  # Add a way to vary the text size
  DF$TSize <- TextSize
  
  # Build the plot
  p1 <- ggplot(DF,aes(x=Outcome, y=1, alpha=Scores)) +  #   p1 <- ggplot(DF,aes(x=Outcome, y=1, fill=Voter, alpha=Scores)) +  # (with colors)
    geom_bar(stat="identity", colour="black") +
    geom_text(aes(label = Voter, vjust = 1, ymax = 1, size = TSize),
              position = "stack", alpha=I(1), show_guide = FALSE) +
    facet_grid(Decision ~ .)
    
  # Control the colours and labels

  p1f <- p1 +
#    scale_fill_hue(h=c(0,130)) +
    theme_bw() +
    scale_alpha_continuous(
      range = c(0,.9), #, range=c(.05,.9)) + # with colors
      breaks = sort( unique( DF$Scores ) ),
      labels = sort( round( unique( DF$Scores ), digits = 3 ) ),
      guide = guide_legend(title = "Rep Change")) + 
    theme( legend.position = "bottom", axis.title = element_text(size=( TextSize + 6 )) ) +
    xlab("Outcome") +
    ylab('Unscaled Votes') + 
    labs(title = Title)
  
  return(p1f)
}

# Whitepaper Figures

# M1
# row.names(M1)
# row.names(M1) <- paste("Voter", 1:6)
# M1
# PlotJ(M1)
# ggsave( filename = "figures/right.jpg", plot = PlotJ(M1), units = "in", height = 7.2, width = 4 ) 
# M2 <- rbind(M1, c(1,.5,0,0))
# M2
# for(i in 1:7) M2[i,] <- M2[7,]
# M2
# row.names(M2)[7] <- "Voter 7"
# M2
# M2[3,2] <- 1
# M2
# PlotJ(M2)
# ggsave( filename = "figures/left.jpg", plot = PlotJ(M2), units = "in", height = 7.2, width = 4 ) 
