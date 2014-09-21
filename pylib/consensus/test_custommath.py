#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
from custommath import *
 
def TestWeightedMedian():
    data = [
        [7, 1, 2, 4, 10],
        [7, 1, 2, 4, 10],
        [7, 1, 2, 4, 10, 15],
        [1, 2, 4, 7, 10, 15],
        [0, 10, 20, 30],
    ]
    weights = [
        [1, 1/3, 1/3, 1/3, 1],
        [1, 1, 1, 1, 1],
        [1, 1/3, 1/3, 1/3, 1, 1],
        [1/3, 1/3, 1/3, 1, 1, 1],
        [30, 191, 9, 0],
    ]
    answers = [7, 4, 8.5, 8.5, 10]
    for datum, weight, answer in zip(data, weights, answers):
        assert(WeightedMedian(datum, weight) == answer)

if __name__ == "__main__":
    TestWeightedMedian()
