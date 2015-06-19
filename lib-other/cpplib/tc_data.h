#ifndef TC_DATA_H
#define TC_DATA_H

#include <map>
#include <stdint.h>
#include <string>
#include <time.h>
#include <vector>


/* Branch
 * Branches
 */
struct Branch {
public:
	Branch(const std::string &Name_,
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
		double ConsensusThreshold_);
public:
	std::string ID;
	std::string Name; 
	std::string ExodusAddress;
	std::string Description;
	double BaseListingFee;
	uint32_t FreeDecisions;
	uint32_t TargetDecisions;
	uint32_t MaxDecisions;
	double MinimumTradingFee;
	uint32_t VotingPeriod;
	uint32_t BallotTime;
	uint32_t UnsealTime;
	double ConsensusThreshold;
};

class Branches {
public:
	Branches(void) { }
	~Branches(void) { }
	const Branch *operator[](const std::string &ID) const;
	Branch *operator[](const std::string &ID);
	const Branch *get_by_name(const std::string &Name) const;
	Branch *get_by_name(const std::string &Name);
	int AddBranch(Branch *);
protected:
	std::map<std::string,Branch *> ID_to_Branch;
};



/* Decision
 * Decisions
 */
struct Decision {
public:
	Decision(
		const std::string &Branch_,
		const std::string &Prompt_,
		const std::string &OwnerAd_,
		time_t EventOverBy_,
		bool Scaled_=false,
		double Min_=0.0,
		double Max_=1.0);
public:
	std::string ID;
	uint32_t State;
	double RuledOutcome;
	uint32_t Size;
	std::string Branch;
	std::string Prompt;
	std::string OwnerAd;
	time_t EventOverBy;
	bool Scaled;
	double Min; 
	double Max;
};

class Decisions {
public:
	Decisions(void) { }
	~Decisions(void) { }
	const Decision *operator[](const std::string &ID) const;
	Decision *operator[](const std::string &ID);
	int AddDecision(Decision *);
protected:
	std::map<std::string,Decision *> ID_to_Decision;
};



/* Market  
 * Markets  
 */
struct Space {
	std::vector< std::vector<std::string> > D_State;
	std::vector< std::vector<std::string> > Names;
	std::vector<uint32_t> data;
	void print(void) const;
};

struct Market {
public:
	Market(
		double B_,
		double TradingFee_,
		const std::string &OwnerAd_,
		const std::string &Title_,
		const std::string &Description_,
		const std::vector<std::string> &Tags_,
		time_t MaturationTime_,
		std::vector<std::vector<std::string> > &D_State_
	);
	std::vector<uint32_t> GetDim(bool Raw=true) const;
	Space GetSpace(bool Verbose=false) const;
	time_t GetEndingDate(void) const;
	void FillMarketInfo(void);
public:
	/* permanent features */
	double B; /* liquidity parameter */
	double TradingFee;
	std::string OwnerAd;
	std::string Title;
	std::string Description;
	std::vector<std::string> Tags;
	time_t MaturationTime;
	std::vector< std::vector<std::string> > D_State;
	/* ID based on permanent features */
	std::string ID;
	/* features which change during trading */
	uint32_t Size; /* number bytes */
	std::vector<double> Shares;
	double Balance;
	double FeeBalance;
	uint32_t State;
};

class Markets {
public:
	Markets(void) { }
	~Markets(void) { }
	const Market *operator[](const std::string &ID) const;
	Market *operator[](const std::string &ID);
	std::vector<double> ShowPrices(const std::string &ID) const;
	double QueryMove(const std::string &ID, uint32_t State, double P);
	double QueryCost(const std::string &ID, uint32_t State, double S);
	double QueryMoveCost(const std::string &ID, uint32_t State, double P);
	int AddMarket(Market *);
protected:
	std::map<std::string,Market *> ID_to_Market;
};


/* User    
 * Users    
 */
struct User {
public:
	User(const std::string &Name_, double Cash_);
public:
	std::string Name; /* treated as ID */
	double Cash;
};

class Users {
public:
	Users(void) { }
	~Users(void) { }
public:
	const User *operator[](const std::string &uID) const;
	User *operator[](const std::string &uID);
	int AddUser(User *);
protected:
	std::map<std::string,User *> uID_to_User;
};


std::string tc_digest(const char *algo, const char *ibytes, uint32_t nibytes);
std::vector<double> Buy(const std::string &uID, const std::string &ID,
		uint32_t State, double P, bool Verbose);
std::vector<double> Sell(const std::string &uID, const std::string &ID,
		uint32_t State, double P, bool Verbose);

#endif

