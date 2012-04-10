//
//  NSDate+FormattingAdditions.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-09.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "NSDate+FormattingAdditions.h"

@implementation NSDate (FormattingAdditions)

- (NSString*)asLocalizedDateString
{
    return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString*)asLocalizedDateTimeString
{
    return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

@end
