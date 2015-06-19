#include <math.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <string>
#include <stdlib.h>
#include <vector>
extern "C" {
#include "tc_mat.h"
}

#ifndef NULL
#define NULL		(0)
#endif

#ifndef NA
#define NA			4194832096
#endif


#ifndef INFINITY
#define INFINITY	(1/0)
#endif

/****************************************************************
 * tc_vector                                                    *
 ****************************************************************/

template <class T>
struct tc_vector
	: public std::vector<T>
{
	tc_vector<T>(void);
	tc_vector<T>(const std::vector<T> &);
	tc_vector<T>(const tc_vector<T> &);
	tc_vector<T>(T);
	~tc_vector<T>(void);
public:
	tc_vector<T> operator[](const tc_vector<bool> &) const;
	tc_vector<T> operator[](const tc_vector<uint32_t> &) const;
	T operator[](uint32_t) const;
	T &operator[](uint32_t);
	tc_vector<T> &operator=(const tc_vector<T> &);
	tc_vector<T> operator+(T) const;
	tc_vector<T> operator-(T) const;
	tc_vector<T> operator*(T) const;
	tc_vector<T> operator/(T) const;
	tc_vector<T> operator+(const tc_vector<T> &) const;
	tc_vector<T> operator-(const tc_vector<T> &) const;
	tc_vector<T> operator*(const tc_vector<T> &) const;
	tc_vector<T> operator/(const tc_vector<T> &) const;
	tc_vector<T> operator|(const tc_vector<T> &) const;
	tc_vector<bool> operator<(T) const;
	tc_vector<bool> operator<=(T) const;
	tc_vector<bool> operator>(T) const;
	tc_vector<bool> operator>=(T) const;
	void set(const tc_vector<bool> &, T);
};

/****************************************************************
 * tc_vector functions                                          *
 ****************************************************************/

tc_vector<bool> operator!(const tc_vector<bool> &x)
{
	tc_vector<bool> v;
	for(uint32_t i=0; i < x.size(); i++)
		v.push_back(!x[i]);
	return v;
}

template <class T>
tc_vector<T>::tc_vector(T x)
{
	this->push_back(x);
}

template <class T>
tc_vector<T>::tc_vector(void)
{

}

template <class T>
tc_vector<T>::tc_vector(const std::vector<T> &v)
 : std::vector<T>(v)
{

}

template <class T>
tc_vector<T>::tc_vector(const tc_vector<T> &v)
{
	for(uint32_t i=0; i < v.size(); i++)
		this->push_back(v[i]);
}

template <class T>
tc_vector<T>::~tc_vector(void)
{

}

template <class T>
tc_vector<T> c(int argc, ...)
{
	tc_vector<T> v;
	va_list ap;
	va_start(ap, argc);
	for(uint32_t i=0; i < argc; i++)
		v.push_back( va_arg(ap, T) );
	va_end(ap);
	return v;
}

template <class T>
T tc_vector<T>::operator[](uint32_t i) const
{
	return std::vector<T>::operator[](i);
}

template <class T>
T &tc_vector<T>::operator[](uint32_t i) 
{
	return std::vector<T>::operator[](i);
}

template <class T>
tc_vector<T> tc_vector<T>::operator[](const tc_vector<bool> &I) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < I.size(); i++)
		if ((I[i]) && (i < this->size()))
			v.push_back(this->operator[](i));
	return v;
}

template <class T>
tc_vector<T> tc_vector<T>::operator[](const tc_vector<uint32_t> &I) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < I.size(); i++) {
		if (I[i] < this->size())
			v.push_back( this->operator[](I[i]) );
		else
			v.push_back(NA);
	}
	return v;
}

template <class T>
tc_vector<T> &tc_vector<T>::operator=(const tc_vector<T> &v)
{
	if (this != &v) {
		this->clear();
		for(uint32_t i=0; i < v.size(); i++)
			this->push_back(v[i]);
	}
	return *this;
}

template <class T>
tc_vector<T> tc_vector<T>::operator+(T y) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		v.push_back( (x==NA)? NA: x + y );
	}
	return v;
}

template <class T>
tc_vector<T> tc_vector<T>::operator-(T y) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		v.push_back( (x==NA)? NA: x - y );
	}
	return v;
}

template <class T>
tc_vector<T> tc_vector<T>::operator*(T y) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		v.push_back( (x==NA)? NA: x * y );
	}
	return v;
}

template <class T>
tc_vector<T> tc_vector<T>::operator/(T y) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		v.push_back( (x==NA)? NA: x / y );
	}
	return v;
}


template <class T>
tc_vector<T> tc_vector<T>::operator+(const tc_vector<T> &z) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		T y = (i < z.size())? z[i]: NA;
		v.push_back( (x==NA || y==NA)? NA: x + y );
	}
	return v;
}

template <class T>
tc_vector<T> tc_vector<T>::operator-(const tc_vector<T> &z) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		T y = (i < z.size())? z[i]: NA;
		v.push_back( (x==NA || y==NA)? NA: x - y );
	}
	return v;
}

template <class T>
tc_vector<T> tc_vector<T>::operator*(const tc_vector<T> &z) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		T y = (i < z.size())? z[i]: NA;
		v.push_back( (x==NA || y==NA)? NA: x * y );
	}
	return v;
}

template <class T>
tc_vector<T> tc_vector<T>::operator/(const tc_vector<T> &z) const
{
	tc_vector<T> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		T y = (i < z.size())? z[i]: NA;
		v.push_back( (x==NA || y==NA)? NA: x / y );
	}
	return v;
}

template <class T>
tc_vector<T> tc_vector<T>::operator|(const tc_vector<T> &z) const
{
	tc_vector<bool> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		T y = (i < z.size())? z[i]: NA;
		v.push_back( (x==NA)? NA: (x | y));
	}
	return v;
}

template <class T>
tc_vector<bool> tc_vector<T>::operator<(T y) const
{
	tc_vector<bool> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		v.push_back( (x==NA)? NA: (x < y));
	}
	return v;
}

template <class T>
tc_vector<bool> tc_vector<T>::operator<=(T y) const
{
	tc_vector<bool> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		v.push_back( (x==NA)? NA: (x <= y));
	}
	return v;
}

