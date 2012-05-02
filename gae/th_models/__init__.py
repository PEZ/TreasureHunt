#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

from google.appengine.ext import ndb
from google.appengine.ext.ndb import polymodel

from google.appengine.api import memcache
import logging

class THModel(polymodel.PolyModel):
    deleted = ndb.BooleanProperty(default=False)
