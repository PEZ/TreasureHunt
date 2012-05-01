#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

from google.appengine.ext import db

class THUser(db.Model):
    created_at = db.DateTimeProperty(auto_now_add=True)
    
    def as_dict(self):
        return {'key': str(self.key()),
                'created_at': self.created_at.isoformat()}