template <class T>
tc_vector<bool> tc_vector<T>::operator>(T y) const
{
	tc_vector<bool> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		v.push_back( (x==NA)? NA: (x > y));
	}
	return v;
}

template <class T>
tc_vector<bool> tc_vector<T>::operator>=(T y) const
{
	tc_vector<bool> v;
	for(uint32_t i=0; i < this->size(); i++) {
		T x = this->operator[](i);
		v.push_back( (x==NA)? NA: (x >= y));
	}
	return v;
}

template <class T>
void tc_vector<T>::set(const tc_vector<bool> &I, T x)
{
	for(int i=0; i < I.size(); i++)
		if ((I[i]) && (i < this->size()))
			this->operator[](i) = x;
}

template <class T>
uint32_t length(const tc_vector<T> &v)
{
	return v.size();
}

template <class T>
bool missing(const tc_vector<T> &v)
{
	return (v.size() == 0)? true: false;
}

template <class T>
tc_vector<T> rep(T x, uint32_t len)
{
	tc_vector<T> v;
	for(uint32_t i=0; i < len; i++)
		v.push_back(x);
	return v;
}

template <class T>
tc_vector<bool> is_na(const tc_vector<T> &v)
{
	tc_vector<bool> r;
	for(uint32_t i=0; i < v.size(); i++)
		r.push_back( ((v[i] == NA)? true: false) );
	return r;
}

template <class T>
tc_vector<bool> is_infinite(const tc_vector<T> &v)
{
	tc_vector<bool> r;
	for(uint32_t i=0; i < v.size(); i++)
		r.push_back( ((v[i] == INFINITY)? true: false) );
	return r;
}

bool any(const tc_vector<bool> &v)
{
	for(uint32_t i=0; i < v.size(); i++)
		if (v[i])
			return true;
	return false;
}

template <class T>
tc_vector<uint32_t> order(tc_vector<T> v)
{
	tc_vector<uint32_t> x;
	for(uint32_t i=0; i < v.size(); i++)
		x.push_back(i);
	for(uint32_t i=0; i < v.size(); i++) {
		for(uint32_t j=i+1; j < v.size(); j++) {
			if (v[i] > v[j]) {
				T tmp = v[i];
				v[i] = v[j];
				v[j] = tmp;
				uint32_t itmp = x[i];
				x[i] = x[j];
				x[j] = itmp;
			}
		}
	}
	return x;
}

template <class T>
bool identical(const tc_vector<T> &v1, const tc_vector<T> &v2)
{
	if (v1.size() != v2.size())
		return false;
	for(uint32_t i=0; i < v1.size(); i++)
		if (v1[i] != v2[i])
			return false;
	return true;
}

uint32_t sum(const tc_vector<bool> &v, bool na_rm=true)
{
	uint32_t x = 0;
	for(uint32_t i=0; i < v.size(); i++)
		if ((na_rm) && (v[i] != NA))
			x += (v[i])? 1: 0;
	return x;
}

uint32_t sum(const tc_vector<uint32_t> &v, bool na_rm=true)
{
	uint32_t x = 0;
	for(uint32_t i=0; i < v.size(); i++)
		if ((na_rm) && (v[i] != NA))
			x += v[i];
	return x;
}

double sum(const tc_vector<double> &v, bool na_rm=true)
{
	double x = 0;
	for(uint32_t i=0; i < v.size(); i++)
		if ((na_rm) && (v[i] != NA))
			x += v[i];
	return x;
}

template <class T>
tc_vector<T> cumsum(const tc_vector<T> &v)
{
	tc_vector<T> r;
	T x = (T) 0;
	for(uint32_t i=0; i < v.size(); i++) {
		if ((x != NA) && v[i] != NA)
			x += v[i];
		else
			x = NA;
		r.push_back(x);
	}
	return r;
}

template <class T>
T mean(const tc_vector<T> &v, bool na_rm=true)
{
	T x = (T) 0;
	uint32_t count = 0;
	for(uint32_t i=0; i < v.size(); i++) {
		if ((na_rm) && (v[i] != NA)) {
			x += v[i];
			count++;
		}
	}
	return (count > 0)? x/count: NA;
}

template <class T>
T max(const tc_vector<T> &v)
{
	if (v.size() == 0)
		return NA;
	T x = v[0];
	for(uint32_t i=1; i < v.size(); i++)
		if ((v[i] != NA) && (v[i] > x))
			x = v[i];
	return x;
}

template <class T>
T min(const tc_vector<T> &v)
{
	if (v.size() == 0)
		return NA;
	T x = v[0];
	for(uint32_t i=1; i < v.size(); i++)
		if ((v[i] != NA) && (v[i] < x))
			x = v[i];
	return x;
}

template <class T>
tc_vector<T> abs(const tc_vector<T> &v, bool na_rm=true)
{
	tc_vector<T> r;
	for(uint32_t i=0; i < v.size(); i++)
		if (!((na_rm) && (v[i] == NA)))
			r.push_back( (v[i] > 0)? v[i]: -v[i] );
	return r;
}

tc_vector<double> exp(const tc_vector<double> &v)
{
	tc_vector<double> r;
	for(uint32_t i=0; i < v.size(); i++)
		r.push_back( (v[i] == NA)? NA: exp(v[i]) );
	return r;
}

tc_vector<double> log(const tc_vector<double> &v)
{
	tc_vector<double> r;
	for(uint32_t i=0; i < v.size(); i++)
		r.push_back( (v[i] == NA || v[i] <= 0.0)? NA: log(v[i]) );
	return r;
}


void print(const tc_vector<double> &v)
{
	for(uint32_t i=0; i < v.size(); i++)
		if (v[i] == NA)
			printf(" NA");
		else
			printf(" %.5f", v[i]);
	printf("\n");
}

void print(const tc_vector<uint32_t> &v)
{
	for(uint32_t i=0; i < v.size(); i++)
		if (v[i] == NA)
			printf(" NA");
		else
			printf(" %u", v[i]);
	printf("\n");
}

void print(const tc_vector<int32_t> &v)
{
	for(uint32_t i=0; i < v.size(); i++)
		if (v[i] == NA)
			printf(" NA");
		else
			printf(" %d", v[i]);
	printf("\n");
}

