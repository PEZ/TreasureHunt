from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

import json

import traceback
import logging

from th_models.th_user import THUser


class THAPIHandler(webapp.RequestHandler):
    def respond(self, message_struct):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write(json.dumps(message_struct))

    def bail_with_message(self, err, message_struct, code=500):
        self.error(code)
        if err is not None:
            logging.warning("%s\n%s" % (err.message, traceback.format_exc()))
        self.respond(message_struct)

class THGetUserAPIHandler(THAPIHandler):
    def get(self, user_key):
        user = None
        if (user_key is not None):
            try:
                user = THUser.get(user_key)
            except Exception, e:
                logging.warning('Failed loading user with key: %s (%s)' % (user_key, e.message))
        if (user is not None):
            self.respond('Hello, %s' % user.key())
        else:
            self.bail_with_message(None, 'never seen that dude', 404)

class THCreateUserAPIHandler(THAPIHandler):
    def post(self):
        user = THUser()
        user.put()
        self.respond('Hello, %s' % user.key())


application = webapp.WSGIApplication([('^/user/?$', THCreateUserAPIHandler),
                                      ('^/user/([-\w]+)', THGetUserAPIHandler)], debug=True)


def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
