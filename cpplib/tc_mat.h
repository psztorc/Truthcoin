#ifndef TC_MAT_H
#define TC_MAT_H

#include <stdint.h>

struct tc_mat {
	double **a;
	uint32_t nr, nc;
};
struct tc_mat *tc_mat_ctr(uint32_t nr_, uint32_t nc_);
void tc_mat_dtr(struct tc_mat *);
void tc_mat_clear(struct tc_mat *);
void tc_mat_resize(struct tc_mat *, uint32_t nr_, uint32_t nc_);
void tc_mat_copy(struct tc_mat *, const struct tc_mat *);
void tc_mat_identity(struct tc_mat *);
void tc_mat_transpose(struct tc_mat *, const struct tc_mat *);
int tc_mat_add(struct tc_mat *, const struct tc_mat *A, const struct tc_mat *B);
int tc_mat_mult(struct tc_mat *, const struct tc_mat *A, const struct tc_mat *B);
int tc_mat_mult_scalar(struct tc_mat *, double a, const struct tc_mat *B);
int tc_mat_bidiag_decomp(const struct tc_mat *A, struct tc_mat *U, struct tc_mat *B, struct tc_mat *V);
int tc_mat_svd(const struct tc_mat *A, struct tc_mat *U, struct tc_mat *D, struct tc_mat *V);
void tc_mat_print(const struct tc_mat *);

#endif
