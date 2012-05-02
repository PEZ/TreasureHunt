#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

from google.appengine.ext import db, blobstore
from th_models import THModel
from th_models.th_hunt import THHunt

class THCheckpoint(THModel):
    hunt = db.ReferenceProperty(THHunt, collection_name='checkpoints', required=True)
    created_at = db.DateTimeProperty(auto_now_add=True)
    updated_at = db.DateTimeProperty(auto_now=True)
    title = db.StringProperty(default='')
    text_clue = db.StringProperty(default='')
    has_image_clue = db.BooleanProperty(default=False)

    def as_dict(self, full=False):
        return_dict = {'key': str(self.key()),
                       'title': self.title,
                       'created_at': self.created_at.isoformat(),
                       'updated_at': self.updated_at.isoformat(),
                       'has_image_clue': self.has_image_clue,
                       'has_text_clue': self.has_text_clue}
        if full:
            return_dict.update({'text_clue': self.text_clue})
        return return_dict

    @property
    def image_clue_key(self):
        return THCheckpointImage.all(keys_only=True).ancestor(self).get()

    @property
    def image_clue_blob_info_key(self):
        if self.has_image_clue:
            image = THCheckpointImage.get(self.image_clue_key)
            if image is not None:
                return image.image.key()

    @property
    def has_text_clue(self):
        return self.text_clue is not None and self.text_clue.strip() != ""

class THCheckpointImage(db.Model):
    image = blobstore.BlobReferenceProperty()
