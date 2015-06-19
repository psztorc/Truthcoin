#include <math.h>
#include <openssl/md5.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tc_data.h"

/*********************************************************************
 * Globals                                                           *
 *********************************************************************/

Branches Branches;
Decisions Decisions;
Markets Markets;
Users Users;

/*********************************************************************
 * Branch                                                            *
 * Branches                                                          *
 *********************************************************************/

/* 
 * ID <- digest(paste(unlist(Branch[1:-1]),collapse=''),serialize=FALSE,"md5")
 */
Branch::Branch(
	const std::string &Name_,
	const std::string &ExodusAddress_,
	const std::string &Description_,
	double BaseListingFee_,
	uint32_t FreeDecisions_,
	uint32_t TargetDecisions_,
	uint32_t MaxDecisions_,
	double MinimumTradingFee_,
	uint32_t VotingPeriod_,
	uint32_t BallotTime_,
	uint32_t UnsealTime_,
	double ConsensusThreshold_) 
 : Name(Name_),
	ExodusAddress(ExodusAddress_),
	Description(Description_),
	BaseListingFee(BaseListingFee_),
	FreeDecisions(FreeDecisions_),
	TargetDecisions(TargetDecisions_),
	MaxDecisions(MaxDecisions_),
	MinimumTradingFee(MinimumTradingFee_),
	VotingPeriod(VotingPeriod_),
	BallotTime(BallotTime_),
	UnsealTime(UnsealTime_),
	ConsensusThreshold(ConsensusThreshold_)
{
	char BaseListingFee_str[16];
	sprintf(BaseListingFee_str, "%.2f", BaseListingFee);
	char FreeDecisions_str[16];
	sprintf(FreeDecisions_str, "%d", FreeDecisions);
	char TargetDecisions_str[16];
	sprintf(TargetDecisions_str, "%d", TargetDecisions);
	char MaxDecisions_str[16];
	sprintf(MaxDecisions_str, "%d", MaxDecisions);
	char MinimumTradingFee_str[16];
	sprintf(MinimumTradingFee_str, "%.4f", MinimumTradingFee);
	char VotingPeriod_str[16];
	sprintf(VotingPeriod_str, "%d", VotingPeriod);
	char BallotTime_str[16];
	sprintf(BallotTime_str, "%d", BallotTime);
	char UnsealTime_str[16];
	sprintf(UnsealTime_str, "%d", UnsealTime);
	char ConsensusThreshold_str[16];
	sprintf(ConsensusThreshold_str, "%.2f", ConsensusThreshold);
	std::string str = "";
	str += Name;
	str += ExodusAddress;
	str += Description;
	str += std::string(BaseListingFee_str);
	str += std::string(FreeDecisions_str);
	str += std::string(TargetDecisions_str);
	str += std::string(MaxDecisions_str);
	str += std::string(MinimumTradingFee_str);
	str += std::string(VotingPeriod_str);
	str += std::string(BallotTime_str);
	str += std::string(UnsealTime_str);
	str += std::string(ConsensusThreshold_str);
	ID = tc_digest("md5", str.c_str(), strlen(str.c_str()));
}

const Branch *Branches::operator[](const std::string &ID) const
{
	std::map<std::string,Branch *>::const_iterator it = ID_to_Branch.find(ID);
	if (it == ID_to_Branch.end())
		return NULL;
	return it->second;
}

Branch *Branches::operator[](const std::string &ID)
{
	std::map<std::string,Branch *>::iterator it = ID_to_Branch.find(ID);
	if (it == ID_to_Branch.end())
		return NULL;
	return it->second;
}

const Branch *Branches::get_by_name(const std::string &Name) const
{
	for(std::map<std::string,Branch *>::const_iterator it=ID_to_Branch.begin(); it != ID_to_Branch.end(); it++)
		if (it->second->Name == Name)
			return it->second;
	return NULL;
}

Branch *Branches::get_by_name(const std::string &Name)
{
	for(std::map<std::string,Branch *>::iterator it=ID_to_Branch.begin(); it != ID_to_Branch.end(); it++)
		if (it->second->Name == Name)
			return it->second;
	return NULL;
}

/* AddBranch
 * Adds a New Branch to the mix. 
 */
