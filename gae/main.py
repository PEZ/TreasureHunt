from google.appengine.ext import webapp
from google.appengine.ext import ndb, blobstore
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.ext.webapp import template

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

class THGetUserAPIHandler(THAPIHandler):
    BASE_URL = '/api/user'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def get(self, user_key):
        user = ndb.Key(urlsafe=urllib.unquote(user_key)).get()
        if user is not None and user.is_of_class_name('THUser'):
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

    def get(self, hunt_key_str):
        hunt = ndb.Key(urlsafe=urllib.unquote(hunt_key_str)).get()
        if hunt is not None and hunt.is_of_class_name('THHunt'):
            self.respond(hunt.as_dict())
        else:
            self.bail_with_message(None, 'unknown hunt', 404)

    def post(self, user_key_str):
        title = self.request.get('title')
        user_key = ndb.Key(urlsafe=urllib.unquote(user_key_str))
        user = user_key.get()
        if user is not None and user.is_of_class_name('THUser'):
            try:
                hunt = THHunt(user=user.key, title=title)
                hunt.put()  
                self.respond(user.as_dict())
            except Exception, e:
                logging.error('Error creating hunt for user %s: %s' % (user_key_str, e.message))
                raise
        else:
            self.bail_with_message(None, 'never seen that dude', 404)

class THUploadCheckpointImageHandler(blobstore_handlers.BlobstoreUploadHandler, THAPIHandler):
    BASE_URL = '/api/upload/checkpoint'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def post(self, checkpoint_key_str):
        logging.debug(checkpoint_key_str)
        files = self.get_uploads('image_clue')
        blob_info = files[0]
        checkpoint_key = ndb.Key(urlsafe=urllib.unquote(checkpoint_key_str))
        checkpoint = checkpoint_key.get()
        if checkpoint is not None and checkpoint.is_of_class_name('THCheckpoint'):
            try:
                image = THCheckpointImage(parent=checkpoint.key, image=blob_info.key())
                checkpoint.has_image_clue = True
                ndb.put_multi([image, checkpoint])
                self.respond({'result': True})
            except Exception, e:
                blob_info.delete()
                logging.error('Error creating image for checkpoint %s: %s' % (checkpoint_key_str, e.message))
                raise
        else:
            blob_info.delete()
            self.bail_with_message(None, 'unknown checkpoint', 404)
            return

class THGenerateCheckpointUploadUrlAPIHandler(THAPIHandler):
    BASE_URL = '/api/generate_upload_url/checkpoint'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def get(self, checkpoint_key_str):
        checkpoint_key = ndb.Key(urlsafe=urllib.unquote(checkpoint_key_str))
        checkpoint = checkpoint_key.get()
        if checkpoint is not None and checkpoint.is_of_class_name('THCheckpoint'):
            upload_url = blobstore.create_upload_url('%s/%s' % (THUploadCheckpointImageHandler.BASE_URL, checkpoint_key.urlsafe()))
            self.respond(json.dumps({'upload_url': upload_url}))
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

    def get(self, checkpoint_key_str):
        checkpoint = ndb.Key(urlsafe=urllib.unquote(checkpoint_key_str)).get()
        if checkpoint is not None and checkpoint.is_of_class_name('THCheckpoint'):
            self.respond(checkpoint.as_dict())
        else:
            self.bail_with_message(None, 'unknown checkpoint', 404)

    def post(self, hunt_key_str):
        title = self.request.get('title')
        text_clue = self.request.get('text_clue')
        hunt = ndb.Key(urlsafe=urllib.unquote(hunt_key_str)).get()
        if hunt is not None and hunt.is_of_class_name('THHunt'):
            try:
                checkpoint = THCheckpoint(hunt=hunt.key, title=title, text_clue=text_clue)
                checkpoint.put()
                self.respond(checkpoint.as_dict())
            except Exception, e:
                logging.error('Error creating checkpoint for hunt %s: %s' % (hunt_key_str, e.message))
                raise
        else:
            self.bail_with_message(None, 'unknown hunt', 404)

    def delete(self, checkpoint_key_str):
        checkpoint = ndb.Key(urlsafe=urllib.unquote(checkpoint_key_str)).get()
        if checkpoint is not None and checkpoint.is_of_class_name('THCheckpoint'):
            try:
                checkpoint.key.delete()
                self.respond({'key': checkpoint_key_str, 'result': 'deleted'})
            except Exception, e:
                logging.error('Error deleting checkpoint %s: %s' % (checkpoint_key_str, e.message))
                raise
        else:
            self.bail_with_message(None, 'unknown checkpoint', 404)

class THCheckpointUpdateAPIHandler(THAPIHandler):
    BASE_URL = '/api/update/checkpoint'
    PATTERN = '^%s/%s' % (BASE_URL, PARAM_REGEX)

    def post(self, checkpoint_key_str):
        title = self.request.get('title', None)
        text_clue = self.request.get('text_clue', None)
        checkpoint_key = ndb.Key(urlsafe=urllib.unquote(checkpoint_key_str))
        checkpoint = checkpoint_key.get()
        if checkpoint is not None and checkpoint.is_of_class_name('THCheckpoint'):
            if title is not None:
                checkpoint.title = title
            if text_clue is not None:
                checkpoint.text_clue = text_clue
            try:
                checkpoint.put()
                self.respond(checkpoint.as_dict())
            except Exception, e:
                logging.error('Error updating checkpoint %s: %s' % (checkpoint_key_str, e.message))
                raise
        else:
            self.bail_with_message(None, 'unknown checkpoint', 404)

class THCheckpointWebHandler(WebHandler):
    BASE_URL = '/c'
    PATTERN = '%s/%s' % (BASE_URL, PARAM_REGEX)
    
    def get(self, checkpoint_id):
        checkpoint_key = ndb.Key(THCheckpoint, int(checkpoint_id))
        checkpoint = checkpoint_key.get()
        if checkpoint is not None and checkpoint.is_of_class_name('THCheckpoint'):
            template_values = {
                'title': 'Checkpoint',
                'checkpoint': checkpoint,
                'image_clue_url': None 
            }
            if checkpoint.has_image_clue:
                template_values['image_clue_url'] = '%s/%s' % (THServeBlobHandler.BASE_URL, checkpoint.image_clue_blob_info_key)
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
                                      (THCheckpointWebHandler.PATTERN, THCheckpointWebHandler),
                                      (THCheckpointUpdateAPIHandler.PATTERN, THCheckpointUpdateAPIHandler)],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
