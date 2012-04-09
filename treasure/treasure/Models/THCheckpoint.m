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
@dynamic isQR;
@dynamic textClue;
@dynamic title;
@dynamic fkHunt;

@end

@implementation ImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value {
	return [[UIImage alloc] initWithData:value];
}

@end