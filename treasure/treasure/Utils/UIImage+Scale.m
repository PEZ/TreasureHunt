//
//  UIImage+Scale.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-10.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

- (UIImage*)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);

    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
