//
//  THUtils.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THUtils.h"
#import <CommonCrypto/CommonDigest.h>

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

+ (NSString*) sha1ForString:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