void print(const tc_vector<bool> &v)
{
	for(uint32_t i=0; i < v.size(); i++)
		if (v[i] == NA)
			printf(" NA");
		else
			printf(" %s", (v[i]? "true": "false"));
	printf("\n");
}

void print(double x) 
{
	if (x == NA)
		printf(" NA\n");
	else
		printf(" %.5f\n", x);
}

/****************************************************************
 * tc_matrix                                                    *
 ****************************************************************/

template <class T>
struct tc_matrix
	: public tc_vector<T>
{
public:
	tc_matrix<T>(void); 
	tc_matrix<T>(const tc_matrix<T> &);
	tc_matrix<T>(const tc_vector<T> &, uint32_t nrow);
	T operator()(uint32_t i, uint32_t j) const { return this->operator[](i*ncol(*this) + j); }
	T &operator()(uint32_t i, uint32_t j) { return this->operator[](i*ncol(*this) + j); }
	tc_matrix<T> &operator=(const tc_matrix<T> &);
public:
	std::vector<std::string> _col_names;
	std::vector<std::string> _row_names;
	uint32_t _nrow;
};

/****************************************************************
 * tc_matrix functions                                          *
 ****************************************************************/

template <class T>
uint32_t nrow(const struct tc_matrix<T> &m) { return m._nrow; }

template <class T>
uint32_t ncol(const struct tc_matrix<T> &m) { return m.size() / m._nrow; }

template <class T>
tc_matrix<T>::tc_matrix(void)
 : tc_vector<T>(), _nrow(0)
{

}

template <class T>
tc_matrix<T>::tc_matrix(const tc_matrix<T> &m)
 : tc_vector<T>(m), _col_names(m._col_names), _row_names(m._row_names), _nrow(m._nrow)
{

}

template <class T>
tc_matrix<T>::tc_matrix(const tc_vector<T> &v, uint32_t nrow)
 : tc_vector<T>(v), _nrow(nrow)
{

}

template <class T>
tc_matrix<T> &tc_matrix<T>::operator=(const tc_matrix<T> &m)
{
	if (this != &m) {
		tc_vector<T>::operator=(m);
		_col_names = m._col_names;
		_row_names = m._row_names;
		_nrow = m._nrow;
	}
	return *this;
}

void print(const tc_matrix<double> &m)
{
	if (m._nrow == 0)
		return;
	uint32_t ncol = m.size() / m._nrow;
	if (m._col_names.size()) {
		for(uint32_t i=0; i < m._col_names.size(); i++)
			printf(" %s", m._col_names[i].c_str());
		printf("\n");
	}
	for(uint32_t i=0; i < m.size(); i++) {
		if ((i % ncol == 0) && (i/ncol < m._row_names.size()))
			printf(" %s", m._row_names[i/ncol].c_str());
		if (m[i] == NA)
			printf(" NA");
		else
			printf(" %.5f", m[i]);
		if ( (i+1) % ncol == 0)
			printf("\n");
	}
	if (m.size() % ncol)
		printf("\n");
}

void print(const tc_matrix<uint32_t> &m)
{
	if (m._nrow == 0)
		return;
	uint32_t ncol = m.size() / m._nrow;
	if (m._col_names.size()) { 
		for(uint32_t i=0; i < m._col_names.size(); i++)
			printf(" %s", m._col_names[i].c_str());
		printf("\n");
	}
	for(uint32_t i=0; i < m.size(); i++) {
		if ((i % ncol == 0) && (i/ncol < m._row_names.size()))
			printf(" %s", m._row_names[i/ncol].c_str());
		if (m[i] == NA)
			printf(" NA");
		else
			printf(" %u", m[i]);
		if ( (i+1) % ncol == 0)
			printf("\n");
	}
	if (m.size() % ncol)
		printf("\n");
}

void print(const tc_matrix<int32_t> &m)
{
	if (m._nrow == 0)
		return;
	uint32_t ncol = m.size() / m._nrow;
	if (m._col_names.size()) { 
		for(uint32_t i=0; i < m._col_names.size(); i++)
			printf(" %s", m._col_names[i].c_str());
		printf("\n");
	}
	for(uint32_t i=0; i < m.size(); i++) {
		if ((i % ncol == 0) && (i/ncol < m._row_names.size()))
			printf(" %s", m._row_names[i/ncol].c_str());
		if (m[i] == NA)
			printf(" NA");
		else
			printf(" %d", m[i]);
		if ( (i+1) % ncol == 0)
			printf("\n");
	}
	if (m.size() % ncol)
		printf("\n");
}

void print(const tc_matrix<bool> &m)
{
	if (m._nrow == 0)
		return;
	uint32_t ncol = m.size() / m._nrow;
	if (m._col_names.size()) { 
		for(uint32_t i=0; i < m._col_names.size(); i++)
			printf(" %s", m._col_names[i].c_str());
		printf("\n");
	}
	for(uint32_t i=0; i < m.size(); i++) {
		if ((i % ncol == 0) && (i/ncol < m._row_names.size()))
			printf(" %s", m._row_names[i/ncol].c_str());
		if (m[i] == NA)
			printf(" NA");
		else
			printf(" %s", m[i]? "true": "false");
		if ( (i+1) % ncol == 0)
			printf("\n");
	}
	if (m.size() % ncol)
		printf("\n");
}

template <class T>
tc_vector<T> left_mult(const tc_vector<T> &v, const tc_matrix<T> &m)
{
	tc_vector<T> r;
	if (v.size() != nrow(m))
		return r;
	uint32_t ncols = ncol(m);
	uint32_t nrows = nrow(m);
	for(uint32_t j=0; j < ncols; j++) {
		double val = 0.0;
		for(uint32_t i=0; i < nrows; i++)
			val += v[i] * m(i,j);
		r.push_back(val);
	}
	return r;
}


/****************************************************************
 * functions                                                    *
 ****************************************************************/

template <class T>
tc_matrix<T> AsMatrix(tc_vector<T> Vec) 
{
	// Takes a vector and transforms it into a 1 column matrix
	return tc_matrix<T>(Vec,length(Vec));
}

template <class T>
tc_vector<T> MeanNA(const tc_vector<T> &Vec) 
{
	// Replaces NA instances with their mean instead
	tc_vector<T> v(Vec);
	T m = mean(v, true);
	v.set(is_na(v), m);
	return v;
}

