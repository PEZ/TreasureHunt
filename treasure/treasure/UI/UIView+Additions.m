//
//  UIView+Additions.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-22.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (NSUInteger)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

@end
