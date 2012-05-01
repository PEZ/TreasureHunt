#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

from google.appengine.ext import db
from th_models.th_user import THUser

class THHunt(db.Model):
    user = db.ReferenceProperty(THUser, collection_name='hunts', required=True)
    created_at = db.DateTimeProperty(auto_now_add=True)
    updated_at = db.DateTimeProperty(auto_now=True)
    title = db.StringProperty(default='')
