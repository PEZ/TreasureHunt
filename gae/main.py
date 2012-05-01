from google.appengine.ext import webapp
from google.appengine.ext import db, blobstore
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.ext.webapp import template
from google.appengine.api import memcache

import json
import os
import urllib

import traceback
import logging

from th_models.th_user import THUser
from th_models.th_hunt import THHunt
from th_models.th_checkpoint import THCheckpoint, THCheckpointImage

#PARAM_REGEX = r'([-\w]+)/?'
PARAM_REGEX = r'([^/]+)/?'

class THAPIHandler(webapp.RequestHandler):
    def respond(self, message_struct):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write(json.dumps(message_struct))

    def bail_with_message(self, err, message_struct, code=500):
        self.error(code)
        if err is not None:
            logging.warning("%s\n%s" % (err.message, traceback.format_exc()))
        self.respond(message_struct)

class WebHandler(webapp.RequestHandler):

    def Render(self, template_file, template_values, layout='main.html'):
        if layout == None:
            _template = template_file
        else:
            _template = layout
            template_values = dict(template_values, **{'template': template_file})
        path = os.path.join(os.path.dirname(__file__), 'templates', _template)
        self.response.out.write(template.render(path, template_values))

    def error(self, code):
        super(WebHandler, self).error(code)
        if code == 404:
            self.Render("404.html", {})

def get_db_object(model_class, db_key):
    db_object = None
    if db_key:
        try:
            mem_key = '%s:%s' % (model_class.__name__, db_key)
            db_object = memcache.get(mem_key)  #@UndefinedVariable
            if db_object is None:
                db_object = model_class.get(db_key)
                if not memcache.add(mem_key, db_object): #@UndefinedVariable
                    logging.error('Error setting memcache for key %s' % mem_key)
        except Exception as e:
            logging.warning('Failed loading %s with key: %s (%s)' % (model_class.__name__, db_key, e.message))
    return db_object

def get_user(user_key):
    return get_db_object(THUser, user_key)

def get_hunt(hunt_key):
    return get_db_object(THHunt, hunt_key)

def get_checkpoint(checkpoint_key):
    return get_db_object(THCheckpoint, checkpoint_key)

class THGetUserAPIHandler(THAPIHandler):
    BASE_URL = '/api/user'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def get(self, user_key):
        user = get_user(user_key)
        if (user is not None):
            self.respond(user.as_dict())
        else:
            self.bail_with_message(None, 'never seen that dude', 404)

class THCreateUserAPIHandler(THAPIHandler):
    BASE_URL = '/api/user'
    PATTERN = '%s/?$' % BASE_URL

    def post(self):
        user = THUser()
        user.put()
        self.respond(user.as_dict())

class THHuntAPIHandler(THAPIHandler):
    BASE_URL = '/api/hunt'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def get(self, hunt_key):
        hunt = get_hunt(hunt_key)
        if (hunt is not None):
            self.respond(hunt.as_dict())
        else:
            self.bail_with_message(None, 'unknown hunt', 404)

    def post(self, user_key):
        title = self.request.get('title')
        user = get_user(user_key)
        if (user is not None):
            hunt = THHunt(user=user, title=title)
            hunt.put()
            self.respond(hunt.as_dict())
        else:
            self.bail_with_message(None, 'never seen that dude', 404)

class THUploadCheckpointImageHandler(blobstore_handlers.BlobstoreUploadHandler, THAPIHandler):
    BASE_URL = '/api/upload/checkpoint'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def post(self, checkpoint_key):
        checkpoint = get_checkpoint(checkpoint_key)
        files = self.get_uploads('image_clue')
        blob_info = files[0]
        if checkpoint is not None:
            image = THCheckpointImage(parent=checkpoint, image=blob_info.key())
            checkpoint.has_image_clue = True
            db.put([image, checkpoint])
            self.respond(checkpoint.as_dict(full=True))
        else:
            blob_info.delete()
            self.bail_with_message(None, 'unknown checkpoint', 404)

class THGenerateCheckpointUploadUrlAPIHandler(THAPIHandler):
    BASE_URL = '/api/generate_upload_url/checkpoint'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def get(self, checkpoint_key):
        checkpoint = get_checkpoint(checkpoint_key)
        if (checkpoint is not None):
            upload_url = blobstore.create_upload_url('%s/%s' % (THUploadCheckpointImageHandler.BASE_URL, checkpoint_key))
            self.respond(upload_url)
        else:
            self.bail_with_message(None, 'unknown checkpoint', 404)

class THServeBlobHandler(blobstore_handlers.BlobstoreDownloadHandler):
    BASE_URL = '/image'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def get(self, resource):
        resource = str(urllib.unquote(resource))
        blob_info = blobstore.BlobInfo.get(resource)
        self.send_blob(blob_info)

class THCheckpointAPIHandler(THAPIHandler):
    BASE_URL = '/api/checkpoint'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def get(self, checkpoint_key):
        checkpoint = get_checkpoint(checkpoint_key)
        if (checkpoint is not None):
            self.respond(checkpoint.as_dict())
        else:
            self.bail_with_message(None, 'unknown checkpoint', 404)

    def post(self, hunt_key):
        title = self.request.get('title')
        text_clue = self.request.get('text_clue')
        hunt = get_hunt(hunt_key)
        if (hunt is not None):
            checkpoint = THCheckpoint(hunt=hunt, title=title, text_clue=text_clue)
            checkpoint.put()
            self.respond(checkpoint.as_dict())
        else:
            self.bail_with_message(None, 'unknown hunt', 404)

class THCheckpointWebHandler(WebHandler):
    BASE_URL = '/c'
    PATTERN = '%s/%s' % (BASE_URL, PARAM_REGEX)
    
    def get(self, checkpoint_key):
        checkpoint = get_checkpoint(checkpoint_key)
        if (checkpoint is not None):
            template_values = {
                'title': 'Checkpoint',
                'checkpoint': checkpoint,
                'image_clue_url': '%s/%s' % (THServeBlobHandler.BASE_URL, checkpoint.image_clue_blob_info_key)
            }
            self.Render("checkpoint.html", template_values)
        else:
            self.error(404)

application = webapp.WSGIApplication([(THCreateUserAPIHandler.PATTERN, THCreateUserAPIHandler),
                                      (THGetUserAPIHandler.PATTERN, THGetUserAPIHandler),
                                      (THHuntAPIHandler.PATTERN, THHuntAPIHandler),
                                      (THCheckpointAPIHandler.PATTERN, THCheckpointAPIHandler),
                                      (THGenerateCheckpointUploadUrlAPIHandler.PATTERN, THGenerateCheckpointUploadUrlAPIHandler),
                                      (THUploadCheckpointImageHandler.PATTERN, THUploadCheckpointImageHandler),
                                      (THServeBlobHandler.PATTERN, THServeBlobHandler),
                                      (THCheckpointWebHandler.PATTERN, THCheckpointWebHandler)],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