int Branches::AddBranch(Branch *B)
{
	if ((*this)[B->ID]) /* ID already exists */
		return -1;
	if (get_by_name(B->Name)) {
		printf("A branch with that name already exists.\n");
		return -1;
	}
	/* Make sure parameters make sense */
	if (!((0 <= B->FreeDecisions)
			&& (B->FreeDecisions <= B->TargetDecisions)
			&& (B->TargetDecisions <= B->MaxDecisions)))
	{
		printf("Free/Target/Max Decisions must be non-negative and increasing\n");
		return -2;
	}
	if (B->BallotTime + B->UnsealTime >= B->VotingPeriod) {
		printf("Irregular overlap in voting periods. Provide longer inter-consensus time, or shorten Ballot / Unseal times.\n");
		return -3;
	}
	ID_to_Branch[B->ID] = B;
	return 0;
}

/*********************************************************************
 * Decision                                                          *
 * Decisions                                                         *
 *********************************************************************/

Decision::Decision(
	const std::string &Branch_,
	const std::string &Prompt_,
	const std::string &OwnerAd_,
	time_t EventOverBy_,
	bool Scaled_,
	double Min_,
	double Max_)
 : Branch(Branch_), Prompt(Prompt_), OwnerAd(OwnerAd_),
	EventOverBy(EventOverBy_), Scaled(Scaled_), Min(Min_), Max(Max_)
{
	char EventOverBy_str[16];
	sprintf(EventOverBy_str, "%u", (uint32_t)EventOverBy);
	std::string str = "";
	str += Branch;
	str += Prompt;
	str += OwnerAd;
	str += std::string(EventOverBy_str);
	ID = tc_digest("md5", str.c_str(), strlen(str.c_str()));
}

const Decision *Decisions::operator[](const std::string &ID) const
{
	std::map<std::string,Decision *>::const_iterator it = ID_to_Decision.find(ID);
	if (it == ID_to_Decision.end())
		return NULL;
	return it->second;
}

Decision *Decisions::operator[](const std::string &ID)
{
	std::map<std::string,Decision *>::iterator it = ID_to_Decision.find(ID);
	if (it == ID_to_Decision.end())
		return NULL;
	return it->second;
}

/* AddDecision
 */
int Decisions::AddDecision(Decision *D)
{
	if ((*this)[D->ID]) /* ID already exists */
		return -1;
	Branch *B = Branches.get_by_name(D->Branch);
	if (!B) 
		return -1;
	/* Check Availiable Space */
	uint32_t ExistingDecisionQuantity = 0;
	for(std::map<std::string,Decision *>::const_iterator it=ID_to_Decision.begin(); it != ID_to_Decision.end(); it++)
		if ((it->second->Branch == D->Branch) && (it->second->EventOverBy == D->EventOverBy))
			ExistingDecisionQuantity++;
	if (ExistingDecisionQuantity >= B->MaxDecisions) {
		printf("Too many Decisions in this Voting Period, move to another.\n");
        return -3;
	}
	/* Pay Required Fees */
	double FinalListFee = 0.0;
	if (ExistingDecisionQuantity <= B->FreeDecisions) {
		printf("Decision is free.\n");
		FinalListFee = 0;
	}
	else
	if (ExistingDecisionQuantity <= B->TargetDecisions) {
		printf("Decision costs Base amount.\n");
		FinalListFee = B->BaseListingFee;
	}
	else
	{
		printf("Decision costs Base amount.\n");
		FinalListFee = B->BaseListingFee + (ExistingDecisionQuantity - B->TargetDecisions)*B->BaseListingFee;
	}
	printf("FinalListFee %.1f\n", FinalListFee);
	ID_to_Decision[D->ID] = D;
	return 0;
}

/*********************************************************************
 * Market                                                            *
 * Markets                                                           *
 *********************************************************************/

