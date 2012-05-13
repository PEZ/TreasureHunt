#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

from google.appengine.ext import ndb
from th_models import THModel
from th_models.th_user import THUser

class THHunt(THModel):
    user = ndb.KeyProperty(kind=THUser, required=True)
    created_at = ndb.DateTimeProperty(auto_now_add=True)
    updated_at = ndb.DateTimeProperty(auto_now=True)
    title = ndb.StringProperty(default='')
    deleted = ndb.BooleanProperty(default=False)

    def as_dict(self):
        return {'key': str(self.key.urlsafe()),
                'title': self.title,
                'created_at': self.created_at.isoformat(),
                'updated_at': self.updated_at.isoformat()}

    @property
    def checkpoints_keys(self):
        from th_models.th_checkpoint import THCheckpoint
        return THCheckpoint.query(THCheckpoint.hunt == self.key).fetch(keys_only=True)

    @property
    def checkpoints(self):
        return [key.get() for key in self.checkpoints_keys]