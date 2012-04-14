//
//  THCheckpoint.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-09.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THCheckpoint.h"
#import "THHunt.h"


@implementation THCheckpoint

@dynamic displayOrder;
@dynamic imageClue;
@dynamic imageClueThumbnail;
@dynamic isQR;
@dynamic textClue;
@dynamic title;
@dynamic hunt;

- (BOOL)hasClue
{
    return self.imageClue || (self.textClue && ![self.textClue isEqualToString:@""]);
}

@end