void Space::print(void) const 
{
	double dim = D_State.size();
	if (dim < 1)
		return;
	const std::vector<std::string> &row_hdrs = Names[0];
	uint32_t count = 0;
	if (dim < 2) {
		for(uint32_t i=0; i < row_hdrs.size(); i++) {
			printf(" %-6s", row_hdrs[i].c_str());
			printf(" %6u", data[count++]);
			printf("\n");
		}
		return;
	}
	uint32_t MaxN = 1;
	for(uint32_t i=0; i < dim; i++)
		MaxN *= D_State[i].size() + 1;
	std::vector<uint32_t> index;
	for(uint32_t i=0; i < dim; i++)
		index.push_back(0);
	/* iterate over all tables of the first two dimensions */
	uint32_t nTables = MaxN / ((D_State[0].size()+1) * (D_State[1].size()+1));
	for(uint32_t table=0; table < nTables; table++) {
		if (dim > 2) {
			for(uint32_t i=0; i < index.size(); i++)
				printf(" %s,", (i<2)? "": Names[i][index[i]].c_str());
			printf("\n");
			for(uint32_t i=2; i < index.size(); i++) {
				index[i]++;
				if (index[i] == Names[i].size())
					index[i] = 0;
				else
					break;
			}
		}
		const std::vector<std::string> &col_hdrs = Names[1];
		printf(" %-6s", "");
		for(uint32_t j=0; j < col_hdrs.size(); j++)
			printf(" %-6s", col_hdrs[j].c_str());
		printf("\n");
		for(uint32_t i=0; i < row_hdrs.size(); i++) {
			printf(" %-6s", row_hdrs[i].c_str());
			for(uint32_t j=0; j < col_hdrs.size(); j++)
				printf(" %6u", data[count++]);
			printf("\n");
		}
		printf("\n");
	}
}

/* Market() constructor
 * Sets ID = md5 hash of the permanent features:
 *   B TradingFee OwnerAd Title Description Tags[] MaturationTime D_State
 * warning: in order to match R, must know the decimal places R uses for
 * each numerical value. for now, assume 2.
 * 
 * ID <- digest(paste(unlist(Market[-1:-6]),collapse=''),serialize=FALSE,"md5")
 * 
 * included in the construct is 
 * 
 * FillMarketInfo
 * Takes a basic, unfinished Market and fills out some details like the size,
 * hash, etc. Also calculates the required seed capital for a given B level.
 * For security and simplicity the Market is hashed after the B (and initial
 * balance) are set. Then one only needs to verify that the balance was truly established.
 * Other fields, such as balance and share, which would change constantly and
 * rapidly, are calcualted from the base ("blank") Market.
 * Size is calculated second-to-last on the final Market to account for
 * exponentially increasing Share space.
 *
 * AMM seed capital requirement is given as b*log(N), where N is the number of
 * states the Market must support.
 */

Market::Market(
	double B_,
	double TradingFee_,
	const std::string &OwnerAd_,
	const std::string &Title_,
	const std::string &Description_,
	const std::vector<std::string> &Tags_,
	time_t MaturationTime_,
	std::vector<std::vector<std::string> > &D_State_
	)
 :	B(B_),
	TradingFee(TradingFee_),
	OwnerAd(OwnerAd_),
	Title(Title_),
	Description(Description_),
	Tags(Tags_),
	MaturationTime(MaturationTime_),
	D_State(D_State_),
	State(1) /* 1 indicates active (ie "trading"), 2 = "contested", 3 = "redeemable" */
{
	char B_str[16];
	sprintf(B_str, "%.0f", B);
	char TradingFee_str[16];
	sprintf(TradingFee_str, "%.2f", TradingFee);
	char MaturationTime_str[16];
	sprintf(MaturationTime_str, "%u", (uint32_t)MaturationTime);
	std::string str = "";
	str += std::string(B_str);
	str += std::string(TradingFee_str);
	str += OwnerAd;
	str += Title;
	str += Description;
	for(uint32_t i=0; i < Tags.size(); i++)
		str += Tags[i]; 
	str += std::string(MaturationTime_str);
	for(uint32_t i=0; i < D_State.size(); i++)
		for(uint32_t j=0; j < D_State[i].size(); j++)
			str += D_State[i][j]; 
	ID = tc_digest("md5", str.c_str(), strlen(str.c_str()));
	
	MaturationTime = GetEndingDate();
	Space S = GetSpace();
	Shares = std::vector<double>(S.data.size(), 0.0);
	uint32_t Nstates = S.data.size();
	Balance = B * log((double)Nstates);
}

/* Market::GetDim
 * Infers, from the D_State ("decision space") the total size of this Markets.
 * each question corresponds to one partition of the space, thus for each dimension N questions yeilds N+1 states
 */
