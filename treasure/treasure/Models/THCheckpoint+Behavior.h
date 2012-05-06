//
//  THCheckpoint+Behavior.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-30.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THCheckpoint.h"

@interface THCheckpoint (Behavior)

@property (readonly) BOOL hasClue;

- (BOOL)shouldUploadImage;

@end
