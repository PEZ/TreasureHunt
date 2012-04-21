//
//  THHunt+OrderedCheckpoints.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-21.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THHunt.h"

@interface THHunt (OrderedCheckpoints)
- (void)insertObject:(THCheckpoint *)value inCheckpointsAtIndex:(NSUInteger)idx;
- (void)addCheckpointsObject:(THCheckpoint *)value;
- (void)removeCheckpointsObject:(THCheckpoint *)value;
@end
