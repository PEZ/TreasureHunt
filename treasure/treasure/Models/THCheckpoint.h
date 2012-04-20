//
//  THCheckpoint.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-19.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define CHECKPOINT_TITLE_MAXLENGTH 50
#define CHECKPOINT_TEXTCLUE_MAXLENGTH 100

@class THHunt;

@interface THCheckpoint : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) id imageClue;
@property (nonatomic, retain) id imageClueThumbnail;
@property (nonatomic, retain) NSNumber * isQR;
@property (nonatomic, retain) NSString * textClue;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) THHunt *hunt;

@property (readonly) BOOL hasClue;

@end
