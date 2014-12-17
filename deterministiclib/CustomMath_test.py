def test_GetWeight():
    print(GetWeight([1,1,1,1]))
    # [1] 0.25 0.25 0.25 0.25
    print(GetWeight([10,10,10,10]))
    # [1] 0.25 0.25 0.25 0.25
    print(GetWeight([4,5,6,7]))
    # [1] 0.1818182 0.2272727 0.2727273 0.3181818
    print(GetWeight([4,5,6,7], True))
    # [1] 0.2159091 0.2386364 0.2613636 0.2840909
def catch_test():
    print(Catch(Decimal('.4')))#0
    print(Catch(Decimal('.5')))#0.5
    print(Catch(Decimal('.6')))#1
    print(Catch(Decimal('.6'), Tolerance=Decimal('0.1')))#1
    print(Catch(Decimal('.6'), Tolerance=Decimal('0.2')))#0.5
def MeanNATest():
    v=[3,4,6,7,8]
    print(MeanNA(v))
    # [1] 3 4 6 7 8
    v=[3,'NA',6,7,8]
    print(MeanNA(v))
    # [1] 3 6 6 7 8
    v=[0,0,0,1,'NA']
    print(MeanNA(v))
    # [1] 0.00 0.00 0.00 1.00 0.25
    v=[0,0,'NA',1,'NA']
    print(MeanNA(v))
    # [1] 0.0000000 0.0000000 0.3333333 1.0000000 0.3333333
def rescale_test():
    m=[[1, 1, 0, 0],#, 233, Decimal(16027.59)],
       [1, 0, 0, 0],# 199, 'NA'],
       [1, 1, 0, 0],# 233, 16027.59],
       [1, 1, 1, 0],# 250, 'NA'],
       [0, 0, 1, 1],# 435, 8001.00],
       [0, 0, 1, 1]]#, 435, 19999.00]]
    print(Rescale(m))
def influence_test():
    print(Influence([Decimal('0.25')]*4))#[1,1,1,1]
    print(Influence([Decimal('0.3')]*2+[Decimal('0.4')]))#[0.9,0.9,1.2]
    print(Influence([Decimal('0.99')]+[Decimal('0.0025')]*4))
    ## [1] 4.9500 0.0125 0.0125 0.0125 0.0125
def reweight_test():
    print(ReWeight([1,1,1,1]))#[.25, .25, .25, .25]
    print(ReWeight(['NA',1,'NA',1]))#[0, .5, 0, .5]
    print(ReWeight([2,4,6,12]))## [1] 0.08333333 0.16666667 0.25000000 0.50000000
    print(ReWeight([2,4,'NA',12]))# [1] 0.1111111 0.2222222 0.0000000 0.6666667
def test_weighted_sample_mean():
    m=[[1,0,1],[1,1,1],[1,0,1]]
    c=[1,1,1]
    Mat=numpy.ma.masked_array(m)
    Coins=numpy.array(map(lambda x: [x], c))
    print(weighted_sample_mean(m, c))
    print(numpy.ma.average(Mat, axis=0, weights=numpy.hstack(Coins))) # Computing the weighted sample mean (fast, efficient and precise)
def test_subtract_vector():
    m=[[1,0,1],[1,1,1],[1,0,1]]
    Mat=numpy.ma.masked_array(m)
    v=[.5, .5, 0]
    #print(Mat)
    print(numpy.matrix(Mat-numpy.array(v)))
    print(subtract_vector(m, v))
def test_matrix_multiply():
    m=[[1,0,1],[1,1,1],[1,0,1]]
    Mat=numpy.ma.masked_array(m)
    coins=numpy.ma.masked_array([[1],[1],[2]])
    print(matrix_multiply(Mat, coins))
    print(numpy.ma.multiply(Mat, coins))
def dot_test():
    m=[[1,2,3],[1,0,0],[0,4,0]]
    m2=[[1],[1],[0]]
    Mat=numpy.ma.masked_array(m)
    Mat2=numpy.ma.masked_array(m2)
    a=numpy.dot(Mat, Mat2)
    b=dot(m, m2)
    print(a)
    print(b)
def v_average_test():
    import numpy.ma as ma
    M=[[1,1,0],[0,0,1],[0,1,0]]
    Coins=[100000,200000,300000]
    Mat=numpy.matrix(M)
    Mean = ma.average(Mat, axis=0, weights=numpy.hstack(Coins))
    print(Mean)
    print(v_average(M, ReWeight(Coins)))
def b_test():
    from numpy import ma as ma
    td=0.33333333333333333
    XM=[[-td, -td, 2*td],
        [2*td, 2*td, -td],
        [-td, -td, -td]]
    Coins=[1000000]*3
    print(ma.multiply(XM, Coins).T.dot(XM))
    print(dot(switch_row_cols(matrix_multiply(XM, Coins)), XM))
def weighted_cov_test():
    Mat=[[0,0,1],[1,1,0],[0,0,0]]
    print(WeightedCov(Mat, [1,1,1]))
def weighted_median_test():
    print(weighted_median([3,4,5],[Decimal('.2'),Decimal('.2'),Decimal('.6')]))
    print(weighted_median([3,4,5],[Decimal('.2'),Decimal('.2'),Decimal('.5')]))
    print(weighted_median([3,4,5],[Decimal('.2'),Decimal('.2'),Decimal('.4')]))
def dot_test():
    a=[[1,0],
       [0,1]]
    n=[[2,0],
       [0,1]]
    c=[[-33333.33333333,  66666.66666667, -33333.33333333],
       [-33333.33333333,  66666.66666667, -33333.33333333],
       [ 66666.66666667, -33333.33333333, -33333.33333333]]
    XM=[[-0.33333333, -0.33333333,  0.66666667],
        [ 0.66666667,  0.66666667, -0.33333333],
        [-0.33333333, -0.33333333, -0.33333333]]
    print(dot(c, XM))
    import numpy
    print(numpy.dot(c, XM))
def ma_multiply_test():
    XM=[[1,0,1,0],[0,1,0,0],[0,0,100, 0]]
    Coins=[[1],[2],[3]]
    from numpy import ma
    print(ma.multiply(XM, Coins))
    print(ma_multiply(XM, Coins))
    Coins=[1,2,3,4]
    print(ma.multiply(XM, Coins))
    print(ma_multiply(XM, Coins))
def weightedprincomp_test():
    import pprint
    M=[[0,0,1],[1,1,0],[0,0,0]]
    V=[Decimal('.1')]*3#]#, [Decimal('.1')], [Decimal('.8')], [Decimal('.1')]]
    a=WeightedPrinComp(M,V)
    pprint.pprint(WeightedPrinComp(M,V))
