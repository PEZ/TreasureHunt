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

+ (NSError *)errorOrNewError:(NSError*)error forRequest:(__weak ASIHTTPRequest *)request;

+ (void)obtainCheckpointKeyForKeyedHunt:(THHunt*)hunt
                          andCheckpoint:(THCheckpoint*)checkpoint
                              withBlock:(THServerConnectionKeyAndIdObtainedBlock)keyAndIdObtainedBlock;

+ (void)updateKeyedCheckpoint:(THCheckpoint*)checkpoint withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock;

typedef void (^THServerConnectionCheckpointUploadUrlObtainedBlock)(NSString*);
#define API_OBTAIN_CHECKPOINT_UPLOAD_URL_STRING API_BASE_URL_STRING @"/generate_upload_url/checkpoint"
+ (void)obtainCheckpointUploadURL:(THCheckpoint*)checkpoint
                       withBlock:(THServerConnectionCheckpointUploadUrlObtainedBlock)urlObtainedBlock;

+ (void)uploadImageForKeyedCheckpoint:(THCheckpoint *)checkpoint
                            withBlock:(THServerConnectionCheckpointImageUploadedBlock)imageUploadedBlock;

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
    if (user == nil) {
        [THServerConnection obtainUserKey:^(NSString *userServerKey) {
            if (userServerKey != nil) {
                THUser *user = [THUser firstInManagedObjectContext:_context];
                [THServerConnection obtainHuntKeyForNotNilUser:user andHunt:hunt withBlock:keyObtainedBlock];
            }
            else {
                keyObtainedBlock(nil);
            }
        }];
    }
    else {
        [THServerConnection obtainHuntKeyForNotNilUser:user andHunt:hunt withBlock:keyObtainedBlock];
    }
}

+ (void)obtainCheckpointKeyAndIdForHunt:(THHunt *)hunt
                          andCheckpoint:(THCheckpoint *)checkpoint
                              withBlock:(THServerConnectionKeyAndIdObtainedBlock)keyAndIdObtainedBlock
{
    if (hunt.serverKey == nil) {
        THUser *user = [THUser firstInManagedObjectContext:_context];
        [THServerConnection obtainHuntKeyForUser:user andHunt:hunt withBlock:^(NSString *huntServerKey) {
            if (huntServerKey != nil) {
                [THServerConnection obtainCheckpointKeyForKeyedHunt:hunt
                                                      andCheckpoint:checkpoint
                                                          withBlock:keyAndIdObtainedBlock];
            }
            else {
                keyAndIdObtainedBlock(nil, nil);
            }
        }];
    }
    else {
        [THServerConnection obtainCheckpointKeyForKeyedHunt:hunt
                                              andCheckpoint:checkpoint
                                                  withBlock:keyAndIdObtainedBlock];
    }
}

#pragma mark - Updates
+ (void)updateHunt:(THHunt *)hunt withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock
{
    if (hunt.serverKey == nil) {
        THUser *user = [THUser firstInManagedObjectContext:_context];
        [THServerConnection obtainHuntKeyForUser:user andHunt:hunt withBlock:^(NSString *serverKey) {
            [self updateKeyedHunt:hunt withBlock:updateDoneBlock];
        }];
    }
    else {
        [self updateKeyedHunt:hunt withBlock:updateDoneBlock];
    }
}

+ (void)updateScalarDataForCheckpoint:(THCheckpoint *)checkpoint withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock
{
    if (checkpoint.serverKey == nil) {
        [self obtainCheckpointKeyAndIdForHunt:checkpoint.hunt
                                andCheckpoint:checkpoint
                                    withBlock:^(NSString *serverKey, NSString *serverId) {
            [self updateKeyedCheckpoint:checkpoint withBlock:updateDoneBlock];
        }];
    }
    else {
        [self updateKeyedCheckpoint:checkpoint withBlock:updateDoneBlock];
    }
}

