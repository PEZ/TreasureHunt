//
//  THHunt.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-19.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//Todo: Can this be done from querying the model?
#define HUNT_TITLE_MAXLENGTH 50

@class THCheckpoint;

@interface THHunt : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *checkpoints;
@end

@interface THHunt (CoreDataGeneratedAccessors)

- (void)insertObject:(THCheckpoint *)value inCheckpointsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCheckpointsAtIndex:(NSUInteger)idx;
- (void)insertCheckpoints:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCheckpointsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCheckpointsAtIndex:(NSUInteger)idx withObject:(THCheckpoint *)value;
- (void)replaceCheckpointsAtIndexes:(NSIndexSet *)indexes withCheckpoints:(NSArray *)values;
- (void)addCheckpointsObject:(THCheckpoint *)value;
- (void)removeCheckpointsObject:(THCheckpoint *)value;
- (void)addCheckpoints:(NSOrderedSet *)values;
- (void)removeCheckpoints:(NSOrderedSet *)values;
@end
