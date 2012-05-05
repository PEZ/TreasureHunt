//
//  THUser+FetchFirstOnly.m
//  treasure
//
//  Created by Peter Stromberg on 2012-05-05.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THUser+FetchFirstOnly.h"

@implementation THUser (FetchFirstOnly)

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
}

+ (THUser *)firstInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityInManagedObjectContext:context]];
    [fetchRequest setFetchLimit:1];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
        return nil;
    } else if ([fetchedObjects count] > 0) {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}

@end
