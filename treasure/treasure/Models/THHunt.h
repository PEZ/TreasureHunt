//
//  THHunt.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-09.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface THHunt : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *huntClues;
@end

@interface THHunt (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inHuntCluesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHuntCluesAtIndex:(NSUInteger)idx;
- (void)insertHuntClues:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHuntCluesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHuntCluesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceHuntCluesAtIndexes:(NSIndexSet *)indexes withHuntClues:(NSArray *)values;
- (void)addHuntCluesObject:(NSManagedObject *)value;
- (void)removeHuntCluesObject:(NSManagedObject *)value;
- (void)addHuntClues:(NSOrderedSet *)values;
- (void)removeHuntClues:(NSOrderedSet *)values;
@end