template <class T>
tc_vector<T> GetWeight(const tc_vector<T> &Vec, bool AddMean=false) 
{
	// Takes a tc_vector, absolute value, then proportional linear deviance from 0.
	tc_vector<T> v = abs(Vec);
	if (AddMean)
		v = v + mean(v);
	if (sum(v) == 0)
		v = v + (T)1;
	v = v / sum(v);
	return v;
}

double Catch(double X, double Tolerance=0.0) 
{
	// x is the ConoutRAW numeric, Tolerance is the length of the midpoint corresponding to .5 
	// The purpose here is to handle rounding for Binary Decisions (Scaled Decisions use weighted median)
	if (X < (.5-(Tolerance/2)))
		return 0.0;
	else
	if (X>(.5+(Tolerance/2)))
		return 1.0;
	else return .5;
}

tc_vector<double> weighted_median(
	tc_vector<double> x,
	tc_vector<double> w,
	bool na_rm=true,
	const std::string ties="NULL") 
{
	// Thanks to https://stat.ethz.ch/pipermail/r-help/2002-February/018614.html
	if (missing(w))
		w = rep(1.0, length(x));

	// Remove values that are NAs
	if (na_rm == true) {
		tc_vector<bool> keep = !(is_na(x) | is_na(w));
		x = x[keep];
		w = w[keep];
	}
	else
	if (any(is_na(x)))
		return (double)NA;
	
	// Assert that the weights are all non-negative.
	if (any(w < 0)) {
		printf("Some of the weights are negative; one can only have positive weights.\n");
		exit(1);
	}
	
	// Remove values with weight zero. This will:
	//  1) take care of the case when all weights are zero,
	//  2) make sure that possible tied values are next to each others, and
	//  3) it will most likely speed up the sorting.
	uint32_t n = length(w);
	tc_vector<bool> keep = (w > 0);
	uint32_t nkeep = sum(keep);
	if (nkeep < n) {
		x = x[keep];
		w = w[keep];
		n = nkeep;
	}
	
	// Are any weights Inf? Then treat them with equal weight and all others
	// with weight zero.
	tc_vector<bool> wInfs = is_infinite(w);
	if (any(wInfs)) {
		x = x[wInfs];
		n = length(x);
		w = rep(1., n);
	}

	// Are there any values left to calculate the weighted median of?
	if (n == 0)
		return (double)NA;

	// Order the values and order the weights accordingly
	tc_vector<uint32_t> ord = order(x);
	x = x[ord];
	w = w[ord];

	tc_vector<double> wcum = cumsum(w);
	double wsum = wcum[n-1];
	double wmid = wsum / 2;

	// Find the position where the sum of the weights of the elements such that
	// x[i] < x[k] is less or equal than half the sum of all weights.
	// (these two lines could probably be optimized for speed).
	tc_vector<bool> lows = (wcum <= wmid);
	uint32_t k = sum(lows);

	// Two special cases where all the weight are at the first or the
	// last value:
	if (k == 0) return x[0];
	if (k == n) return x[n-1];

	// At this point we know that:
	//  1) at most half the total weight is in the set x[1:k],
	//  2) that the set x[(k+2):n] contains less than half the total weight
	// The question is whether x[(k+1):n] contains *more* than
	// half the total weight (try x=c(1,2,3), w=c(1,1,1)). If it is then
	// we can be sure that x[k+1] is the weighted median we are looking
	// for, otherwise it is any function of x[k:(k+1)].

	double wlow = wcum[k-1];			// the weight of x[1:k]
	double whigh = wsum - wlow;		// the weight of x[(k+1):n]
	if (whigh > wmid)
		return x[k-1];
	
	if (ties == "NULL" || ties == "weighted") {  // Default!
		return (wlow*x[k-1] + whigh*x[k]) / wsum;
	} else if (ties == "max") {
		return x[k];
	} else if (ties == "min") {
		return x[k-1];
	} else if (ties == "mean") {
		return (x[k-1]+x[k])/2;
	} else if (ties == "both") {
		return c<double>(2, x[k-1], x[k]);
	}
	return (double) NA;
}

tc_matrix<double> Rescale(tc_matrix<double> UnscaledMatrix, tc_matrix<double> Scales) 
{
	tc_matrix<double> OutMatrix = UnscaledMatrix;
	for(uint32_t j=0; j < ncol(OutMatrix); j++) {
		double min = Scales(1,j);
		double max = Scales(2,j);
		for(uint32_t i=0; i < nrow(OutMatrix); i++)
			if (OutMatrix(i,j) != NA)
				OutMatrix(i,j) = (OutMatrix(i,j) - min) / (max - min);
	}
	OutMatrix._row_names = UnscaledMatrix._row_names;
	OutMatrix._col_names = UnscaledMatrix._col_names;
	return OutMatrix;
}

/* Influence
 * Takes a normalized tc_vector (one that sums to 1), and computes relative strength of the indicators.
 * this is because by-default the conformity of each Author and Judge is expressed relatively.
 */
tc_vector<double> Influence(tc_vector<double> Weight) 
{
	tc_vector<double> Expected = rep(1.0/length(Weight),length(Weight));
	return Weight / Expected;
}

/* ReWeight
 * Get the relative influence of numbers, treat NA as influence-less
 */
tc_vector<double> ReWeight(tc_vector<double> Vec)
{
	if(!identical(Vec,abs(Vec,false)))
		printf("Warning: Expected all positive.\n");

	tc_vector<double> Out = Vec;
	Out.set(is_na(Vec), 0.0);
	Out = Out/sum(Out);
	return Out;
}

tc_matrix<int32_t> ReverseMatrix(tc_matrix<int32_t> Mat) 
{
	// Inverts a binary matrix
	return tc_matrix<int32_t>((Mat-1)*-1, Mat._nrow);
}

struct WeightedPrinCompOutput {
	std::vector<double> Scores;
	std::vector<double> Loadings;
};

void print(const WeightedPrinCompOutput &Out)
{ 
	printf("Scores ");
	for(uint32_t i=0; i < Out.Scores.size(); i++)
		printf(" %.8f", Out.Scores[i]);
	printf("\n");
	printf("Loadings ");
	for(uint32_t i=0; i < Out.Loadings.size(); i++)
		printf(" %.8f", Out.Loadings[i]);
	printf("\n");
}

