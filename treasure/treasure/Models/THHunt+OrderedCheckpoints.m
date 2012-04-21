//
//  THHunt+OrderedCheckpoints.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-21.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THHunt+OrderedCheckpoints.h"

@implementation THHunt (OrderedCheckpoints)

#pragma mark - Dodging bug with missing or faulty implementation of methods in Core Data

- (void)insertObject:(THCheckpoint *)value inCheckpointsAtIndex:(NSUInteger)idx
{
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.checkpoints];
    [tempSet insertObject:value atIndex:idx];
    self.checkpoints = tempSet;
}

- (void)addCheckpointsObject:(THCheckpoint *)value
{
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.checkpoints];
    [tempSet addObject:value];    
    self.checkpoints = tempSet;
}

- (void)removeCheckpointsObject:(THCheckpoint *)value
{
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.checkpoints];
    [tempSet removeObject:value];    
    self.checkpoints = tempSet;
}

@end
