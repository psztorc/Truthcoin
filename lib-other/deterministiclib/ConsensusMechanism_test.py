from ConsensusMechanism import *
def test_GetRewardWeights():
    M = [[1, 1, 0, 0],
         [1, 0, 0, 0],
         [1, 1, 0, 0],
         [1, 1, 1, 0],
         [0, 0, 1, 1],
         [0, 0, 1, 1]]
    '''
{u'ThisRep': array([[ 0.2823757,  0.2176243,  0.2823757,  0.2176243,  0.       ,  0.       ]]), u'FirstL': array([-0.5395366 , -0.45705607,  0.45705607,  0.5395366 ]), u'SmoothRep': array([[ 0.17823757,  0.17176243,  0.17823757,  0.17176243,  0.15      ,
         0.15      ]]), u'OldRep': array([[ 0.16666667,  0.16666667,  0.16666667,  0.16666667,  0.16666667,
         0.16666667]])}
    '''
    import pprint
    pprint.pprint(GetRewardWeights(M))
def test_getdecisionoutcomes():
    M=[[1,    1,    0,    0],
       [1,    0,    0,    0],
       [1,    1,    0,    0],
       [1,    1,    1,    0],
       [0,    0,    1,    1],
       [0,    0,    1,    1]]
    print(GetDecisionOutcomes(M, [1]*6))
    #[[Decimal('0.6666666666666666666666666668'), Decimal('0.5000000000000000000000000001'), Decimal('0.5000000000000000000000000001'), Decimal('0.3333333333333333333333333334')]]
def FillNa_test():
    M=[[1,    1,    0,    0],
       [1,    0,    'NA',    'NA'],
       [1,    'NA',    0,    'NA'],
       [1,    1,    1,    'NA'],
       [0,    'NA',    1,    'NA'],
       [0,    0,    1,    1]]
    print(FillNa(M, [1,1,1,1,1,1]))
#[[Decimal('1'), Decimal('1'), Decimal('0'), Decimal('0')], [Decimal('1'), Decimal('0'), Decimal('1'), Decimal('0.5')], [Decimal('1'), Decimal('0.5'), Decimal('0'), Decimal('0.5')], [Decimal('1'), Decimal('1'), Decimal('1'), Decimal('0.5')], [Decimal('0'), Decimal('0.5'), Decimal('1'), Decimal('0.5')], [Decimal('0'), Decimal('0'), Decimal('1'), Decimal('1')]]
def Factory_test():
    import pprint
    M1=[[1,    1,    0,    'NA'],
        [1,    0,    0,    0],
        [1,    1,    0,    0],
        [1,    1,    1,    0],
        [0,    0,    1,    1],
        [0,    0,    1,    1]]
    pprint.pprint(Factory(M1, [1,1,1,1,1,1]))
#Factory_test()
