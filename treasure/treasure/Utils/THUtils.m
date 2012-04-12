//
//  THUtils.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THUtils.h"

@implementation THUtils

+ (BOOL)isTextReplacementWithinMaxLength:(NSUInteger)maxLength
                                forRange:(NSRange)range
                              andOldText:(NSString *)oldText
                              andNewText:(NSString *)newText
{
    NSUInteger oldLength = [oldText length];
    NSUInteger replacementLength = [newText length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    return newLength <= maxLength;
}

+ (void)saveContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Save context, inresolved error %@, %@", error, [error userInfo]);
    }
}

@end