std::vector<uint32_t> Market::GetDim(bool Raw) const
{
	uint32_t adj = (Raw)? 1: 0;
	std::vector<uint32_t> r;
	for(uint32_t i=0; i < D_State.size(); i++)
		r.push_back( D_State[i].size() + adj );
	return r;
}

/* Market::GetSpace
 * Takes a Market, specifically its D_States, and constructs the array of possible ending states.
 * JSpace represents D_State[0] x D_State[1] x ... x D_State[n-1] possible outcomes
 */
Space Market::GetSpace(bool Verbose) const
{
	std::vector<uint32_t> Dim = GetDim();
	if (Verbose) {
		printf("Market Dimention(s):\n");
		for(uint32_t i=0; i < D_State.size(); i++) {
			const char *str = (i+1==D_State.size())? "": ",";
			printf("%d%s", (uint32_t)D_State[i].size(),str);
		}
		printf("\n");
	}
	Space S;
	S.D_State = D_State;
	for(uint32_t i=0; i < D_State.size(); i++) {
		std::vector<std::string> Names;
		for(uint32_t j=0; j < D_State[i].size()+1; j++) {
			char name[16];
			sprintf(name, "d%u.%s", i+1, ((j==0)? "No": "Yes"));
			Names.push_back(std::string(name));
		}
		S.Names.push_back(Names);
	}
	uint32_t MaxN = 1;
	for(uint32_t i=0; i < D_State.size(); i++)
		MaxN *= D_State[i].size() + 1;
	for(uint32_t i=0; i < MaxN; i++)
		S.data.push_back(i+1);
	return S;
}

/* GetEndingDate
 * grab the Decision IDs
 * extract the relevant section (match by ID, endings)
 */
time_t Market::GetEndingDate(void) const
{
	time_t max = (time_t) 0;
	for(uint32_t i=0; i < D_State.size(); i++) {
		for(uint32_t j=0; j < D_State[i].size(); j++) {
			std::string StateInfo = D_State[i][j];
			const Decision *D = Decisions[StateInfo];
			if (D && (D->EventOverBy > max))
				max = D->EventOverBy;
		}
	}
	return max;
}

const Market *Markets::operator[](const std::string &ID) const 
{
	std::map<std::string,Market *>::const_iterator it = ID_to_Market.find(ID);
	if (it == ID_to_Market.end())
		return NULL;
	return it->second;
}

Market *Markets::operator[](const std::string &ID) 
{
	std::map<std::string,Market *>::iterator it = ID_to_Market.find(ID);
	if (it == ID_to_Market.end())
		return NULL;
	return it->second;
}

/* ShowPrices 
 * Takes a Market and ID and returns the current market price.
 */
std::vector<double> Markets::ShowPrices(const std::string &ID) const
{
	std::vector<double> r;
	const Market *M = (*this)[ID];
	if (M) {
		uint32_t nStates = M->Shares.size();
		for(uint32_t i=0; i < nStates; i++) {
			double value = exp(M->Shares[i] / M->B) / nStates;
			r.push_back(value);
		}
	}
	return r;
}

/* QueryMove
 * How many shares would I need to buy of (ID,State) to move the probability to P?
 */
double Markets::QueryMove(const std::string &ID, uint32_t State, double P) 
{
	double Marginal = 0.0;
	std::vector<double> r;
	const Market *M = (*this)[ID];
	if (M) {
		uint32_t nStates = M->Shares.size();
		double sum = 0.0;
		std::vector<double> S;
		for(uint32_t i=0; i < nStates; i++) {
			double value = exp(M->Shares[i] / M->B);
			S.push_back(value);
			sum += value;
		}
		std::vector<double> Sstar;
		for(uint32_t i=0; i < nStates; i++) {
			double value = M->B * (log(P/1-P) + log(sum-S[i]));
			Sstar.push_back(value);
		}
		/* Marginal = ?? */
	}
	return Marginal;
}

/* QueryCost
 * What price will the market-maker demand for a purchase of S shares?  
 */
