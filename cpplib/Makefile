GCC = gcc -g -Wall -std=c99 -O4
GPP = g++ -g -Wall -O4

ifeq ($(HAVE_GSL),1)
	LIBS = -lgsl -lgslcblas
endif

all: tst_svd tst_custom_math tst_markets tst_consensus

tc_mat.o: tc_mat.c tc_mat.h
	$(GCC) -c tc_mat.c -o tc_mat.o

tc_data.o: tc_data.cpp
	$(GPP) -o $@ -c $< 

tst_svd: tst_svd.cpp tc_mat.o
	$(GPP) -o $@ $< tc_mat.o $(LIBS)

tst_custom_math: tst_custom_math.cpp tc_matrix.h tc_mat.o
	$(GPP) -o $@ $< tc_mat.o $(LIBS)

tst_markets: tst_markets.cpp tc_data.o
	$(GPP) -o $@ $< tc_data.o -lssl -lcrypto

tst_consensus: tst_consensus.cpp tc_matrix.h tc_mat.o
	$(GPP) -o $@ $< tc_mat.o

clean:
	rm -f tst_svd tst_custom_math tst_markets tc_data.o tc_mat.o
