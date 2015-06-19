/*
 * CustomMath.r
 * A collection of relatively basic functions.
 */
#include <stdint.h>
#include <stdio.h>
#include "tc_matrix.h"

int main(int argc, char **argv)
{
// vector <- c(3,4,5)
// > vector
// [1] 3 4 5
// > AsMatrix(vector)
//       [,1]
// [1,]    3
// [2,]    4
// [3,]    5
	printf("AsMatrix\n");
	print(AsMatrix(c<uint32_t>(3, 3,4,5)));
	printf("\n");

// > MeanNA(c(3,4,6,7,8))
// [1] 3 4 6 7 8
//
// > MeanNA(c(3,NA,6,7,8))
// [1] 3 6 6 7 8
//
// > MeanNA(c(0,0,0,1,NA))
// [1] 0.00 0.00 0.00 1.00 0.25
//
// > MeanNA(c(0,0,NA,1,NA))
// [1] 0.0000000 0.0000000 0.3333333 1.0000000 0.3333333
	printf("MeanNA\n");
	print(MeanNA(c<uint32_t>(5, 3,4,6,7,8)));
	print(MeanNA(c<uint32_t>(5, 3,NA,6,7,8)));
	print(MeanNA(c<double>(5, 0.,0.,0.,1.,(double)NA)));
	print(MeanNA(c<double>(5, 0.,0.,(double)NA,1.,(double)NA)));
	printf("\n");


// > GetWeight(c(1,1,1,1))
// [1] 0.25 0.25 0.25 0.25
// > GetWeight(c(10,10,10,10))
// [1] 0.25 0.25 0.25 0.25
// > GetWeight(c(4,5,6,7))
// [1] 0.1818182 0.2272727 0.2727273 0.3181818
// > GetWeight(c(4,5,6,7),TRUE)
// [1] 0.2159091 0.2386364 0.2613636 0.2840909
	printf("GetWeight\n");
	print(GetWeight(c<double>(4, 1.,1.,1.,1.)));
	print(GetWeight(c<double>(4, 10.,10.,10.,10.)));
	print(GetWeight(c<double>(4, 4.,5.,6.,7.)));
	print(GetWeight(c<double>(4, 4.,5.,6.,7.),true));
	printf("\n");

// > Catch(.4)
// [1] 0
// > Catch(.5)
// [1] 0.5
// > Catch(.6)
// [1] 1
// > Catch(.6,Tolerance=.1)
// [1] 1
// > Catch(.6,Tolerance=.2)
// [1] 0.5
	printf("Catch\n");
	print(Catch(.4));
	print(Catch(.5));
	print(Catch(.6));
	print(Catch(.6, .1));
	print(Catch(.6, .2));
	printf("\n");

// > weighted.median(x=c(3,4,5),w=c(.2,.2,.6))
// [1] 5
// > weighted.median(x=c(3,4,5),w=c(.2,.2,.5))
// [1] 5
// > weighted.median(x=c(3,4,5),w=c(.2,.2,.4))
// [1] 4.5
	printf("weighted_median\n");
	print(weighted_median(c<double>(3,3.0,4.0,5.0),c<double>(3,.2,.2,.6)));
	print(weighted_median(c<double>(3,3.0,4.0,5.0),c<double>(3,.2,.2,.5)));
	print(weighted_median(c<double>(3,3.0,4.0,5.0),c<double>(3,.2,.2,.4)));
	printf("\n");

// Scales <- matrix( data=c( 0,    0,    0,    0,      1,          1,
//                           0,    0,    0,    0,      0,       8000,
//                           1,    1,    1,    1,    435,     20000 ), nrow=3, byrow=TRUE)
//                   
// colnames(Scales) <- c("C1.1", "C2.1", "C3.0", "C4.0", "C5.233", "C6.1602759")
// row.names(Scales) <- c("Scaled", "Min", "Max")  
// 
// Scales
// 
// M <- matrix( data=c(
//       1,    1,    0,    0,    233,   16027.59,
//       1,    0,    0,    0,    199,         NA,
//       1,    1,    0,    0,    233,   16027.59,
//       1,    1,    1,    0,    250,         NA,
//       0,    0,    1,    1,    435,    8001.00,
//       0,    0,    1,    1,    435,   19999.00),
//   nrow=6,byrow=TRUE)
//   
// colnames(M) <- c("C1.1", "C2.1", "C3.0", "C4.0", "C5.233", "C6.1602759")
// row.names(M) <- paste("Voter",1:6)
// 
// Rescale(M,Scales)
// 
// C1.1 C2.1 C3.0 C4.0    C5.233   C6.1602759
// Voter 1    1    1    0    0 0.5356322 6.689658e-01
// Voter 2    1    0    0    0 0.4574713           NA
// Voter 3    1    1    0    0 0.5356322 6.689658e-01
// Voter 4    1    1    1    0 0.5747126           NA
// Voter 5    0    0    1    1 1.0000000 8.333333e-05
// Voter 6    0    0    1    1 1.0000000 9.999167e-01
	printf("Rescale\n");
	tc_matrix<double> Scales = tc_matrix<double>(
			c<double>(18,
						0.0,  0.0,  0.0,  0.0,   1.0,     1.0,
						0.0,  0.0,  0.0,  0.0,   0.0,  8000.0,
						1.0,  1.0,  1.0,  1.0, 435.0, 20000.0), 3);
	Scales._col_names.push_back("C1.1");
	Scales._col_names.push_back("C1.1");
	Scales._col_names.push_back("C3.0");
	Scales._col_names.push_back("C4.0");
	Scales._col_names.push_back("C5.233");
	Scales._col_names.push_back("C6.1602759");
	tc_matrix<double> M = tc_matrix<double>(
			c<double>(36,
						1.0, 1.0, 0.0, 0.0, 233.0, 16027.59,
						1.0, 0.0, 0.0, 0.0, 199.0, (double)NA,
						1.0, 1.0, 0.0, 0.0, 233.0, 16027.59,
						1.0, 1.0, 1.0, 0.0, 255.0, (double)NA,
						0.0, 0.0, 1.0, 1.0, 435.0,  8001.00,
						0.0, 0.0, 1.0, 1.0, 435.0, 19999.00), 6);
	M._col_names.push_back("C1.1");
	M._col_names.push_back("C1.1");
	M._col_names.push_back("C3.0");
	M._col_names.push_back("C4.0");
	M._col_names.push_back("C5.233");
	M._col_names.push_back("C6.1602759");
	M._row_names.push_back("Voter 1");
	M._row_names.push_back("Voter 2");
	M._row_names.push_back("Voter 3");
	M._row_names.push_back("Voter 4");
	M._row_names.push_back("Voter 5");
	M._row_names.push_back("Voter 6");
	print(Rescale(M,Scales));
	printf("\n");

// > Influence(c(.25,.25,.25,.25))
// [1] 1 1 1 1
// > Influence(c(.3,.3,.4))
// [1] 0.9 0.9 1.2
// > Influence(c(.99,.0025,.0025,.0025,.0025))
// [1] 4.9500 0.0125 0.0125 0.0125 0.0125
	printf("Influence\n");
	print(Influence(c<double>(4, .25,.25,.25,.25)));
	print(Influence(c<double>(3, .3,.3,.4)));
	print(Influence(c<double>(5, .99,.0025,.0025,.0025,.0025)));
	printf("\n");

// > ReWeight(c(1,1,1,1))
// [1] 0.25 0.25 0.25 0.25
// > ReWeight(c(NA,1,NA,1))
// [1] 0.0 0.5 0.0 0.5
// > ReWeight(c(2,4,6,12))
// [1] 0.08333333 0.16666667 0.25000000 0.50000000
// > ReWeight(c(2,4,NA,12))
// [1] 0.1111111 0.2222222 0.0000000 0.6666667
	printf("Reweigt\n");
	print(ReWeight(c<double>(4, 1.,1.,1.,1.)));
	print(ReWeight(c<double>(4, (double)NA,1.,(double)NA,1.)));
	print(ReWeight(c<double>(4, 2.,4.,6.,12.)));
	print(ReWeight(c<double>(4, 2.,4.,(double)NA,12.)));
	printf("\n");

// M <- matrix(
//   nrow=3,
//   byrow=TRUE,
//   data=c(
//     0,0,1,
//     1,1,0,
//     0,0,0))
// 
//       [,1] [,2] [,3]
// [1,]    0    0    1
// [2,]    1    1    0
// [3,]    0    0    0
// > ReverseMatrix(M)
//       [,1] [,2] [,3]
// [1,]    1    1    0
// [2,]    0    0    1
// [3,]    1    1    1
	printf("ReverseMatrix\n");
	print(ReverseMatrix(tc_matrix<int32_t>(c<int32_t>(9, 0,0,1, 1,1,0, 0,0,0), 3)));
	printf("\n");

// M <- matrix(
//   nrow=3,
//   byrow=TRUE,
//   data=c(
//     0,0,1,
//     1,1,0,
//     0,0,0))
// 
// M2 <- cbind(M,c(.7,.5,.2))
// 
// > WeightedPrinComp(M)
// $Scores
// [1]  0.7251092 -0.9905177  0.2654084
// $Loadings
// [1] -0.6279630 -0.6279630  0.4597008
// 
// > WeightedPrinComp(M,c(.33333,.33333,.33333))
// $Scores
// [1]  0.7251092 -0.9905177  0.2654084
// $Loadings
// [1] -0.6279630 -0.6279630  0.4597008
// 
// > WeightedPrinComp(M,c(.1,.1,.8))
// $Scores
// [1]  0.2762801 -1.2732354  0.1246194
// $Loadings
// [1] -0.6989274 -0.6989274  0.1516607
// 
// > WeightedPrinComp(M2)
// $Scores
// [1]  0.7385624 -0.9866042  0.2480418
// $Loadings
// [1] -0.62428014 -0.62428014  0.46733010  0.04638101
// 
// > WeightedPrinComp(M2,c(.1,.1,.8))
// $Scores
// [1]  0.1269693 -1.2954637  0.1460618
// $Loadings
// [1] -0.69461121 -0.69461121  0.06807931 -0.17434371
	printf("WeightedPrinComp\n");
	M = tc_matrix<double>(
			c<double>(9,
						0.0,  0.0,  1.0,
						1.0,  1.0,  0.0,
						0.0,  0.0,  0.0), 3);
	tc_matrix<double> M2 = tc_matrix<double>(
			c<double>(12,
						0.0,  0.0,  1.0,  0.7,
						1.0,  1.0,  0.0,  0.5, 
						0.0,  0.0,  0.0,  0.2), 3);
	print(WeightedPrinComp(M));
	print(WeightedPrinComp(M, c<double>(3, .33333,.33333,.33333)));
	print(WeightedPrinComp(M, c<double>(3, .1,.1,.8)));
	print(WeightedPrinComp(M2));
	print(WeightedPrinComp(M2, c<double>(3, .1,.1,.8)));
	printf("\n");
	return 0;
}


