
# Display of VoteMatrix Data

if(!require(ggplot2)) install.packages('ggplot2')
if(!require(reshape2)) install.packages('reshape2')

if(!exists("Factory")) print("You have not loaded ConsensusMechanism.r")

PlotJ <- function(M, Scales = BinaryScales(M), Rep = DemocracyRep(M), Title="Plot of Judgement Space") { 
  
  require(ggplot2)
  require(reshape2)
  
  # Non unique row names, while valid, make for a confusing graphic.
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
  
  # Build the plot
  p1 <- ggplot(DF,aes(x=Outcome, y=1, fill=Voter, alpha=Scores)) +
    geom_bar(stat="identity", colour="black") +
    geom_text(aes(label = Voter, vjust = 1, ymax = 1), position = "stack", alpha=I(1)) +
    facet_grid(Decision ~ .)
  
  # Control the colours and labels
  p1f <- p1 +
    theme_bw() +
    scale_fill_hue(h=c(0,130)) +
    scale_alpha_continuous(guide=guide_legend(title = "Consensus Scores"), range=c(.05,.9)) +
    xlab("Outcome") +
    ylab('Unscaled Votes') + 
    labs(title = Title)
  
  return(p1f)
}