#!/usr/bin/env python
'''
Created on May 1, 2012

@author: pez
'''

def webapp_add_wsgi_middleware(app):
    from google.appengine.ext.appstats import recording
    app = recording.appstats_wsgi_middleware(app)
    return app