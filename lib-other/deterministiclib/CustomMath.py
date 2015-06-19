from cdecimal import Decimal
import copy, svd
def AsMatrix(v): return map(lambda i: [i], v)
def matrix_p(v): return type(v[0])==list
def mean(v): return sum(v)*Decimal('1.0')/len(v)
def replace_na(x, m):
    if type(x) in [int, float]:
        return x
    return m
def GetWeight(Vec, AddMean=False):
    new=map(abs, Vec)
    m=mean(new)
    tot=sum(new)
    if AddMean: new=map(lambda x: x+m, new)
    if(tot==0): new=map(lambda x: x+1, new)
    s=Decimal(sum(new))
    new=map(lambda x: Decimal(x)/s, new)
    return new
def dec_greater_than(a, b): return float(a)>float(b)
def Catch(X, Tolerance=0):
    h=Decimal('0.5')
    t=Tolerance/2
    if dec_greater_than(X,h+t):
        return Decimal('1')
    if dec_greater_than(h-t, X):
        return Decimal('0')
    return Decimal('0.5')
def median_walker(so_far_w, limit, x, w, prev_x):
    if so_far_w>limit: return prev_x
    if so_far_w==limit: return mean([Decimal('1.0')*prev_x, x[0]])
    return median_walker(so_far_w+w[0], limit, x[1:], w[1:], x[0])
def weighted_median(x, w):
    x, w=zip(*sorted(zip(x, w)))
    return median_walker(0, sum(w)*Decimal('1.0')/2, x, w, x[0])
def switch_row_cols(m):
    if not matrix_p(m):
        m=AsMatrix(m)
    out=[]
    for i in range(len(m[0])):
        newrow=[]
        for row in m:
            newrow.append(row[i])
        out.append(newrow)
    return out
def MeanNA(v):
    vf=filter(lambda x: type(x) in [int, float], v)
    m=mean(vf)
    return map(lambda x: replace_na(x, m), v)
def Rescale(UnscaledMatrix):
    flipped_m=switch_row_cols(UnscaledMatrix)
    out=[]
    for row in flipped_m:
        mrow=MeanNA(copy.deepcopy(row))
        ma=max(mrow)
        mi=min(mrow)
        out.append(map(lambda x: 'NA' if type(x)==str else (x-mi)/(ma-mi), row))
    return switch_row_cols(out)
def Influence(Weight):
    l=len(Weight)
    return map(lambda x: x*l, Weight)
def ReWeight(v):
    if type(v[0])==list: v=map(lambda x: x[0], v)
    w=map(lambda x: 0 if type(x)==str else x, v)
    s=sum(w)
    return map(lambda x: x*Decimal('1.0')/s, w)
def v2m(v):
    if not matrix_p(v):
        v=AsMatrix(v)
    return v
def dot(m, n):
    m=v2m(m)
    n=v2m(n)
    out=[]
    for i in range(len(m)):
        row=[]
        for j in range(len(n[0])):
            row.append(sum( m[i][k] * map(lambda x: x[j], n)[k] for k in range(len(m[0]))))
        out.append(row)
    return out
def weighted_sample_mean(matrix, weighting):
    weighting=ReWeight(weighting)
    matrix=dot(matrix, weighting)
    out=[]
    for i in range(len(matrix[0])):
        n=0
        for m in matrix:
            n+=m[i]
        out.append(n)
    return out
def subtract_vector(m, v):
    if type(v[0])==list and len(v[0])>1: v=v[0]
    if not matrix_p(v):
        v=AsMatrix(v)
    out=[]
    for row in range(len(m)):
        n=[]
        for column in range(len(v)):
            n.append(m[row][column]-v[column][0])
        out.append(n)
    return out
def v_average(M, W):
    M=copy.deepcopy(M)
    for row in range(len(M)):
        M[row]=map(lambda x: x*W[row],  M[row])
    out=[]
    for i in range(len(M[0])):
        n=0
        for j in range(len(M)):
            n+=M[j][i]
        out.append(n)
    return out
def ma_multiply(m, v):
    out=[]
    if type(v[0])==list and len(v)>0:#if v is vertical
        for row in range(len(m)):
            out.append(map(lambda x: x*v[row][0], m[row]))
    else:
        if type(v[0])==list: v=v[0]
        for row in range(len(m)):
            out.append(map(lambda i: m[row][i]*v[i], range(len(m[0]))))
    return out
def WeightedCov(Mat, Rep=-1):#should only output square matrices.
    if type(Rep) is int: Rep=map(lambda x: x/Decimal(len(Mat)), [1]*len(Mat))
    Coins=copy.deepcopy(Rep)
    #if type(Coins[0])==list: Coins=map(lambda x: x[0], Coins)
    Coins=map(lambda y: [y[0]*1000000], Coins)
    Mean=v_average(Mat, ReWeight(Coins))
    XM=subtract_vector(Mat, Mean)
    a=Decimal('1')/(sum(map(lambda x: x[0], Coins))-1)
    c=switch_row_cols(ma_multiply(XM,Coins))
    b=dot(c,XM)
    sigma2=map(lambda row: map(lambda x: x*a, row), b)
    return({'Cov':sigma2, 'Center':XM})
def WeightedPrinComp(M, Weights):
    if len(Weights)!=len(M):
        print('Weights must be equal in length to rows')
        return 'error'
    if type(Weights[0])!=list: Weights=map(lambda x: [x], Weights)
    wCVM=WeightedCov(M, Weights)
    SVD=svd.svd(wCVM['Cov'])
    L=switch_row_cols(SVD[0])[0]
    S=switch_row_cols(dot(wCVM['Center'], L))[0]
    return{'Scores':S, 'Loadings':L}
