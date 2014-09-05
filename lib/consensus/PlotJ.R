
# Display of VoteMatrix Data

if(!require(ggplot2)) install.packages('ggplot2')
if(!require(reshape2)) install.packages('reshape2')

if(!exists("Factory")) print("You have not loaded ConsensusMechanism.r")

PlotJ <- function(M,Scales,Title="Plot of Judgement Space") { 
  
  require(ggplot2)
  require(reshape2)
  
  # Give unique names
  row.names(M) <- paste("Voter",1:nrow(M))
  
  # Use the SVD-Consensus
  Results <- Factory(M, Scales = ScaleData, CatchP=0)
  
  # Get Dimensions and Labels (who voted for what?)
  DF <- melt(Results[["Filled"]])
  DF$value <- factor( round(DF$value, 4))
  DF$Var1  <- factor(DF$Var1)
  
  # Get Scores (opacity)
  SC <- data.frame(Var1=rownames(M), Scores= Results[["Agents"]][,"ThisRep"])
  
  DF <- merge(DF,SC)
  
  p1 <- ggplot(DF,aes(x=value,fill=Var1,alpha=Scores)) +
    facet_grid(Var2~.) +
    geom_histogram() +
    geom_bar(aes(y=1),stat="identity", colour="black") 
  
  
  p1f <- p1 + theme_bw() +
    scale_fill_hue(h=c(10,90), guide=guide_legend(title = "Voter")) +
    scale_alpha_continuous(guide=guide_legend(title = "Consensus Scores"),range=c(.05,.8)) +
    xlab("Outcome") +
    ylab('Unscaled Votes') + 
    theme_grey() +
    labs(title = Title)
  return(p1f)
}