#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

from google.appengine.ext.ndb import model

from google.appengine.api import memcache
import logging

class THModel(model.Model):

    def is_of_class_name(self, class_name):
        return self.__class__.__name__ == class_name

'''
    @classmethod
    def mem_key_for_db_key(cls, db_key):
        logging.info('%s' % db_key)
        return '%s' % db_key 

    @property
    def mem_key(self):
        return self.__class__.mem_key_for_db_key(self.key())

    def update_in_memcache(self):
        return memcache.set(self.mem_key(), self) #@UndefinedVariable
    
    @classmethod
    def get_db_object(cls, db_key):
        db_object = None
        if db_key:
            try:
                mem_key = cls.mem_key_for_db_key(db_key)
                db_object = memcache.get(mem_key)  #@UndefinedVariable
                if db_object is None:
                    db_object = cls.get(db_key)
                    if not db_object.update_in_memcache():
                        logging.error('Error setting memcache for key %s' % mem_key)
            except Exception as e:
                logging.warning('Failed loading %s with key: %s (%s)' % (cls.__name__, db_key, e.message))
        return db_object
'''