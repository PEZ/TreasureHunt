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

@property (nonatomic) UIImage *imageClue;
@property (nonatomic) UIImage *imageClueThumbnail;
@property (nonatomic) NSNumber *isQR;
@property (nonatomic) NSNumber *isSynced;
@property (nonatomic) NSString *serverId;
@property (nonatomic) NSString *serverKey;
@property (nonatomic) NSString *textClue;
@property (nonatomic) NSString *title;
@property (nonatomic) THHunt *hunt;

@end
