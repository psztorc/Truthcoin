# The Listing Fee Price - Costs and Updates to that Cost


GetQStandardDecisions <- function(BranchToAddOn, TauUntillAfterEvent) {
  # Takes a Branch, finds all the Decisions on that branch, at the right time, of the right type.
  
  RightBranch <- (Decisions$Branch==BranchToAddOn)
  RightTime <- (Decisions$TauFromNow==TauUntillAfterEvent)
  RightType <- (Decisions$Standard==1)
  
  if( sum(RightBranch,RightTime,RightType)==0 ) return(0)
  
  QStandardDecisions <- nrow( Decisions[(RightBranch & RightTime & RightType), ] )
  return( QStandardDecisions )
  
}

GetSlotInfo <- function(PreviousBaseFee, MaxSlots, Width=2, Log=TRUE) {
  # How much money did the Branch expect to take in (total Listing Fees, assuming the target was hit perfectly)?
  
  PentLength <- (MaxSlots/5)
  
  # Calculate Slot Costs - one of two ways
  if( Log) SlotPrices <- PreviousBaseFee * c( 1/Width, 1/exp(log(Width)/2),  1, exp(log(Width)/2), Width )
  if(!Log) SlotPrices <- PreviousBaseFee * c( 1/Width, mean(c(1, 1/Width)),  1, mean(c(1, Width)), Width )
  
  # Calculate Fee Multiple
  LogHalf <- exp(log(Width)/2) # log-scale version of "halfway" ...used above
  if( Log) Multiple <- ( LogHalf / (LogHalf + 1) ) 
  if(!Log) Multiple <- ( 4/7 )
  
  
  # Extra Info
  
  # The target is exactly half of the full Slot-range .. fully through 1 and 2, but only halfway through 3.
  ExpectedSlotUsage <- c(1, 1, .5, 0, 0) * PentLength 
  ExpectedSpend <- SlotPrices %*% ExpectedSlotUsage
  
  # All slots completely used
  MaxSlotUsage <- c(1, 1, 1, 1, 1) * PentLength 
  MaxSpend <- SlotPrices %*% MaxSlotUsage
  
  return( list(SlotPrices, Multiple, ExpectedSpend, MaxSpend) )
  
}


QueryCostToAuthorStandard <- function(BranchToAddOn="Politics", TauUntillAfterEvent=2) {
  # How much will it cost me to add a Decision to this Branch (at this Tau)

  # Get Branch parameters
  MaxDecisions <- Branches[ Branches$Name==BranchToAddOn, "MaxDecisions"]
  BaseFee <- Branches[ Branches$Name==BranchToAddOn, "BaseListingFee"]
  
  # How many Decisions have already been added
  ExistingDecisions  <-  GetQStandardDecisions(BranchToAddOn, TauUntillAfterEvent)
  
  # Check to make sure user is even allowed to Author Standard (are there enough slots?):
  if(ExistingDecisions==MaxDecisions) {
    print("Too many Standard Decisions already...you will have to use Overflow Decisions or select a different time (or different Branch).")
    return(-1)
  }
    
  # Which pent are we in?
  PentLength <- (MaxDecisions/5)
  Pent <- 1 + floor( ExistingDecisions / PentLength )
  
  SlotPrices <- GetSlotInfo(BaseFee, MaxDecisions)[[1]]
  Fee <- SlotPrices[Pent]
  
  print(paste("You are number",(ExistingDecisions+1),"of",MaxDecisions,", and are in Pentile",Pent,"."))
  print(paste("This period's base fee is",BaseFee, "so you must pay",Fee, "."))  
  return(Fee)
  
}


QueryCostToAuthorOverflow <- function(BranchToAddOn="Politics", TauUntillAfterEvent=2) {
  
  # Get Branch Parameter
  BaseFee <- Branches[ Branches$Name==BranchToAddOn, "BaseListingFee"]
  
  print(paste("This period's base fee is", BaseFee, "."))  
  return(BaseFee)
  
}





# After a Tau is done, it is time to get the new Base Fee.

CalcNewBaseFee <- function(PreviousBaseFee=0.02, MaxSlots=500, UsedSlots=490) {
  
  PentLength <- (MaxSlots/5)
  
  # Get Slot Economic Parameters
  SlotInfo <-  GetSlotInfo(PreviousBaseFee, MaxSlots)
  
  # Calc ActualSpend
  MaginalIndex <- UsedSlots - (PentLength * ((1:5)-1)) # The second term is "How many would be used if marginal?"
  FullSlots <- PentLength < MaginalIndex
  MarginalSlot <- sum(FullSlots) + 1
  
  ActualSlotUsage <- rep(0, 5) + ( rep(PentLength, 5) * FullSlots ) # Fill up all full slots
  ActualSlotUsage[MarginalSlot] <- MaginalIndex[MarginalSlot] # Add last marginal slot
  
  SlotCosts <- SlotInfo[[1]]
  ActualSpend <- SlotCosts %*% ActualSlotUsage
  

  # Calc New Fee
  Multiple <- SlotInfo[[2]]
  NewFee <- as.numeric( (ActualSpend/PentLength) * Multiple )
  
  return(NewFee)
}

UpdateBaseFee <- function(Branch) {
  # Takes a Branch, Calculates the New Base Fee and Installs it for the next round
  # Note...only run this once per Tau!

  # Get Parameters
  UsedSlots <- GetQStandardDecisions(Branch, Tau = 0)
  cur_PreviousBaseFee <- Branches[Branches$Name==Branch,"BaseListingFee"]
  cur_MaxSlots <- Branches[Branches$Name==Branch,"MaxDecisions"]
  
  # Calc Base Fee
  NewFee <- CalcNewBaseFee(cur_PreviousBaseFee, cur_MaxSlots, UsedSlots)
  
  # Edit Branch Parameter for next period
  Branches[Branches$Name==Branch,"BaseListingFee"] <<- NewFee
}


# Tests / Explanation

# Fee constantly retargets based on % of slots used.
# Below: Many slots were used, fee increases from 0.02 to 0.06351472
# > CalcNewBaseFee(PreviousBaseFee=0.02, MaxSlots=500, UsedSlots=490)
# [1] 0.06351472
# Below: sanity check... ( "Used Slots" = "Target Slots", price does not change )
# > CalcNewBaseFee(PreviousBaseFee=0.0222, MaxSlots=500, UsedSlots=250) 
# [1] 0.0222

# Below: Few slots were used, fee decreases from 0.020 to 0.004100505
# > CalcNewBaseFee(PreviousBaseFee=0.02, MaxSlots=500, UsedSlots=70)
# [1] 0.004100505
# Sanity check again:
# > CalcNewBaseFee(PreviousBaseFee=0.004100505, MaxSlots=500, UsedSlots=250) # sanity check
# [1] 0.004100505

# Final Example: Fee Increases Marginally
# > CalcNewBaseFee(PreviousBaseFee=0.02, MaxSlots=500, UsedSlots=280)
# [1] 0.02351472