double Markets::QueryCost(const std::string &ID, uint32_t State, double S) 
{
	double cost = 0.0;
	const Market *M = (*this)[ID];
	if (M) {
		uint32_t nStates = M->Shares.size();
		double B = M->B;
		const std::vector<double> &S0 = M->Shares;
		double sum = 0.0;
		for(uint32_t i=0; i < nStates; i++)
			sum += exp(S0[i]/B);
		double LMSR = B * log(sum);
		std::vector<double> S1 = S0;
		for(uint32_t i=0; i < nStates; i++)
			S1[i] += S0[State];
		sum = 0.0;
		for(uint32_t i=0; i < nStates; i++)
			sum += exp(S1[i]/B);
		double LMSR2 = B * log(sum);
		cost = LMSR2 - LMSR;
	}
	return cost;
}

/* QueryMoveCost
 * How much would it cost to set the probability to P?
 */ 
double Markets::QueryMoveCost(const std::string &ID, uint32_t State, double P)
{
	double NewS = QueryMove(ID, State, P);
	return QueryCost(ID, State, NewS);
}

/* AddMarket
 * if the ID exists, return -1
 * otherwise add to Markets and return 0
 */
int Markets::AddMarket(Market *M)
{
	if ((*this)[M->ID])
		return -1;
	ID_to_Market[M->ID] = M;
	return 0;
}

/*********************************************************************
 * User                                                              *
 * Users                                                             *
 *********************************************************************/

User::User(const std::string &Name_, double Cash_)
 : Name(Name_), Cash(Cash_)
{

}

const User *Users::operator[](const std::string &uID) const 
{
	std::map<std::string,User *>::const_iterator it = uID_to_User.find(uID);
	if (it == uID_to_User.end())
		return NULL;
	return it->second;
}

User *Users::operator[](const std::string &uID) 
{
	std::map<std::string,User *>::iterator it = uID_to_User.find(uID);
	if (it == uID_to_User.end())
		return NULL;
	return it->second;
}

/* CreateAccount:
 * Creates an account filled with money. 
 * Obviously, this is a crucial step which will require (!) verification of Bitcoin payments,
 * an X-confirmation delay, etc. For testing we allow unconstrained (free/infinite) cash.
 * These accounts have simple toy names, actual accounts would be addresses themselves.
 */
int Users::AddUser(User *U)
{
	if ((*this)[U->Name])
		return -1;
	uID_to_User[U->Name] = U;
	return 0;
}

/*********************************************************************
 * functions                                                         *
 *********************************************************************/

std::string tc_digest(
	const char *algo,
	const char *ibytes,
	uint32_t nibytes)
{
	std::string ret("");
	if (algo && !strcmp(algo, "md5")) {
		uint8_t obytes[MD5_DIGEST_LENGTH];
		memset(obytes, 0, MD5_DIGEST_LENGTH);
		MD5_CTX ctx;
		MD5_Init(&ctx);
		MD5_Update(&ctx, ibytes, nibytes);
		MD5_Final(obytes, &ctx);
		char ret_cstr[2*MD5_DIGEST_LENGTH+1];
		for(uint32_t i=0; i < MD5_DIGEST_LENGTH; i++)
			sprintf(ret_cstr+2*i, "%02x", obytes[i]);
		ret = ret_cstr;
	}
	return ret;
}




/* Buy
 */
std::vector<double> Buy(const std::string &uID, const std::string &ID, uint32_t State, double P, bool Verbose)
{
	std::vector<double> r;
	Market *M = Markets[ID];
	User *U = Users[uID];
	if (!M || !U)
		return r;
	/* Calculate Required Cost */
	double BaseCost = Markets.QueryMoveCost(ID, State, P);	/*  trade cost assuming no fees */
	double Fee = BaseCost * M->TradingFee;					/* fees for buying only */
	double TotalCost = BaseCost + Fee;						/* Total cost including Fee */
	double MarginalShares = Markets.QueryMove(ID, State, P);
	if (MarginalShares < 0)
		printf("Price already exceeds target. Sell shares or buy a Mutually Exclusive State (MES).\n");
		return r;
	if (Verbose) {
		printf("Calulating Required Shares... %.8f\n", MarginalShares);
		printf("Determining Cost of Trade... %.8f\n", BaseCost);
		printf("Fee %.8f\n", Fee);
	}

	/* Reduce Funds, add Shares */
	if (U->Cash < TotalCost)
		printf("Insufficient Funds\n");
		return r;
	U->Cash -= TotalCost;
	#if 0
	OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]];
	if (is.null(OldShares))
		OldShares <- 0;
	Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares;
	#endif 
	
	/* Credit Funds, add Shares */
	M->Balance += BaseCost;
	M->FeeBalance += Fee;
	M->Shares[State] += MarginalShares;
	
	if (Verbose)
		printf("Bought %.8f for %.8f.\n", MarginalShares, TotalCost);
	r[0] = MarginalShares;
	r[1] = TotalCost;
	return r;
}