/* WeightedPrinComp
 * Takes Matrix X and vector of row-weights "Weights"
 * Manually computes the statistical procedure known as Principal Components Analysis (PCA)
 * This version of the procedure is so basic, that it can also be thought of as merely a singular-value decomposition on a weighted covariance matrix.
 */
WeightedPrinCompOutput WeightedPrinComp(tc_matrix<double> X, tc_vector<double> Weights) 
{
	WeightedPrinCompOutput Out;
	if (length(Weights) != nrow(X)) {
		print("Error: Weights must be equal to nrow(X)");
		return Out;
	}
	uint32_t M = nrow(X);
	uint32_t N = ncol(X);
	/* X */
	struct tc_mat *x_mat = tc_mat_ctr(M, N);
	double **x = (double **) x_mat->a;
	for(uint32_t i=0; i < M; i++)
		for(uint32_t j=0; j < N; j++)
			x[i][j] = X(i,j);
	/* means */
	struct tc_mat *means = tc_mat_ctr(N, 1);
	double **m = (double **) means->a;
	for(uint32_t j=0; j < N; j++) {
		double sum = 0.0;
		for(uint32_t i=0; i < M; i++)
			sum += Weights[i] * x[i][j];
		m[j][0] = sum;
	}
	/* Weighted Covariance Matrix */
	double wgts2 = 0.0;
	for(uint32_t i=0; i < M; i++)
		wgts2 += Weights[i] * Weights[i];
	double factor = 1.0/(1.0 - wgts2);
	struct tc_mat *wCVM = tc_mat_ctr(N, N);
	for(uint32_t i=0; i < N; i++) {
		for(uint32_t j=0; j <= i; j++) {
			double sum = 0.0;
			for(uint32_t k=0; k < M; k++)
				sum += Weights[k] * (x[k][i] - m[i][0]) * (x[k][j] - m[j][0]);
			wCVM->a[i][j] =
			wCVM->a[j][i] = factor * sum;
		}
	}
	/* SVD of wCVM */
	struct tc_mat *U = tc_mat_ctr(0, 0);
	struct tc_mat *D = tc_mat_ctr(0, 0);
	struct tc_mat *V = tc_mat_ctr(0, 0);
	int rc = tc_mat_svd(wCVM, U, D, V);
	if (!rc) {
		struct tc_mat *loadings = tc_mat_ctr(N, 1);
		for(uint32_t i=0; i < N; i++)
			loadings->a[i][0] = U->a[i][0];
		for(uint32_t i=0; i < M; i++)
			for(uint32_t j=0; j < N; j++)
				x_mat->a[i][j] -= means->a[j][0];
		struct tc_mat *scores = tc_mat_ctr(0, 0);
		tc_mat_mult(scores, x_mat, loadings);
		for(uint32_t i=0; i < M; i++)
			Out.Scores.push_back(scores->a[i][0]);
		for(uint32_t i=0; i < N; i++)
			Out.Loadings.push_back(loadings->a[i][0]);
		tc_mat_dtr(loadings);
		tc_mat_dtr(scores);
	} else {
		printf("tc_mat_svd error\n");
	}

	tc_mat_dtr(wCVM);
	tc_mat_dtr(U);
	tc_mat_dtr(D);
	tc_mat_dtr(V);
	tc_mat_dtr(x_mat);
	tc_mat_dtr(means);
	return Out;
}

WeightedPrinCompOutput WeightedPrinComp(tc_matrix<double> X)
{
	tc_vector<double> Weights = ReWeight(rep(1.0,nrow(X)));
	return WeightedPrinComp(X, Weights);
}

struct RewardWeightsOutput {
	tc_vector<double> FirstLoading;
	tc_vector<double> OldRep;
	tc_vector<double> ThisRep;
	tc_vector<double> SmoothedR;
};

void print(const RewardWeightsOutput &Out)
{
	printf("FirstLoading ");
	for(uint32_t i=0; i < Out.FirstLoading.size(); i++)
		printf(" %.8f", Out.FirstLoading[i]);
	printf("\n");
	printf("OldRep ");
	for(uint32_t i=0; i < Out.OldRep.size(); i++)
		printf(" %.8f", Out.OldRep[i]);
	printf("\n");
	printf("ThisRep ");
	for(uint32_t i=0; i < Out.ThisRep.size(); i++)
		printf(" %.8f", Out.ThisRep[i]);
	printf("\n");
	printf("SmoothedR");
	for(uint32_t i=0; i < Out.SmoothedR.size(); i++)
		printf(" %.8f", Out.SmoothedR[i]);
	printf("\n");
}

