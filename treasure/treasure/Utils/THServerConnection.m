//
//  THServerConnection.m
//  treasure
//
//  Created by Peter Stromberg on 2012-05-04.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "THServerConnection.h"
#import "THUtils.h"
#import "THUser+FetchFirstOnly.h"

static NSManagedObjectContext *_context;

@interface THServerConnection (Private)
+ (void)obtainHuntKeyForNotNilUser:(THUser *)user
                           andHunt:(THHunt *)hunt
                         withBlock:(THServerConnectionKeyObtainedBlock)keyObtainedBlock;
+ (void)updateKeyedHunt:(THHunt*)hunt withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock;
@end

@implementation THServerConnection


+ (void)setManagedObjectContext:(NSManagedObjectContext*)context {
        _context = context;
}

#pragma mark - Key obtination

+ (void)obtainUserKey:(THServerConnectionKeyObtainedBlock)keyObtainedBlock
{
    THUser *user = [THUser firstInManagedObjectContext:_context];
    if (user != nil) {
        keyObtainedBlock(user.serverKey);
    }
    else {
        NSURL *url = [NSURL URLWithString:API_CREATE_USER_URL_STRING];
        __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.requestMethod = @"POST";

        [request setCompletionBlock:^{
            NSError *error;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData]
                                                                 options:kNilOptions
                                                                   error:&error];
            NSString *serverKey = [json objectForKey:@"key"];
            THUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_context];
            user.serverKey = serverKey;
            [THUtils saveContext:_context];
            keyObtainedBlock(user.serverKey);
        }];
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"Error creating user on server: %@@", error);
            keyObtainedBlock(nil);
        }];
        [request startAsynchronous];
    }    
}


+ (void)obtainHuntKeyForUser:(THUser *)user
                     andHunt:(THHunt *)hunt
                   withBlock:(THServerConnectionKeyObtainedBlock)keyObtainedBlock
{
    if (user != nil) {
        [THServerConnection obtainHuntKeyForNotNilUser:user andHunt:hunt withBlock:keyObtainedBlock];
    }
    else {
        [THServerConnection obtainUserKey:^(NSString *userServerKey) {
            if (userServerKey != nil) {
                THUser *user = [THUser firstInManagedObjectContext:_context];
                [THServerConnection obtainHuntKeyForNotNilUser:user andHunt:hunt withBlock:keyObtainedBlock];
            }
        }];
    }
}

#pragma mark - Updates
+ (void)updateHunt:(THHunt *)hunt withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock
{
    if (hunt.serverKey == nil) {
        THUser *user = [THUser firstInManagedObjectContext:_context];
        [THServerConnection obtainHuntKeyForUser:user andHunt:hunt withBlock:^(NSString *serverKey) {
            [self updateKeyedHunt:hunt withBlock:^(BOOL isSuccess) {
                updateDoneBlock(isSuccess);
            }];
        }];
    }
    else {
        [self updateKeyedHunt:hunt withBlock:^(BOOL isSuccess) {
            updateDoneBlock(isSuccess);
        }];
    }
}

#pragma mark - Private

+ (void)obtainHuntKeyForNotNilUser:(THUser *)user
                           andHunt:(THHunt *)hunt
                         withBlock:(THServerConnectionKeyObtainedBlock)keyObtainedBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_CREATE_HUNT_URL_STRING, user.serverKey]];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.requestMethod = @"POST";
    [request setCompletionBlock:^{
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData]
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        NSString *serverKey = [json objectForKey:@"key"];
        if (error || serverKey == nil) {
            [request failWithError:error];
        }
        else {
            hunt.serverKey = serverKey;
            [THUtils saveContext:_context];
            keyObtainedBlock(hunt.serverKey);
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error creating hunt on server: %@", error);
        keyObtainedBlock(nil);
    }];
    [request startAsynchronous];
}

+ (void)updateKeyedHunt:(THHunt *)hunt withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_UPDATE_HUNT_URL_STRING, hunt.serverKey]];
    __weak ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:hunt.title forKey:@"title"];
    [request setCompletionBlock:^{
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData]
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        NSString *serverKey = [json objectForKey:@"key"];
        if (error || serverKey == nil) {
            [request failWithError:error];
        }
        else {
            hunt.isSynced = [NSNumber numberWithBool:YES];
            [THUtils saveContext:_context];
            NSLog(@"Hunt updated on server: %@, %@", hunt.serverKey, hunt.title);
            updateDoneBlock(YES);
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error updating hunt on server: key=%@, title=%@, error=%@", hunt.serverKey, hunt.title, error);
        updateDoneBlock(NO);
    }];
    [request startAsynchronous];
}

@end
