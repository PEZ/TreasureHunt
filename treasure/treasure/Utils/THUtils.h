//
//  THUtils.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THUtils : NSObject

+ (BOOL)isTextReplacementWithinMaxLength:(NSUInteger)maxLength
                                forRange:(NSRange)range
                              andOldText:(NSString *)oldText
                              andNewText:(NSString *)newText;

+ (void)saveContext:(NSManagedObjectContext *)context;

+ (NSString*) sha1ForString:(NSString*)input;

@end