RewardWeightsOutput GetRewardWeights(
	const tc_matrix<double> &M,
	const tc_vector<double> &Rep,
	double alpha=0.1,
	bool Verbose=false)
{
	if (Verbose) {
		printf("****************************************************\n");
		printf("Begin GetRewardWeights\n");
		printf("Inputs...\n");
		printf("Matrix:\n");
		print(M);
		printf("\n");
		printf("Reputation:\n");
		print(AsMatrix(Rep));
		printf("\n");
	}

	/* Rep = ReWeight(rep(1,M.nrow())) 
	 * The first loading is designed to indicate which Decisions were more agreed-upon than others.  
	 * The scores show loadings on consensus (to what extent does this observation represent consensus?) 
	 */
	WeightedPrinCompOutput Results = WeightedPrinComp(M, Rep);
	if (Verbose) {
		printf("First:\n");
		print(Results);
	}
	
	/* PCA, being an abstract factorization, is incapable of determining anything
	 * absolute. Therefore the results of the entire procedure would theoretically
	 * be reversed if the average state of Decisions changed from TRUE to FALSE.
	 * Because the average state of Decisions is a function both of randomness and
	 * the way the Decisions are worded, I quickly check to see which of the two 
	 * possible new reputation vectors had more opinion in common with the original
	 * old reputation. I originally tried doing this using math but after multiple 
	 * failures I chose this ad hoc way.
	 */
	tc_vector<double> FirstLoading = Results.Loadings;
	tc_vector<double> FirstScore = Results.Scores;
	double min_score = min(FirstScore);
	double max_score = max(FirstScore);
	tc_vector<double> Set1 = FirstScore + fabs(min_score);
	tc_vector<double> Set2 = FirstScore - max_score;
	tc_vector<double> Old = left_mult(Rep, M);
	tc_vector<double> New1 = GetWeight(left_mult(Set1, M));
	tc_vector<double> New2 = GetWeight(left_mult(Set2, M));
	/* Difference in Sum of squared errors, if >0, then New1 had higher errors 
	 * (use New2), and conversely if <0 use 1.
	 */
	double RefInd = sum((New1-Old)*(New1-Old)) - sum((New2-Old)*(New2-Old));
	tc_vector<double> AdjPrinComp = (RefInd <= 0.0)? Set1: Set2;
	if (Verbose) {
		printf("\n");
		printf("Estimations using: Previous Rep, Option 1, Option 2\n");
		for(uint32_t i=0; i < Old.size(); i++) 
			printf(" %7.4f  %7.4f  %7.4f\n", Old[i], New1[i], New2[i]);
		printf("\n");
		printf("Previous period reputations, Option 1, Option 2, Selection");
		for(uint32_t i=0; i < Old.size(); i++) 
			printf(" %7.4f  %7.4f  %7.4f  %7.4f\n", Rep[i], Set1[i], Set2[i], AdjPrinComp[i]);
	}
	/* Declared here, filled below (unless there was a perfect consensus).
	 * (set this to uniform if you want a passive diffusion toward equality when people cooperate
	 * [not sure why you would]). Instead diffuses towards previous reputation (Smoothing does this anyway).
	 */
	tc_vector<double> RowRewardWeighted = Rep;
	/*  Overwrite the inital declaration IFF there wasnt perfect consensus. */

	double max_AdjPrinComp = max(abs(AdjPrinComp));
	if (max_AdjPrinComp != 0.0)
		RowRewardWeighted = GetWeight( (AdjPrinComp * Rep/mean(Rep)) );
	/* note: Rep/mean(Rep) is a correction ensuring Reputation is additive. Therefore, 
	 * nothing can be gained by splitting/combining Reputation into single/multiple accounts.
	 */
	/* Freshly-Calculated Reward (Reputation) - Exponential Smoothing
	 * New Reward: RowRewardWeighted
	 * Old Reward: Rep
	 */
	tc_vector<double> SmoothedR = RowRewardWeighted * alpha + Rep * (1.0-alpha);
	if (Verbose) {
		printf("\n");
		printf("Corrected for Additivity , Smoothed _1 period\n");
		for(uint32_t i=0; i < Old.size(); i++) 
			printf(" %7.4f  %7.4f\n", RowRewardWeighted[i], SmoothedR[i]);
	}
	/* Return Data 
	 * Keep the factors and time information along for the ride, they are interesting. 
	 */

	RewardWeightsOutput Out;
	Out.FirstLoading = FirstLoading;
	Out.OldRep = Rep;
	Out.ThisRep = RowRewardWeighted;
	Out.SmoothedR = SmoothedR;
	return Out;
}

RewardWeightsOutput GetRewardWeights(const tc_matrix<double> &M, double alpha=0.1, bool Verbose=false)
{
	if (Verbose)
		printf("Reputation not provided...assuming equal influence.\n");
	tc_vector<double> Rep = std::vector<double>(nrow(M),1.0/nrow(M));
	return GetRewardWeights(M, Rep, alpha, Verbose);
}

/* GetDecisionOutcomes
 * Determines the Outcomes of Decisions based on the provided reputation (weighted vote)
 */
tc_vector<double> GetDecisionOutcomes(
	const tc_matrix<double> &Mtemp,
	const tc_vector<int> &ScaledIndex,
	const tc_vector<double> &Rep,
	bool Verbose=false)
{
	tc_vector<double> raw;
	if (ncol(Mtemp) != ScaledIndex.size())
		return raw;
	if (Verbose) {
		printf("****************************************************\n");
		printf("Begin GetDecisionOutcomes\n");
	}
	/*
	 * The Reputation of the row-players who DID provide judgements, rescaled to sum to 1.
	 * The relevant Decision with NAs removed. ("What these row-players had to say about the Decisions they DID judge.")
	 * Discriminate Based on Contract Type
	 */
	for(uint32_t i=0; i < ncol(Mtemp); i++) {
		tc_vector<double> Row, Col;
		for(uint32_t j=0; j < nrow(Mtemp); j++) {
			double Mij = Mtemp(j,i);
			if (Mij == NA)
				continue;
			Col.push_back(Mij);
			Row.push_back(Rep[j]);
		}
		Row = ReWeight(Row);
		/* Our Current best-guesses at           */
		/*   Binary Decision (weighted average)  */
		/*   Scaled Decision (weighted median)   */
		double raw_i = (!ScaledIndex[i])? sum(Row * Col): weighted_median(Col, Row)[0];
		if (Verbose) {
			printf("** ** Column: %d\n", i);
			print(Row);
			print(Col);
			printf("Consensus:");
			printf("%.8f\n", raw_i);
		}
		raw.push_back(raw_i);
	}
	return raw;
}

tc_vector<double> GetDecisionOutcomes(
	const tc_matrix<double> &M,
	const tc_vector<int> &ScaledIndex,
	bool Verbose=false)
{
	if (Verbose)
		print("Reputation not provided...assuming equal influence.\n");
	tc_vector<double> Rep = std::vector<double>(nrow(M),1.0/nrow(M));
	return GetDecisionOutcomes(M, ScaledIndex, Rep, Verbose);
}

/* FillNa
 * Uses exisiting data and reputations to fill missing observations.
 * Essentially a weighted average using all availiable non-NA data.
 * How much should slackers who arent voting suffer? I decided this would depend on the global percentage of slacking.
 */	
