from cdecimal import Decimal
import CustomMath as custommath
def DemocracyRep(x):
    v=[]
    for i in range(len(x)):
        v.append(1)
    return(custommath.ReWeight(v))
def GetRewardWeights(M, Rep=-1, alpha=Decimal('0.1')):
    if Rep==-1:
        Rep=DemocracyRep(M)
    if type(Rep[0])==list:
        Rep=map(lambda x: x[0], Rep)
    Results=custommath.WeightedPrinComp(M, Rep)
    FirstLoading=Results['Loadings']
    FirstScore=Results['Scores']
    a=min(map(abs,FirstScore))
    b=max(FirstScore)
    Set1=map(lambda x: x+a, FirstScore)
    Set2=map(lambda x: x-b, FirstScore)
    Old=custommath.dot([Rep], M)
    New1=custommath.dot([custommath.GetWeight(Set1)], M)
    New2=custommath.dot([custommath.GetWeight(Set2)], M)
    def sub_f(a, b): return a-b
    def f(n): return sum(map(lambda x: x**2, map(sub_f, n[0], Old[0])))
    RefInd=f(New1)-f(New2)
    if(RefInd<=0): AdjPrinComp = Set1  
    else: AdjPrinComp = Set2  
    RowRewardWeighted=Rep
    if max(map(abs,AdjPrinComp))!=0:
        m=custommath.mean(Rep)
        RRW=[]
        for i in range(len(Rep)):
            RRW.append(AdjPrinComp[i]*Rep[i]/m)
        RowRewardWeighted=custommath.GetWeight(RRW)
    SmoothedR=[]
    for i in range(len(Rep)):
        SmoothedR.append(alpha*RowRewardWeighted[i]+(1-alpha)*Rep[i])
    Out = {"FirstL":FirstLoading, "OldRep":Rep, "ThisRep":RowRewardWeighted, "SmoothRep":SmoothedR}  
    return(Out)
def v_dot(a, b): 
    def mul(c, d): return c*d
    return sum(map(mul, a, b))
def GetDecisionOutcomes(Mtemp, Rep):
# Determines the Outcomes of Decisions based on the provided reputation (weighted vote)
    #For each column
    out=[]
    for i in range(len(Mtemp[0])):
        Row=[]
        Col=[]
        c=map(lambda x: x[i], Mtemp)
        for j in range(len(c)):
            if type(c[j]) not in [str, unicode]:
                Row.append(Rep[j])
                Col.append(c[j])
        Row=custommath.ReWeight(Row)
        out.append(v_dot(Col, Row))
    return custommath.switch_row_cols(out)
def any_NA(M):
    for row in M:
        for i in row:
            if i=='NA': return True
    return False
def diag(v):
    if type(v[0])==list: v=v[0]
    out=[]
    l=len(v)
    for i in range(l):
        row=[0]*l
        row[i]=v[i]
        out.append(row)
    return out
def FillNa(Mna, Rep, Catchp=Decimal('0.1')):
    Mnew = Mna
    MnewC=Mna
    if any_NA(Mna):
        DecisionOutcomesRaw=GetDecisionOutcomes(Mna, Rep)
        NAmat=map(lambda row: map(lambda x: 1 if x=='NA' else 0, row), Mna)
        Mnew=map(lambda row: map(lambda x: 0 if x=='NA' else x, row), Mna)
        NAsToFill=custommath.dot(NAmat, diag(DecisionOutcomesRaw))
        for row in range(len(Mnew)):
            for i in range(len(Mnew[row])):
                Mnew[row][i]=Mnew[row][i]+NAsToFill[row][i]
        return(map(lambda row: map(lambda x: custommath.Catch(x, Catchp), row), Mnew))
    return(Mna)
def Factory(M0, Rep, CatchP=Decimal('0.1'), MaxRow=5000):
    Rep=custommath.ReWeight(Rep)
    Filled=FillNa(M0, Rep, CatchP)
    PlayerInfo=GetRewardWeights(Filled, Rep, Decimal('0.1'))
    AdjLoadings=PlayerInfo['FirstL']
    #print('smoothrep: ' +str(PlayerInfo['SmoothRep']))#way wrong
    #print('Filled: ' +str(Filled))
    DecisionOutcomesRaw=custommath.dot([PlayerInfo['SmoothRep']], Filled)[0]
    #print('raw outcomes: ' +str(DecisionOutcomesRaw))
    DecisionOutcomeAdj=map(lambda x: custommath.Catch(x, CatchP), DecisionOutcomesRaw)
    Certainty=map(lambda x: 2*(x-Decimal('0.5')), DecisionOutcomesRaw)
    Certainty=map(abs, Certainty)
    ConReward=custommath.GetWeight(Certainty)
    Avg_Certainty=custommath.mean(Certainty)
    DecisionOutcomeAdj=[]
    for i, raw in enumerate(DecisionOutcomesRaw):
        DecisionOutcomeAdj.append(custommath.Catch(raw, CatchP))
    DecisionOutcomeFinal=DecisionOutcomeAdj
    NAmat=map(lambda row: map(lambda x: 1 if type(x) in [str, unicode] else 0, row), M0)
    a=custommath.dot([PlayerInfo['SmoothRep']], NAmat)[0]
    ParticipationC=map(lambda x: 1-x, a)
    v=map(sum, NAmat)
    ParticipationR=map(lambda x: 1-x/Decimal(len(NAmat[0])), v)
    PercentNA=1-custommath.mean(ParticipationC)
    NAbonusR = custommath.GetWeight(ParticipationR)
    def plus(a, b): return a+b
    RowBonus = map(plus, map(lambda x: x*PercentNA, NAbonusR), map(lambda x: x*(1-PercentNA),  PlayerInfo['SmoothRep']))
    NAbonusC=custommath.GetWeight(ParticipationC)
    ColBonus=map(plus, map(lambda x: x*PercentNA, NAbonusC), map(lambda x: x*(1-PercentNA), ConReward))
    namatsum=[]
    for i in range(len(NAmat[0])):
        namatsum.append(sum(map(lambda x: x[i], NAmat)))
    Output = {
        'Original': M0,
        'Filled': Filled,
        'Agents': {
            'OldRep': PlayerInfo['OldRep'],#[0],
            'ThisRep': PlayerInfo['ThisRep'],
            'SmoothRep': PlayerInfo['SmoothRep'],
            'NArow': map(sum, NAmat),#.sum(axis=1).base,
            'ParticipationR': ParticipationR,#.base,
            'RelativePart': NAbonusR,#.base,
            'RowBonus': RowBonus,#.base,
        },
        'Decisions': {
            'First Loading': AdjLoadings,
            'DecisionOutcomes_Raw': DecisionOutcomesRaw,
            'Consensus Reward': ConReward,
            'Certainty': Certainty,
            'NAs Filled': namatsum,#NAmat.sum(axis=0),
            'ParticipationC': ParticipationC,
            'Author Bonus': ColBonus,
            'DecisionOutcome_Final': DecisionOutcomeFinal,
        },
        'Participation': 1 - PercentNA,
        'Certainty': Avg_Certainty,
    }
    return Output

