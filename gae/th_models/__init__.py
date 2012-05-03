#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

from google.appengine.ext import ndb
from google.appengine.ext.ndb import model

from google.appengine.api import memcache
import logging

class THModel(model.Model):

    def is_of_class_name(self, class_name):
        return self.__class__.__name__ == class_name
        