tc_matrix<double> FillNa(
	const tc_matrix<double> &Mna,
	const tc_vector<int> &ScaledIndex,
	const tc_vector<double> &Rep,
	double CatchP = 0.1,
	bool Verbose=false) 
{ 
	tc_matrix<double> MnewC = Mna;
	if (sum(is_na(Mna)) > 0) {
		if (Verbose)
			printf("Missing Values Detected. Beginning presolve using availiable values.\n");
		/* Decision Outcome - Our best guess for the Decision state (FALSE=0,
		 * Ambiguous=.5, TRUE=1) so far (ie, using the present, non-missing, values).
		 * Fill in the predictions to the original M 
		 * Discriminate based on contract type
		 * Fill ONLY Binary contracts by appropriately forcing predictions into their discrete (0,.5,1) slot.
		 * (reveals .5 coordination, continuous variables are more gameable).
		 */
		tc_vector<double> DecisionOutcomes_Raw = GetDecisionOutcomes(Mna, ScaledIndex, Rep, Verbose);
		for(uint32_t i=0; i < nrow(Mna); i++) {
			for(uint32_t j=0; j < ncol(Mna); j++) {
				double a = (Mna(i,j)==(double)NA)? DecisionOutcomes_Raw[j]: Mna(i,j);
				MnewC(i,j) = (ScaledIndex[j])? a: Catch(a,CatchP);
			}
		}
		if (Verbose) {
			printf("Binned:\n");
			print(MnewC);
			printf("*** ** Missing Values Filled ** ***\n");
		}
	}
	return MnewC;
}

tc_matrix<double> FillNa(
	const tc_matrix<double> &Mna,
	const tc_vector<int> &ScaledIndex,
	double CatchP = 0.1,
	bool Verbose=false) 
{ 
	tc_vector<double> Rep = ReWeight(rep(1.0,nrow(Mna)));
	if (Verbose)
		printf("Reputation not provided...assuming equal influence.\n");
	return FillNa(Mna, ScaledIndex, Rep, CatchP, Verbose);
}

struct FactoryOutput {
	tc_matrix<double> Original;
	tc_matrix<double> Filled;
	RewardWeightsOutput PlayerInfo;
	tc_vector<double> NArow;
	tc_vector<double> ParticipationR;
	tc_vector<double> NAbonusR;
	tc_vector<double> RowBonus;
	tc_vector<double> AdjLoadings;
	tc_vector<double> DecisionOutcomes_Raw;
	tc_vector<double> ConReward;
	tc_vector<double> Certainty;
	tc_vector<double> NAcol;
	tc_vector<double> ParticipationC;
	tc_vector<double> ColBonus;
	tc_vector<double> DecisionOutcome_Final;
	double Participation;
	double Avg_Certainty;
};

void print(const FactoryOutput &Out)
{
	printf("Original\n"); 
	print(Out.Original);
	printf("Filled\n"); 
	print(Out.Filled);
	printf("Agents\n"); 
	printf("OldRep ");
	printf(" %8s", "OldRep");
	printf(" %8s", "ThisRep");
	printf(" %8s", "SmoothRep");
	printf(" %8s", "NArow");
	printf(" %8s", "ParticipationR");
	printf(" %8s", "NAbonusR");
	printf(" %8s", "RowBonus");
	printf("\n");
	for(uint32_t i=0; i < Out.PlayerInfo.OldRep.size(); i++) {
		printf(" %.8f", Out.PlayerInfo.OldRep[i]);
		printf(" %.8f", Out.PlayerInfo.ThisRep[i]);
		printf(" %.8f", Out.PlayerInfo.SmoothedR[i]);
		printf(" %.8f", Out.NArow[i]);
		printf(" %.8f", Out.ParticipationR[i]);
		printf(" %.8f", Out.NAbonusR[i]);
		printf(" %.8f", Out.RowBonus[i]);
		printf("\n");
	}
	printf("\n");
	printf("Decisions\n"); 
	printf(" %-20s ", "First Loading");
	print(Out.AdjLoadings);
	printf(" %-20s ", "DecisionOutcomes.Raw");
	print(Out.DecisionOutcomes_Raw);
	printf(" %-20s ", "Consensus Reward");
	print(Out.ConReward);
	printf(" %-20s ", "Certainty");
	print(Out.Certainty);
	printf(" %-20s ", "NAs Filled");
	print(Out.NAcol);
	printf(" %-20s ", "ParticipationC");
	print(Out.ParticipationC);
	printf(" %-20s ", "Author Bonus");
	print(Out.ColBonus);
	printf(" %-20s ", "DecisionOutcome.Final");
	print(Out.DecisionOutcome_Final);

	printf("Participation %.8f\n", Out.Participation);
	printf("Certainty %.8f\n", Out.Avg_Certainty);
}

/* Factory
 * Main Routine
 * Fill the default reputations (egalitarian) if none are
 * provided...unrealistic and only for testing.
 */
