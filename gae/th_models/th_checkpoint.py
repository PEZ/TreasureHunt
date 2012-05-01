#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

from google.appengine.ext import db, blobstore
from th_models.th_hunt import THHunt

class THCheckpoint(db.Model):
    hunt = db.ReferenceProperty(THHunt, collection_name='checkpoints', required=True)
    created_at = db.DateTimeProperty(auto_now_add=True)
    updated_at = db.DateTimeProperty(auto_now=True)
    title = db.StringProperty(default='')
    image_clue = blobstore.BlobReferenceProperty()
    text_clue = db.StringProperty(default='')
