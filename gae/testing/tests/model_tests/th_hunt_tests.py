'''
Created on May 13, 2012

@author: pez
'''
import unittest
from testing import ModelTestCase
from th_models.th_hunt import THHunt
from google.appengine.ext import ndb

class THHuntTest(ModelTestCase):


    def testCheckpoints(self):
        '''Test the checkpoints "back reference"'''
        from th_models.th_user import THUser
        from th_models.th_checkpoint import THCheckpoint
        user = THUser()
        user.put()
        hunt1 = THHunt(user=user.key, title='hunt1')
        hunt2 = THHunt(user=user.key, title='hunt2')
        ndb.put_multi([hunt1, hunt2])
        checkpoints = [THCheckpoint(hunt=hunt1.key, title='checkpoint%d' % i) for i in range(3)]
        ndb.put_multi(checkpoints)
        self.assertEqual(len(hunt1.checkpoints), len(checkpoints))
        self.assertEqual(hunt2.checkpoints, [])
        ndb.delete_multi(hunt1.checkpoints_keys)
        self.assertEqual(hunt1.checkpoints, [])


if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()