FactoryOutput Factory(
	const tc_matrix<double> &M0,
	const tc_matrix<double> &Scales,
	const tc_vector<double> &Rep,
	double CatchP = 0.1,
	uint32_t MaxRow = 5000,
	bool Verbose = false)
{
	FactoryOutput Out;
	Out.Original = M0;

	tc_matrix<double> MScaled = Rescale(M0, Scales);
	tc_vector<int> ScaledIndex;
	for(uint32_t i=0; i < ncol(M0); i++)
		ScaledIndex.push_back((Scales[i]==0.0)? 0: 1); 
	tc_matrix<double> Filled = FillNa(MScaled, ScaledIndex, Rep, CatchP, Verbose);
	Out.Filled = Filled;

	/* Consensus - Row Players 
	 * New Consensus Reward
	 */
	RewardWeightsOutput PlayerInfo = GetRewardWeights(Filled, Rep, 0.1, Verbose);
	Out.PlayerInfo = PlayerInfo;
	const tc_vector<double> &AdjLoadings = PlayerInfo.FirstLoading;
	
	/* Column Players (The Decision Creators)
	 * Calculation of Reward for Decision Authors
	 * Consensus - "Who won?" Decision Outcome 
	 * Declare (all binary), Simple matrix multiplication ... highest information
	 * density at RowBonus, but need DecisionOutcomes.Raw to get to that
	 * 
	 * Discriminate Based on Contract Type
	 * Our Current best-guess for this Scaled Decision (weighted median)
	 */
	tc_vector<double> DecisionOutcomes_Raw = left_mult(PlayerInfo.SmoothedR, Filled);
	for(uint32_t i=0; i < ncol(Filled); i++) {
		if (!ScaledIndex[i]) 
			continue;
		tc_vector<double> x;
		for(uint32_t j=0; j < nrow(Filled); j++)
			x.push_back(Filled(j,i));
		DecisionOutcomes_Raw[i] = weighted_median(x, PlayerInfo.SmoothedR)[0];
	}
	
	/* The Outcome Itself
	 * Discriminate Based on Contract Type
	 * Declare first (assumes all binary) 
	 * Replace Scaled with raw (weighted-median) 
	 * Rescale these back up. 
	 * Recenter these back up. 
	 */
	tc_vector<double> DecisionOutcome_Adj;
	for(uint32_t i=0; i < DecisionOutcomes_Raw.size(); i++)
		DecisionOutcome_Adj.push_back(Catch(DecisionOutcomes_Raw[i],CatchP));
	for(uint32_t i=0; i < DecisionOutcomes_Raw.size(); i++)
		if (ScaledIndex[i])
			DecisionOutcome_Adj[i] = DecisionOutcomes_Raw[i];
	tc_vector<double> DecisionOutcome_Final;
	for(uint32_t i=0; i < DecisionOutcome_Adj.size(); i++) {
		double min = Scales(1,i);
		double max = Scales(2,i);
		double val = (max - min) * DecisionOutcome_Adj[i] + min;
		DecisionOutcome_Final.push_back(val);
	}
	/* Quality of Outcomes - is there confusion? */
	/* Discriminate Based on Contract Type
	 * Scaled first:
	 */
	tc_vector<double> Certainty;
	for(uint32_t j=0; j < ncol(Filled); j++) {
		/* For each Decision 
		 * Sum of, the reputations which, met the condition that they
		 * voted for the outcome which was selected for this Decision. 
		 */
		double sum = 0.0;
		for(uint32_t i=0; i < nrow(Filled); i++)
			if (DecisionOutcome_Adj[j] == Filled(i,j))
				sum += PlayerInfo.SmoothedR[i];
		Certainty.push_back(sum);
	}
	/* Grading Authors on a curve. -not necessarily the best idea? may just use Certainty instead */
	tc_vector<double> ConReward = GetWeight(Certainty);
	/* How well did beliefs converge? */
	double Avg_Certainty = mean(Certainty);
	
	if (Verbose) {
		printf("*Decision Outcomes Sucessfully Calculated*\n");
		printf("Raw Outcomes, Certainty, AuthorPayoutFactor\n");
		print(DecisionOutcomes_Raw);
		print(Certainty);
		print(ConReward);
	}
	
	/* Participation
	 * Information about missing values
	 * 
	 * Participation Within Decisions (Columns) 
	 * % of reputation that answered each Decision
	 */
	tc_vector<double> NAcol;
	tc_vector<double> ParticipationC;
	for(uint32_t i=0; i < ncol(M0); i++) {
		double count = 0.0;
		double val = 0.0;
		for(uint32_t j=0; j < nrow(M0); j++)
			if (M0(j,i) == (double)NA) {
				val += PlayerInfo.SmoothedR[j];
				count += 1.0;
			}
		ParticipationC.push_back(1.0 - val);
		NAcol.push_back(count);
	}
	/* Participation Within Agents (Rows) 
	 * Many options
	 * 1- Democracy Option - all Decisions treated equally.
	 */
	tc_vector<double> NArow;
	tc_vector<double> ParticipationR;
	for(uint32_t i=0; i < nrow(M0); i++) {
		double val = 0.0;
		for(uint32_t j=0; j < ncol(M0); j++)
			if (M0(j,i) == (double)NA)
				val += 1.0;
		ParticipationR.push_back(1.0 - val);
		NArow.push_back(val);
	}

	/* General Participation */
	double PercentNA = 1.0 - mean(ParticipationC);

	/* (Possibly integrate two functions of participation?) Chicken and egg problem...
	 */
	if (Verbose) {
		printf("*Participation Information*\n");
		printf("Voter Turnout by question");
		print(ParticipationC);
		printf("Voter Turnout across questions");
		print(ParticipationR);
	}
	
	/* Combine Information */
	/* Row */
	tc_vector<double> NAbonusR = GetWeight(ParticipationR);
	tc_vector<double> RowBonus = NAbonusR*(PercentNA) + PlayerInfo.SmoothedR*(1-PercentNA);
	/* Column */
	tc_vector<double> NAbonusC = GetWeight(ParticipationC);
	tc_vector<double> ColBonus = NAbonusC*(PercentNA) + ConReward*(1-PercentNA);

	Out.AdjLoadings = AdjLoadings;
	Out.DecisionOutcomes_Raw = DecisionOutcomes_Raw;
	Out.ConReward = ConReward;
	Out.Certainty = Certainty;
	Out.NAcol = NAcol;
	Out.ParticipationC = ParticipationC;
	Out.ColBonus = ColBonus;
	Out.DecisionOutcome_Final = DecisionOutcome_Final;
	Out.NArow = NArow;
	Out.ParticipationR = ParticipationR;
	Out.NAbonusR = NAbonusR;
	Out.RowBonus = RowBonus;
	Out.Participation = 1.0 - PercentNA; 
	Out.Avg_Certainty = Avg_Certainty;
	return Out;
}

FactoryOutput Factory(
	const tc_matrix<double> &M0,
	const tc_matrix<double> &Scales,
	double CatchP = 0.1,
	uint32_t MaxRow = 5000,
	bool Verbose = false)
{
	if (Verbose)
		printf("Reputation not provided...assuming equal influence.\n");
	tc_vector<double> Rep = ReWeight(rep(1.0,nrow(M0)));
	return Factory(M0, Scales, Rep, CatchP, MaxRow, Verbose);
}

FactoryOutput Factory(
	const tc_matrix<double> &M0,
	double CatchP = 0.1,
	uint32_t MaxRow = 5000,
	bool Verbose = false)
{
	if(Verbose)
		printf("Scales not provided...assuming binary (0,1).\n");
	tc_matrix<double> Scales;
	for(uint32_t i=0; i < 3*ncol(M0); i++)
		Scales.push_back( i < 2*ncol(M0)? 0.0: 1.0);
	Scales._nrow = 3;
	return Factory(M0, Scales, CatchP, MaxRow, Verbose);
}

