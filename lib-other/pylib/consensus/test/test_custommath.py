#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Tests for Truthcoin's mathematical tools.

"""
from __future__ import division, unicode_literals, absolute_import
import os
import sys
import platform
import numpy as np
import numpy.ma as ma
if platform.python_version() < "2.7":
    unittest = __import__("unittest2")
else:
    import unittest

HERE = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, os.path.join(HERE, os.pardir))

import custommath as custom

class TestCustommath(unittest.TestCase):

    def setUp(self):
        self.votes = np.array([[1, 1, 0, 0], 
                               [1, 0, 0, 0],
                               [1, 1, 0, 0],
                               [1, 1, 1, 0],
                               [0, 0, 1, 1],
                               [0, 0, 1, 1]])                       
        self.votes = ma.masked_array(self.votes, np.isnan(self.votes))
        self.c = [1, 2, 3, np.nan, 3]
        self.c2 = ma.masked_array(self.c, np.isnan(self.c))
        self.c3 = [2, 3, -1, 4, 0]

    def test_WeightedMedian(self):
        data = [
            [7, 1, 2, 4, 10],
            [7, 1, 2, 4, 10],
            [7, 1, 2, 4, 10, 15],
            [1, 2, 4, 7, 10, 15],
            [0, 10, 20, 30],
            [1, 2, 3, 4, 5],
            [30, 40, 50, 60, 35],
            [2, 0.6, 1.3, 0.3, 0.3, 1.7, 0.7, 1.7, 0.4],
        ]
        weights = [
            [1, 1/3, 1/3, 1/3, 1],
            [1, 1, 1, 1, 1],
            [1, 1/3, 1/3, 1/3, 1, 1],
            [1/3, 1/3, 1/3, 1, 1, 1],
            [30, 191, 9, 0],
            [10, 1, 1, 1, 9],
            [1, 3, 5, 4, 2],
            [2, 2, 0, 1, 2, 2, 1, 6, 0],
        ]
        answers = [7, 4, 8.5, 8.5, 10, 2.5, 50, 1.7]
        for datum, weight, answer in zip(data, weights, answers):
            self.assertEqual(custom.WeightedMedian(datum, weight), answer)

    def test_MeanNa(self):
        expected = [1.0, 2.0, 3.0, 2.25, 3.0]
        actual = custom.MeanNa(self.c2)
        self.assertListEqual(list(actual.base), expected)

    def test_Catch(self):
        expected = [0, 1, 0.5, 0]
        actual = [custom.Catch(0.4),
                  custom.Catch(0.6),
                  custom.Catch(0.4, 0.3),
                  custom.Catch(0.4, 0.1)]
        self.assertEqual(actual, expected)

    def test_Influence(self):
        expected = [np.array([0.88888889]),
                    np.array([1.33333333]),
                    np.array([1.]),
                    np.array([1.33333333])]
        actual = custom.Influence(custom.GetWeight(self.c2))
        result = []
        for i in range(len(actual)):
            result.append((actual[i] - expected[i])**2)
        self.assertLess(sum(result), 0.000000000001)

    def test_ReWeight(self):
        expected = [0.08888888888888889,
                    0.17777777777777778,
                    0.26666666666666666,
                    0.2,
                    0.26666666666666666]
        custom.MeanNa(self.c2)
        actual = custom.ReWeight(self.c2)
        self.assertListEqual(expected, list(actual.base))

    def test_ReverseMatrix(self):
        expected = np.array([[0, 0, 1, 1],
                             [0, 1, 1, 1],
                             [0, 0, 1, 1],
                             [0, 0, 0, 1],
                             [1, 1, 0, 0],
                             [1, 1, 0, 0]])
        actual = custom.ReverseMatrix(self.votes)
        self.assertEqual(np.sum(expected == actual), 24)

    def test_WeightedPrinComp(self):
        expected = np.array([-0.81674714,
                             -0.35969107,
                             -0.81674714,
                             -0.35969107,
                              1.17643821,
                              1.17643821])
        actual = custom.WeightedPrinComp(self.votes)[1]
        result = []
        for i in range(len(actual)):
            result.append((actual[i] - expected[i])**2)
        self.assertLess(sum(result), 0.000000000001)

    def tearDown(self):
        del self.votes
        del self.c
        del self.c2
        del self.c3

if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(TestCustommath)
    unittest.TextTestRunner(verbosity=2).run(suite)
