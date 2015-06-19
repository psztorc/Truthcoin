#include <math.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include "tc_data.h"

extern Branches Branches;
extern Decisions Decisions;
extern Markets Markets;

int main(int argc, char **argv)
{
	Branch *B = NULL;
	B = new Branch("Politics",
					"1M5tVTtynuqiS7Goq8hbh5UBcxLaa5XQb8",
					"Politics, particularly US Elections. No violence.",
					.02, 10, 200, 600, .0005, 26208, 2016, 2016, .80);
	Branches.AddBranch(B);

	const char *dec_desc[7] = {
		"Did Barack H Obama win the United States 2012 presidential election?",
		"Did the Democratic Party Candidate win the United States presidential election in 2016?",
		"Did the Democratic Party win (only) a majority of Senate seats?",
		"Did the Democratic Party win (only) a three-fifths supermajority of Senate seats (60+)?",
		"Did the Democratic Party win a two-thirds supermajority of Senate seats (67+)?",
		"Did the Democratic Party win (only) a majority of House seats?",
		"Did the Democratic Party win a two-thirds supermajority of House seats (290+)?",
	};
	const char *branch = "Politics";
	const char *addr = "1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh";
	uint32_t event_over_by = 5;
	Decision *D[7];
	for(uint32_t i=0; i < 7; i++) {
		D[i] = new Decision(branch, dec_desc[i], addr, event_over_by);
		Decisions.AddDecision(D[i]);
		printf("D[%d]->ID = \"%s\"\n", i, D[i]->ID.c_str());
	}
	printf("\n");

	// M1 <- list(
	// 	Market_ID=NA,
	//	Size=NA,
	//	Shares=NA,
	//	Balance=NA,
	//	FeeBalance=NA,
	//	State=1,
	//	B=1,
	//	TradingFee=.01,
	//	OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
	//	Title="Obama2012",
	//	Description="Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
	//	Tags=c("en", "UnitedStates", "Politics", "President", "Winner"),
	//	MaturationTime=5,
	//	D_State=list( "184b97f33923f30a9f586827b400676e" )	# Change
	// )
	//
	// M2 <- list(Market_ID=NA,
	//	Size=NA,
	//	Shares=NA,
	//	Balance=NA,
	//	FeeBalance=NA,
	//	State=1,
	//	B=2,
	//	TradingFee=.01,
	//	OwnerAd="1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",
	//	Title="Dems2016",
	//	Description="Democratic Control of the United States federal government following 2016 election.\nThis Market ...",
	//	Tags=c("en", "UnitedStates", "Politics", "President", "Congress"),
	//	MaturationTime=5,
	//	D_State=list( "2024304e88665e58b3147b9bfd33fb1f",	#Change
	//	  c("4bb76625de425c29ce52150cc5b3f160", "b8b085a2957ae1359056257cce61f0c8", "1800a5b6dc68dfddafbe4bf32ca813dc"),
	//	  c("b55b9a7faf26a97d0a06e16c7151ba33", "1d5ae87389527a9b9916fffd6b6b511c")
	//	)
	// )
	// 
	double TradingFee = 0.01;
	uint32_t Maturation_Time = 5;
	Market *M[2];
	const char *cTags1[5] = {"en", "UnitedStates", "Politics", "President", "Winner"};
	std::vector<std::string> Tags1;
	for(uint32_t i=0; i < 5; i++)
		Tags1.push_back(cTags1[i]);
	std::vector<std::vector<std::string> > D_State1;
	std::vector<std::string> tmp;
	tmp.push_back(D[0]->ID);
	D_State1.push_back(tmp);
	M[0] = new Market(1.0, TradingFee, addr, "Obama2012",
		"Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
		Tags1, Maturation_Time, D_State1);
	Markets.AddMarket(M[0]);

	const char *cTags2[5] = {"en", "UnitedStates", "Politics", "President", "Congress"};
	std::vector<std::string> Tags2;
	for(uint32_t i=0; i < 5; i++)
		Tags2.push_back(cTags2[i]);
	std::vector<std::vector<std::string> > D_State2;
	std::vector<std::string> tmp1;
	tmp1.push_back(D[1]->ID);
	std::vector<std::string> tmp2;
	tmp2.push_back(D[2]->ID);
	tmp2.push_back(D[3]->ID);
	tmp2.push_back(D[4]->ID);
	std::vector<std::string> tmp3;
	tmp3.push_back(D[5]->ID);
	tmp3.push_back(D[6]->ID);
	D_State2.push_back(tmp1);
	D_State2.push_back(tmp2);
	D_State2.push_back(tmp3);
	M[1] = new Market(2.0, TradingFee, addr, "Dems2016",
		"Democratic Control of the United States federal government following 2016 election.\nThis Market ...",
		Tags2, Maturation_Time, D_State2);
	Markets.AddMarket(M[1]);

	// > GetDim(M1)
	// [1] 2
	// > GetDim(M2)
	// [1] 2 4 3
	//
	//  > GetSpace(M1)
	//  d1.No d1.Yes
	//  1      2
	//
	//  > GetSpace(M2)
	//  , , d3.No
	// 
	//          d2.No d2.Yes d2.Yes d2.Yes
	//  d1.No      1      3      5      7
	//  d1.Yes     2      4      6      8
	// 
	//  , , d3.Yes
	// 
	//          d2.No d2.Yes d2.Yes d2.Yes
	//  d1.No      9     11     13     15
	//  d1.Yes    10     12     14     16
	// 
	//  , , d3.Yes
	// 
	//          d2.No d2.Yes d2.Yes d2.Yes
	//  d1.No     17     19     21     23
	//  d1.Yes    18     20     22     24
	//
	// note that d here refers to 'dimension' and not 'decision'
	//
	for(uint32_t i=0; i < 2; i++) {
		printf("M[%d]->ID = \"%s\"\n", i, M[i]->ID.c_str());
		printf("GetDim(M%d)\n", i);
		std::vector<uint32_t> dim = M[i]->GetDim();
		for(uint32_t j=0; j < dim.size(); j++)
			printf(" %u", (uint32_t)dim[j]);
		printf("\n");
		printf("GetSpace(M%d)\n", i);
		M[i]->GetSpace().print();
		printf("\n");
	}

	// Assume some Results
	// Decisions$State <- -1
	// Decisions$RuledOutcome <- c(1, 1, .4, .7, .9, 0, 0) # the most ridiculous results possible.
	// 
	// > GetOutcomeAxis(  M2$D_State[[1]] , TRUE )
	//       [,1] [,2]
	// [1,]   NA    1
	// [1] 0 1
	// > GetOutcomeAxis(  M2$D_State[[2]] , TRUE )
	//       [,1] [,2] [,3] [,4]
	// [1,]   NA  0.4   NA   NA
	// [2,]   NA   NA  0.7   NA
	// [3,]   NA   NA   NA  0.9
	// [1] 0.00 0.20 0.35 0.45
	// > GetOutcomeAxis(  M2$D_State[[3]] , TRUE )
	//       [,1] [,2] [,3]
	// [1,]   NA    0   NA
	// [2,]   NA   NA    0
	// [1] 1 0 0
	//
	double ruled_outcomes[7] = { 1.0, 1.0, 0.4, 0.7, 0.9, 0.0, 0.0};
	for(uint32_t i=0; i < 7; i++) {
		D[i]->State = -1;
		D[i]->RuledOutcome = ruled_outcomes[i];
	}
	for(uint32_t i=0; i < M[1]->D_State.size(); i++) {
		double sum = 0.0;
		for(uint32_t j=0; j < M[1]->D_State[i].size(); j++) {
			const Decision *d = Decisions[M[1]->D_State[i][j]];
			if (d) {
				printf("GetOutcomeAxis[%d,%d] = %.2f\n", j, j+1, d->RuledOutcome);
				sum += d->RuledOutcome;
			}
		}
		printf(" %d ", (sum > 0.0)? 0: 1);
		for(uint32_t j=0; j < M[1]->D_State[i].size(); j++) {
			const Decision *d = Decisions[M[1]->D_State[i][j]];
			if (d)
				printf(" %.2f", (sum > 0.0)? d->RuledOutcome/sum: d->RuledOutcome);
		}
		printf("\n");
	}

	return 0;
}
