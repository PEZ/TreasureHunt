//
//  THCheckpoint+Behavior.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-30.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THCheckpoint+Behavior.h"
#import "THUtils.h"

@implementation THCheckpoint (Behavior)

- (BOOL)hasClue
{
    return self.imageClue || (self.textClue && ![self.textClue isEqualToString:@""]);
}

@end
