# -*- coding: utf-8 -*-
"""
Spyder Editor
WinPython-64bit-3.3.3.3

Note: "Imported NumPy 1.8.0, SciPy 0.13.3, Matplotlib 1.3.1, guidata 1.6.1, guiqwt 2.3.2"
"""

c = [1,2,3,nan,3]

def MeanNa(Vec):
    """Replaces missing values with the vector mean"""
    MVec = ma.masked_array(Vec,isnan(Vec))
    MM = mean(MVec)
    MVec[where(MVec.mask)] = MM
    return(MVec)
    
q = MeanNa(c)
print(q)
    