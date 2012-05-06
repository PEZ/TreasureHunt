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

#ifdef DEBUG
    #define API_BASE_URL_STRING @"http://localhost:8080/api"
#else
    #define API_BASE_URL_STRING @"http://trailofclues.appspot.com/api"
#endif


typedef void (^THServerConnectionKeyObtainedBlock)(NSString*);
typedef void (^THServerConnectionKeyAndIdObtainedBlock)(NSString*, NSString*);
typedef void (^THServerConnectionUpdateDoneBlock)(BOOL);

@interface THServerConnection : NSObject

+ (void)setManagedObjectContext:(NSManagedObjectContext*)context;
+ (BOOL)isUserCreated;
+ (BOOL)isHuntUpdated:(THHunt*)hunt;
+ (BOOL)isCheckpointUpdated:(THCheckpoint*)checkpoint;

#define API_CREATE_USER_URL_STRING API_BASE_URL_STRING @"/user"
+ (void)obtainUserKey:(THServerConnectionKeyObtainedBlock)keyObtainedBlock;

#define API_CREATE_HUNT_URL_STRING API_BASE_URL_STRING @"/hunt"
+ (void)obtainHuntKeyForUser:(THUser*)user
                     andHunt:(THHunt*)hunt
                   withBlock:(THServerConnectionKeyObtainedBlock)keyObtainedBlock;

#define API_UPDATE_HUNT_URL_STRING API_BASE_URL_STRING @"/update/hunt"
+ (void)updateHunt:(THHunt*)hunt withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock;

#define API_CREATE_CHECKPOINT_URL_STRING API_BASE_URL_STRING @"/checkpoint"
+ (void)obtainCheckpointKeyAndIdForHunt:(THHunt*)hunt
                          andCheckpoint:(THCheckpoint*)checkpoint
                              withBlock:(THServerConnectionKeyAndIdObtainedBlock)keyAndIdObtainedBlock;

#define API_UPDATE_CHECKPOINT_URL_STRING API_BASE_URL_STRING @"/update/checkpoint"
+ (void)updateCheckpoint:(THCheckpoint*)checkpoint withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock;


@end
