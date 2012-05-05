//
//  THServerConnection.m
//  treasure
//
//  Created by Peter Stromberg on 2012-05-04.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "THServerConnection.h"
#import "THUtils.h"
#import "THUser+FetchFirstOnly.h"

#define API_BASE_URL_STRING @"http://localhost:8080/api"
#define API_CREATE_USER_URL_STRING API_BASE_URL_STRING @"/user"
#define API_CREATE_HUNT_URL_STRING API_BASE_URL_STRING @"/hunt"

static NSManagedObjectContext *_context;

@implementation THServerConnection


+ (void)setManagedObjectContext:(NSManagedObjectContext*)context {
        _context = context;
}

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
            NSLog(@"Error creating user on server: %@, %@", error, [error userInfo]);
            keyObtainedBlock(nil);
        }];
        [request startAsynchronous];
    }    
}

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
                                                             options:kNilOptions
                                                               error:&error];
        NSString *serverKey = [json objectForKey:@"key"];
        hunt.serverKey = serverKey;
        [THUtils saveContext:_context];
        keyObtainedBlock(hunt.serverKey);
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error creating hunt on server: %@, %@", error, [error userInfo]);
        keyObtainedBlock(nil);
    }];
    [request startAsynchronous];
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

@end
