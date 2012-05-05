//
//  THServerConnection.h
//  treasure
//
//  Created by Peter Stromberg on 2012-05-04.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THUser.h"
#import "THHunt.h"
#import "THCheckpoint.h"

typedef void (^THServerConnectionKeyObtainedBlock)(NSString*);
typedef void (^THServerConnectionKeyAndIdObtainedBlock)(NSString*, NSUInteger);
typedef void (^THServerConnectionUpdateDoneBlock)(NSString*);

@interface THServerConnection : NSObject

+ (void)setManagedObjectContext:(NSManagedObjectContext*)context;
+ (BOOL)isUserCreated;
+ (BOOL)isHuntUpdated:(THHunt*)hunt;
+ (BOOL)isCheckpointUpdated:(THCheckpoint*)checkpoint;
+ (void)obtainUserKey:(THServerConnectionKeyObtainedBlock)keyObtainedBlock;
+ (void)obtainHuntKeyForUser:(THUser*)user
                     andHunt:(THHunt*)hunt
                   withBlock:(THServerConnectionKeyObtainedBlock)keyObtainedBlock;
+ (void)obtainCheckpointKeyAndIdForHunt:(THHunt*)hunt
                          andCheckpoint:(THCheckpoint*)checkpoint
                              withBlock:(THServerConnectionKeyAndIdObtainedBlock)keyAndIdObtainedBlock;

@end
