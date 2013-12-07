
#Contract Structure/Example



Use <- function(package) { if(suppressWarnings(!require(package,character.only=TRUE))) install.packages(package,repos="http://cran.case.edu/") ; require(package,character.only=TRUE) }
options(stringsAsFactors = FALSE)

#Objects


#Judgement Object
#MaxTags <- 8  #this should hold pretty much the whole universe, right?
#dumb idea--- pay per byte is better.

Use('digest')
Use('lubridate')

LongForm <- function(Ctr) return(unlist(Ctr))
#unlists the info - easier to hash (convienience only)

GetId <- function(CtrBlank,debug=0) {
  x <- LongForm(CtrBlank[-1])
  if(debug==1) print(x)
  return( digest(x,"md5") )
}

#GetId(c1)
#[1] "5d52d05f71b359c4a3c20a043e96aefd"


# #Flip Outcome - "Get Shadow"
# GetShadow <- function(CtrP) {
#   CtrS <- CtrP
#   CtrS$Outcome <- CtrP$Outcome==FALSE #not operation
#   #inverse the MutuallyExclusive - !
#   return(CtrS)
# }     

FillContract <- function(Ctr) {
  CtrNew <- Ctr
  CtrNew$Contract <- GetId(Ctr)
  #CtrNew$Shadow <- GetId(GetShadow(Ctr))
  return(CtrNew)
}

#Tests
#Contract Object
C1 <- data.frame(Contract=NA, #hash of c1[-1:-2]
            #Shadow=NULL,  #hash of mutually exclusive contracts
            OwnerAd="1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T", #the Bitcoin address of the creator of this contract
            Title="Obama2012",  #title - not necessarily unique

            Description="Barack Obama to win United States President in 2012\nThis contract will expire in state 1 if the statement is true and 0 otherwise.",
           #in practice, this will probably be pretty long.
           
            Tags=c("Politics, UnitedStates, President, Winner"), #ordinal descriptors
            EventOverBy=5           #block number
            #Outcome=TRUE,           #does it happen or not. (possibly redundant)
            #MutuallyExclusive=NULL  #relationship to other contracts
)

C1
cat(C1$Description)

C1 <- FillContract(C1)

#c1
#FillContract(c1)
#
#c1_S <- GetShadow(c1)
#FillContract(c1_S)
#
#FillContract(c1)[[1]] 
#FillContract(c1)[[1]]==FillContract(c1_S)[[2]] #TRUE
#FillContract(c1)[[2]]      
#FillContract(c1)[[2]]==FillContract(c1_S)[[1]] #TRUE
