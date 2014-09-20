#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
from custommath import *
 
data = [7,1,2,4,10]
weights = [1,1/3,1/3,1/3,1] #  7

assert(WeightedMedian(data, weights) == 7)

data = [7,1,2,4,10]
weights = [1,1,1,1,1] #  4

assert(WeightedMedian(data, weights) == 4)

data = [7,1,2,4,10,15]
weights = [1,1/3,1/3,1/3,1,1]

assert(WeightedMedian(data, weights) == 8.5)

data = [1,2,4,7,10,15]
weights = [1/3,1/3,1/3,1,1,1] # ordered differently  8.5

assert(WeightedMedian(data, weights) == 8.5)

data = [0, 10, 20, 30]
weights = [30, 191, 9, 0]

assert(WeightedMedian(data, weights) == 10)
