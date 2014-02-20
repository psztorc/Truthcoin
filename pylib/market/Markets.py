# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import hashlib

hashlib.sha224(("Nobody inspects the spammish repetition").encode('utf-8')).hexdigest()
hashlib.sha224("Nobody inspects the spammish repetition").hexdigest()

def SHA256(Input):
    try:
        return( hashlib.sha256((Input)).hexdigest() )
    except TypeError: #encode utf-8 if it complains about encoding
        return( hashlib.sha256((Input).encode('utf-8')).hexdigest() )
        
def MD5(Input):
    try:
        return( hashlib.md5((Input)).hexdigest() )
    except TypeError: #encode utf-8 if it complains about encoding
        return( hashlib.md5((Input).encode('utf-8')).hexdigest() )
        
Sha256("Nobody inspects the spammish repetition")

C1 = {'Market': nan,     #hash of c1[-1:-4]
           'Size': nan,         #size of c1[-1:-2] in bytes 
           'Shares': nan,       #initially, zero of course
           'Balance':nan,      #funds in escrow for this Market
           'FeeBalance':nan,   #Transaction Fees Collected
           'State':-2,        # -2 indicates active (ie neither trading nor judging are finished).
           'B':1,            #Liquidity Parameter
           'OwnerAd':"1Loxo4RsiokFYXgpjc4CezGAmYnDwaydWh",  #the Bitcoin address of the creator of this Market
           'Title':"Obama2012",                             #title - not necessarily unique
           'Description':"Barack Obama to win United States President in 2012\nThis Market will expire in state 1 if the statement is true and 0 otherwise.",
           #in practice, this will probably be pretty long.
           'Tags': ("Politics, UnitedStates, President, Winner"), #ordinal descriptors
           'EventOverBy':5,             #block number, corresponds to time that this information will be widely and readily availiable.     
           'D.State':("Did Barack H Obama win the United States 2012 presidential election?")
           }

print(C1)

SHA256(str(C1))

def GetId(CtrBlank):
    """md5 hashes the Market, ignoring the hash field for reproduceability, and the shares/balance fields for consistency."""
    
  
  
  wanted_keys = ['l', 'm', 'n'] # The keys you want
dict([(i, bigdict[i]) for i in wanted_keys if i in bigdict])