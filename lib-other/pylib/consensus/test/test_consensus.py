#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Tests for Truthcoin's consensus functions.

Verifies that the consensus algorithm works as expected.
Check test_answers.txt for expected results.

"""
from __future__ import division, unicode_literals, absolute_import
import os
import sys
import platform
import json
import numpy as np
import numpy.ma as ma
if platform.python_version() < "2.7":
    unittest = __import__("unittest2")
else:
    import unittest

HERE = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, os.path.join(HERE, os.pardir))

import consensus

def prp(o):
    print(json.dumps(outcome, indent=3, sort_keys=True))

class TestConsensus(unittest.TestCase):

    def setUp(self):
        self.votes_unmasked = np.array([
            [1, 1, 0, 0],
            [1, 0, 0, 0],
            [1, 1, 0, 0],
            [1, 1, 1, 0],
            [0, 0, 1, 1],
            [0, 0, 1, 1],
        ])
        self.votes = ma.masked_array(self.votes_unmasked, np.isnan(self.votes_unmasked))

    def test_Factory(self):
        outcome = consensus.Factory(self.votes)
        self.assertAlmostEquals(outcome["Certainty"], 0.228237569613, places=11)

    def test_Factory_scaled(self):
        scalar_decision_params = [
            {"scaled": True, "min": 0.1, "max": 0.5},
            {"scaled": True, "min": 0.2, "max": 0.7},
            {"scaled": False, "min": 0, "max": 1},
            {"scaled": False, "min": 0, "max": 1},
        ]
        outcome = consensus.Factory(self.votes, Scales=scalar_decision_params)
        self.assertAlmostEquals(outcome["Certainty"], 0.618113325804, places=11)

    def tearDown(self):
        del self.votes_unmasked
        del self.votes

if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(TestConsensus)
    unittest.TextTestRunner(verbosity=2).run(suite)
