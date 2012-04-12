//
//  THHunt.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-09.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//Todo: Can this be done from querying the model?
#define HUNT_TITLE_MAXLENGTH 50

@class Checkpoint;

@interface THHunt : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *checkpoints;
@end

@interface THHunt (CoreDataGeneratedAccessors)

- (void)insertObject:(Checkpoint *)value inCheckpointsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCheckpointsAtIndex:(NSUInteger)idx;
- (void)insertCheckpoints:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCheckpointsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCheckpointsAtIndex:(NSUInteger)idx withObject:(Checkpoint *)value;
- (void)replaceCheckpointsAtIndexes:(NSIndexSet *)indexes withCheckpoints:(NSArray *)values;
- (void)addCheckpointsObject:(Checkpoint *)value;
- (void)removeCheckpointsObject:(Checkpoint *)value;
- (void)addCheckpoints:(NSOrderedSet *)values;
- (void)removeCheckpoints:(NSOrderedSet *)values;

@end