/* Sell
 */
std::vector<double> Sell(const std::string &uID, const std::string &ID, uint32_t State, double P, bool Verbose)
{
	std::vector<double> r;
	Market *M = Markets[ID];
	User *U = Users[uID];
	if (!M || !U)
		return r;
	if (M->State > 0) {
		printf("This market contains Disputed Decisions. Funds are frozen during audit.\n");
		return r;
	}
	double Cost = Markets.QueryMoveCost(ID, State, P);
	double MarginalShares = Markets.QueryMove(ID, State, P);
	if (MarginalShares > 0.0) {
		printf("Price already below target. Buy shares or sell a Mutually Exclusive State (MES).\n");
		return r;
	}
	if (Verbose) {
		printf("Calulating Required Shares... %.8f\n", MarginalShares);
		printf("Determining Cost of Trade... %.8f\n", Cost);
	}
	
	/* Reduce shares, add Funds */
	#if 0
	OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]]
	if (OldShares<(-1*MarginalShares))
		return ("Insufficient Shares") /* Remember, shares are negative. */
	Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares 
	#endif
	U->Cash -= Cost; /* Cost is also negative */
	
	/* Remove Funds and Shares from Market */
	M->Balance += Cost;
	M->Shares[State] += MarginalShares;
	if (Verbose)
		printf("Sold %.8f for %.8f.", MarginalShares, Cost);
	r[0] = MarginalShares;
	r[1] = Cost;
	return r;
}

#if 0
/* Redeem
 * NOT DONE !!! - This needs to be updated to support scaled claims.
 * This function takes over after the events state has been determined, and all shares now have a fixed value
 * Check Market Eligibility
 */
Redeem(uID, ID, State, S, bool Verbose) 
{
	ContractState <- Markets[[ID]]$State;
	if (ContractState == 1) {
		print("You cannot redeem (sell) using this function until there is a consensus about the outcome.");
		return -1;
	}
	if (ContractState == 2) {
		print("This market contains Disputed Decisions. Funds are frozen during audit.");
		return -2;
	}
	/* Check Share Ownership */
	OldShares <- Users[[uID]][[ID]][[paste("State",State,sep="")]];
	/* Users are expected to enter +3 if they wish to sell 3 shares, ie marginally change shares by -3. */
	MarginalShares <- S*-1;
	if (OldShares<(-1*MarginalShares)) {
		/* Remember, shares are negative. */
		print("Insufficient Shares");
		return -3;
	}
	/* Calculate Share Value (Simple joint-probability), and extracts the relevant price. */
	FinalPrice <- GetFinalPrices(Markets[[ID]])[State]
	Cost <- MarginalShares*FinalPrice[[1]] /* All shares have equal value, [[1]] to trim label */
	/* Reduce shares, add Funds */
	Users[[uID]][[ID]][[paste("State",State,sep="")]] <<- OldShares + MarginalShares /*  MarginalShares are negative */
	Users[[uID]]$Cash <<-  Users[[uID]]$Cash - Cost; /* Cost is negative */
	/* Remove Funds and Shares from Market */
	Markets[[ID]]$Balance <<-  Markets[[ID]]$Balance + Cost 
	Markets[[ID]]$Shares[State] <<- Markets[[ID]]$Shares[State] + MarginalShares 
	if (Verbose)
		print(paste("FinalSold",-1*MarginalShares,"for",-1*Cost,"."));
	return (c(MarginalShares,Cost));
	/* 
	 * Older stuff
	 *   ContractState <- try(Judged[Judged$Contract==ID,2])
	 *   if (Verbose) print(paste("Determined State of this Market:", ContractState))
	 *   Judged <- BlockChain[[length(BlockChain)]]$Jmatrix
	 */
}  
#endif 
