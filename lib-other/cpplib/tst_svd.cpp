#ifdef HAVE_GSL
#include <gsl/gsl_linalg.h>
#endif
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
extern "C" {
#include "tc_mat.h"
}

#if 0
void tc_mat_print(const struct tc_mat *A)
{
	if (!A)
		return;
	for(uint32_t i=0; i < A->nr; i++) {
		for (uint32_t j=0; j < A->nc; j++)
			printf(" %11.8f", A->a[i][j]);
		printf("\n");
	}
}
#endif

#ifdef HAVE_GSL
int gsl_svd(
	const struct tc_mat *A,
	struct tc_mat *U,
	struct tc_mat *D,
	struct tc_mat *V)
{
	if (!A || !U || !D || !V)
		return -1;
	if ((U->nr != A->nr) || (U->nc != A->nc))
		tc_mat_resize(U, A->nr, A->nc);
	if ((V->nr != A->nc) || (V->nc != A->nc))
		tc_mat_resize(V, A->nc, A->nc);
	if ((D->nr != A->nc) || (D->nc != A->nc))
		tc_mat_resize(D, A->nc, A->nc);
	gsl_vector *gwork = gsl_vector_alloc(A->nc);
	gsl_vector *gS = gsl_vector_alloc(A->nc);
	gsl_matrix *gA = gsl_matrix_alloc(A->nr, A->nc);
	gsl_matrix *gV = gsl_matrix_alloc(A->nc, A->nc);
	for(uint32_t i=0; i < A->nr; i++)
		for(uint32_t j=0; j < A->nc; j++)
			gsl_matrix_set(gA, i, j, A->a[i][j]);
	gsl_set_error_handler_off();
	int status = gsl_linalg_SV_decomp(gA, gV, gS, gwork);
	if (status != GSL_SUCCESS)
		return -2;
	for(uint32_t i=0; i < U->nr; i++)
		for(uint32_t j=0; j < U->nc; j++)
			U->a[i][j] = gsl_matrix_get(gA, i, j);
	for(uint32_t i=0; i < D->nr; i++)
		for(uint32_t j=0; j < D->nc; j++)
			D->a[i][j] = (i==j)? gsl_vector_get(gS, i): 0.0;
	for(uint32_t i=0; i < V->nr; i++)
		for(uint32_t j=0; j < V->nc; j++)
			V->a[i][j] = gsl_matrix_get(gV, i, j);
	gsl_vector_free(gwork);
	gsl_vector_free(gS);
	gsl_matrix_free(gA);
	gsl_matrix_free(gV);
	return 0;
}
#endif

void test_svd(uint32_t nr, uint32_t nc)
{
	double max_error = nc * 4e-13;
	/* generate a random nr x nc matrix A */
	struct tc_mat *A = tc_mat_ctr(nr, nc);
	for(uint32_t i=0; i < nr; i++)
		for(uint32_t j=0; j < nc; j++)
			A->a[i][j] = 2.0*(rand()/1.0/RAND_MAX) - 1.0;

	struct tc_mat *U = tc_mat_ctr(0, 0);
	struct tc_mat *D = tc_mat_ctr(0, 0);
	struct tc_mat *V = tc_mat_ctr(0, 0);
	struct tc_mat *t = tc_mat_ctr(0, 0);

	/* compute svd via a call to tc_mat_svd    */
	int tc_rc = tc_mat_svd(A, U, D, V);
	/* compute tc_diff, the average difference */
	/* of the errors of A vs U D V^T           */
	tc_mat_transpose(t, V);
	tc_mat_mult(t, D, t);
	tc_mat_mult(t, U, t);
	double tc_diff = 0.0;
	for(uint32_t i=0; i < nc; i++)
		for(uint32_t j=0; j < nc; j++)
			tc_diff += fabs(t->a[i][j] - A->a[i][j]);
	tc_diff /= nr*nc;
	if (tc_diff > max_error) {
		/* if bigger than the expected max error, */
		/* print out the offending matrix         */
		printf("tc diff = %g\n", tc_diff);
		printf("rc %d\n", tc_rc);
		printf("a =\n"); tc_mat_print(A); printf("\n");
		printf("u =\n"); tc_mat_print(U); printf("\n");
		printf("d =\n"); tc_mat_print(D); printf("\n");
		printf("v =\n"); tc_mat_print(V); printf("\n");
		printf("t =\n"); tc_mat_print(t); printf("\n");
	}

	/* compute svd via a call to gsl's svd     */
	#ifdef HAVE_GSL
	int gsl_rc = gsl_svd(A, U, D, V);
	tc_mat_transpose(t, V);
	tc_mat_mult(t, D, t);
	tc_mat_mult(t, U, t);
	double gsl_diff = 0.0;
	for(uint32_t i=0; i < nr; i++)
		for(uint32_t j=0; j < nc; j++)
			gsl_diff += fabs(t->a[i][j] - A->a[i][j]);
	gsl_diff /= nr*nc;
	if ((gsl_diff > max_error) || (tc_diff > max_error)) {
		printf("gsl diff = %g\n", gsl_diff);
		printf("rc %d\n", gsl_rc);
		printf("A =\n"); tc_mat_print(A); printf("\n");
		printf("U =\n"); tc_mat_print(U); printf("\n");
		printf("D =\n"); tc_mat_print(D); printf("\n");
		printf("V =\n"); tc_mat_print(V); printf("\n");
		printf("t =\n"); tc_mat_print(t); printf("\n");
	}
	#endif
	tc_mat_dtr(t);
	tc_mat_dtr(U);
	tc_mat_dtr(D);
	tc_mat_dtr(V);
	tc_mat_dtr(A);
}

int main(int argc, char **argv) 
{
	srand(time(NULL));
	uint32_t tests_cfg[10][3] = {
		{2, 2, 50000}, /* test 50000 2 x 2 random matrices */
		{3, 3, 50000}, /* test 50000 2 x 2 random matrices */
		{4, 2, 50000}, 
		{10, 4, 10000}, 
		{10, 10,  5000},
		{37, 5, 1000}, 
		{20, 20,  500},
		{40, 40,  50},
		{80, 80,  5},
		{100, 100, 1},
	};
	for(uint32_t i=0; i < 10; i++) {
		uint32_t nrows = tests_cfg[i][0];
		uint32_t ncols = tests_cfg[i][1];
		uint32_t ntests = tests_cfg[i][2];
		printf("testing %u x %u ...\n", nrows, ncols); 
		for(uint32_t i=0; i < ntests; i++)
			test_svd(nrows, ncols);
	}
	return 0;
}
