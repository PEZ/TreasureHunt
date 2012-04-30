//
//  THHunt+Behavior.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-30.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THCheckpoint+Behavior.h"
#import "THHunt+Behavior.h"

@implementation THHunt (Behavior)

- (BOOL)isComplete {
  BOOL is_complete = YES;
  for (THCheckpoint *checkpoint in self.checkpoints) {
    if (!checkpoint.hasClue) {
      is_complete = NO;
      break;
    }
  }
  is_complete = is_complete && ([self.checkpoints count] > 1);
  return is_complete;
}

@end
