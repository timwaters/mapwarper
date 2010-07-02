# stolen from shapely
# http://trac.gispython.org/projects/PCL/browser/Shapely/trunk/tests/test_doctests.py
# Copyright (c) 2007, Sean C. Gillies

import doctest
import unittest
import glob
import os

optionflags = (doctest.NORMALIZE_WHITESPACE |
               doctest.ELLIPSIS)

def list_doctests():
    return [filename
            for filename
            in glob.glob(os.path.join(os.path.dirname(__file__), '*.txt'))]

def open_file(filename, mode='r'):
    """Helper function to open files from within the tests package."""
    return open(os.path.join(os.path.dirname(__file__), filename), mode)

def setUp(test):
    test.globs.update(dict(
            open_file = open_file,
            ))

def run_doc_tests():
    return unittest.TestSuite(
        [doctest.DocFileSuite(os.path.basename(filename),
                              optionflags=optionflags,
                              setUp=setUp)
         for filename
         in list_doctests()])

if __name__ == "__main__":
    runner = unittest.TextTestRunner()
    runner.run(run_doc_tests())