+ (void)uploadImageForCheckpoint:(THCheckpoint *)checkpoint
                       withBlock:(THServerConnectionCheckpointImageUploadedBlock)imageUploadedBlock
{
    if (checkpoint.serverKey == nil) {
        [self obtainCheckpointKeyAndIdForHunt:checkpoint.hunt
                                andCheckpoint:checkpoint
                                    withBlock:^(NSString *serverKey, NSString *serverId) {
                                        [self uploadImageForKeyedCheckpoint:checkpoint withBlock:imageUploadedBlock];
                                    }];
    }
    else {
        [self uploadImageForKeyedCheckpoint:checkpoint withBlock:imageUploadedBlock];
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
            [request failWithError:[self errorOrNewError:error fromRequest:request]];
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

+ (void)obtainCheckpointKeyForKeyedHunt:(THHunt*)hunt
                          andCheckpoint:(THCheckpoint*)checkpoint
                         withBlock:(THServerConnectionKeyAndIdObtainedBlock)keyAndIdObtainedBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_CREATE_CHECKPOINT_URL_STRING, hunt.serverKey]];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.requestMethod = @"POST";
    [request setCompletionBlock:^{
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData]
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        NSString *serverKey = [json objectForKey:@"key"];
        NSString *serverId = [json objectForKey:@"id"];
        if (error || serverKey == nil) {
            [request failWithError:[self errorOrNewError:error fromRequest:request]];
        }
        else {
            checkpoint.serverKey = serverKey;
            checkpoint.serverId = serverId;
            [THUtils saveContext:_context];
            NSLog(@"Checkpoint created on server: key=%@", checkpoint.serverKey);
            keyAndIdObtainedBlock(checkpoint.serverKey, checkpoint.serverId);
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error creating checkpoint on server: error=%@", error);
        keyAndIdObtainedBlock(nil, nil);
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
            [request failWithError:[self errorOrNewError:error fromRequest:request]];
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

+ (void)updateKeyedCheckpoint:(THCheckpoint*)checkpoint withBlock:(THServerConnectionUpdateDoneBlock)updateDoneBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_UPDATE_CHECKPOINT_URL_STRING, checkpoint.serverKey]];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:checkpoint.title forKey:@"title"];
    [request setPostValue:checkpoint.textClue forKey:@"text_clue"];
    [request setCompletionBlock:^{
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData]
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        NSString *serverKey = [json objectForKey:@"key"];
        if (error || serverKey == nil) {
            [request failWithError:[self errorOrNewError:error fromRequest:request]];
        }
        else {
            checkpoint.isScalarDataSynced = [NSNumber numberWithBool:YES];
            [THUtils saveContext:_context];
            NSLog(@"Checkpoint scalar data updated on server: %@, %@", checkpoint.serverKey, checkpoint.title);
            updateDoneBlock(YES);
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error updating checkpoint scalar data on server: key=%@, title=%@, error=%@", checkpoint.serverKey, checkpoint.title, error);
        updateDoneBlock(NO);
    }];
    [request startAsynchronous];
}

+ (void)uploadImageForKeyedCheckpoint:(THCheckpoint *)checkpoint
                            withBlock:(THServerConnectionCheckpointImageUploadedBlock)imageUploadedBlock
{
    [self obtainCheckpointUploadURL:checkpoint withBlock:^(NSString *uploadUrlString) {
        if (uploadUrlString != nil) {
            NSURL *url = [NSURL URLWithString:uploadUrlString];
            __weak ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:url];
            [request setData:UIImageJPEGRepresentation(checkpoint.imageClue, 0.8) forKey:@"image_clue"];
            [request setCompletionBlock:^{
                NSError *error;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData]
                                                                     options:kNilOptions
                                                                       error:&error];
                NSNumber *isSuccess = [json objectForKey:@"result"];
                if (isSuccess != nil && [isSuccess boolValue]) {
                    checkpoint.isClueImageSynced = [NSNumber numberWithBool:YES];
                    [THUtils saveContext:_context];
                    NSLog(@"Checkpoint image uploaded for checkpoint: key=%@, title=%@",
                          checkpoint.serverKey, checkpoint.title);
                    imageUploadedBlock(YES);
                }
                else {
                    [request failWithError:[self errorOrNewError:error fromRequest:request]];
                }
            }];
            [request setFailedBlock:^{
                NSError *error = [request error];
                NSLog(@"Error uploading checkpoint image for checkpoint: key=%@, title=%@, error=%@",
                      checkpoint.serverKey, checkpoint.title, error);
                imageUploadedBlock(NO);
            }];
            [request startAsynchronous];
        }
        else {
            imageUploadedBlock(NO);
        }
    }];
}

+ (void)obtainCheckpointUploadURL:(THCheckpoint *)checkpoint
                        withBlock:(THServerConnectionCheckpointUploadUrlObtainedBlock)urlObtainedBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_OBTAIN_CHECKPOINT_UPLOAD_URL_STRING, checkpoint.serverKey]];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData]
                                                             options:kNilOptions
                                                               error:&error];
        NSString *uploadUrl = [json objectForKey:@"upload_url"];
        if (error || uploadUrl == nil) {
            [request failWithError:[self errorOrNewError:error fromRequest:request]];
        }
        else {
            urlObtainedBlock(uploadUrl);
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error obtaining checkpoint upload url from server: key=%@, title=%@, error=%@", checkpoint.serverKey, checkpoint.title, error);
        urlObtainedBlock(nil);
    }];
    [request startAsynchronous];
}

+ (NSError *)errorOrNewError:(NSError*)error fromRequest:(__weak ASIHTTPRequest *)request
{
    if (error == nil) {
        error = [NSError errorWithDomain:@"http status"
                                    code:[request responseStatusCode]
                                userInfo:[NSDictionary dictionaryWithObject:[request responseStatusMessage]
                                                                     forKey:@"message"]];
    }
    return error;
}

@end
