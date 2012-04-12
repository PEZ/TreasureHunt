//
//  THCheckpoint.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-09.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//Todo: See if the model can be queried for these attributes
#define CHECKPOINT_TITLE_MAXLENGTH 50
#define CHECKPOINT_TEXTCLUE_MAXLENGTH 1000

@class THHunt;

@interface THCheckpoint : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) UIImage* imageClue;
@property (nonatomic, retain) UIImage* imageClueThumbnail;
@property (nonatomic, retain) NSNumber * isQR;
@property (nonatomic, retain) NSString * textClue;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) THHunt *hunt;

@end