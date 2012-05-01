#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Mar 15, 2012

@author: pez
'''

import unittest
from google.appengine.ext import testbed
from google.appengine.api import memcache
from google.appengine.ext import db

import re

class THTestCase(unittest.TestCase):
    @staticmethod
    def main():
        unittest.main()

    def assertMatches(self, text, *patterns):
        '''
        Assert that all regex patterns matches the text.
        @param text: the text to search
        @param *patterns: one or more regular expression pattern
        '''
        for pattern in patterns:
            if not re.search(pattern, text, re.I):
                raise self.failureException, "'" + pattern + "' not found in " + "'" + text + "'"

    def assertNotMatches(self, text, *patterns):
        '''
        Assert that none of the patterns mathces the text.
        @param text: the text to search
        @param *patterns: one or more regular expression pattern
        '''
        for pattern in patterns:
            if re.search(pattern, text, re.I):
                raise self.failureException, "'" + pattern + "' found in " + "'" + text + "'"

    def assertNone(self, var):
        '''
        Assert that var is None
        '''
        if var is not None:
            raise self.failureException, "'%s' is not None" % var

    def assertNotNone(self, var):
        '''
        Assert that var is not None
        '''
        if var is None:
            raise self.failureException, "'%s' is None" % var
  
    def assertNotRaises(self, excClass, callableObj, *args, **kwargs):
        '''
           Fail if an exception of class excClass is thrown
           by callableObj when invoked with arguments args and keyword
           arguments kwargs. If a different type of exception is
           thrown, it will be caught, and the test case succeeds. 
        '''
        try:
            callableObj(*args, **kwargs)
        except excClass:
            if hasattr(excClass,'__name__'): excName = excClass.__name__
            else: excName = str(excClass)
            raise self.failureException, "%s was raised" % excName
        else:
            return
    
    def assertInInterval(self, value, minv, maxv):
        """ Asserts that value is larger or equal to min and smaller or equal to max """
        if value < minv:
            raise self.failureException, "%s < %s" % (value, minv)
        elif value > maxv:
            raise self.failureException, "%s > %s" % (value, maxv)

    def assertNotInInterval(self, value, minv, maxv):
        """ Asserts that value is larger or equal to min and smaller or equal to max """
        if maxv >= value >= minv:
            raise self.failureException, "%s >= %s >= %s" % (maxv, value, minv)
    
    def assertContains(self, container, value):
        if value not in container:
            raise self.failureException('%r not in %r' % (value, container))
    
    def assertNotContains(self, container, value):
        if value in container:
            raise self.failureException('%r in %r' % (value, container))

class ModelTestCase(THTestCase):    
    def setUp(self):
        super(ModelTestCase, self).setUp()
        self.testbed = testbed.Testbed()
        self.testbed.activate()
        self.testbed.init_datastore_v3_stub()
        self.testbed.init_memcache_stub()
        self.testbed.init_xmpp_stub()

