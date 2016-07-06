//
//  SiSServerManager.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSServerManager.h"
#import "AFNetworking.h"
#import "SiSLoginViewController.h"
#import "SiSAccessToken.h"

#import "SiSFriend.h"
#import "SiSPost.h"

@interface SiSServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager* sessionManager;
@property (strong, nonatomic) SiSAccessToken* accessToken;

@end

@implementation SiSServerManager

+ (SiSServerManager*) sharedManager {
    
    static SiSServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[SiSServerManager alloc] init];
        
    });
    
    return manager;
}

- (id)init {
    
    self = [super init];
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    
    return self;
}

- (void) authorizeUser:(void(^)(SiSFriend* user)) completion {
    
    SiSLoginViewController* vc = [[SiSLoginViewController alloc] initWithCompletionBlock:^(SiSAccessToken *token) {
        
        self.accessToken = token;
        
        if (token) {
            
            [self getFriend:self.accessToken.friendID
                onSuccess:^(SiSFriend* friend) {
                    if (completion) {
                        completion(friend);
                    }
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    if (completion) {
                        completion(nil);
                    }
                }];
            
        } else if (completion) {
            completion(nil);
        }
        
    }];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nav
                         animated:YES
                       completion:nil];
}

- (void) getFriend:(NSString*) friendID
       onSuccess:(void(^)(SiSFriend* friend)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     friendID,          @"user_ids",
     @"photo_100",       @"fields",
     @"nom",            @"name_case", nil];
    
    [self.sessionManager
     GET:@"users.get"
     parameters:params
     progress: nil
     success:^(NSURLSessionDataTask* operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         if ([dictsArray count] > 0) {
             SiSFriend* friend = [[SiSFriend alloc] initWithServerResponse:[dictsArray firstObject]];
             if (success) {
                 success(friend);
             }
             
         } else {
             
             if (failure) {
                 failure(nil, operation.error.code);
             }
         }
         
     } failure:^(NSURLSessionDataTask *operation, NSError *error) {
         
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.error.code);
         }
     }];
}

- (void) getFriendsWithOffset:(NSInteger) offset
                     andCount:(NSInteger) count
                    onSuccess:(void(^)(NSArray* friends)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"4418798",     @"user_id",
                            @"ru",          @"lang",
                            @"name",        @"order",
                            @(count),       @"count",
                            @(offset),      @"offset",
                            @"photo_50,"
                            "photo_100,"
                            "photo_200,"
                            "online",       @"fields",
                            @"nom",         @"name_case", nil];
    
    [self.sessionManager GET:@"friends.get"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask* task, NSDictionary* responseObject) {
                         //NSLog(@"JSON: %@", responseObject);
                         
                         NSArray* friendsArray = [responseObject objectForKey:@"response"];
                         
                         NSMutableArray* objectsArray = [NSMutableArray array];
                         
                         for (NSDictionary* dict in friendsArray) {
                             
                             SiSFriend* friend = [[SiSFriend alloc] initWithServerResponse:dict];
                             
                             [objectsArray addObject:friend];
                         }
                         
                         if (success) {
                             success(objectsArray);
                         }
                         
                     } failure:^(NSURLSessionTask* task, NSError* error) {
                         NSLog(@"Error: %@", error);
                         
                         if (failure) {
                             failure(error, task.error.code);
                         }
                     }];
    
}

- (void) getGroupWall:(NSString*) groupID
           withOffset:(NSInteger) offset
             andCount:(NSInteger) count
            onSuccess:(void(^)(NSArray* posts)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            groupID,        @"owner_id",
                            @"ru",          @"lang",
                            @(count),       @"count",
                            @(offset),      @"offset",
                            @"all",         @"filter", nil];
    
    [self.sessionManager GET:@"wall.get"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask* task, NSDictionary* responseObject) {
                         NSLog(@"JSON: %@", responseObject);
                         
                         NSArray* dictsArray = [responseObject objectForKey:@"response"];
                         
                         if ([dictsArray count] > 1) {
                             dictsArray = [dictsArray subarrayWithRange:NSMakeRange(1, [dictsArray count] - 1)];
                             
                         } else {
                             
                             dictsArray = nil;
                         }
                         
                         NSMutableArray* objectsArray = [NSMutableArray array];
                         
                         for (NSDictionary* dict in dictsArray) {
                             
                             SiSPost* post = [[SiSPost alloc] initWithServerResponse:dict];
                             
                             [objectsArray addObject:post];
                         }
                         
                         if (success) {
                             success(objectsArray);
                         }
                         
                     } failure:^(NSURLSessionTask* task, NSError* error) {
                         NSLog(@"Error: %@", error);
                         
                         if (failure) {
                             failure(error, task.error.code);
                         }
                     }];

    
    
}

- (void) postText:(NSString*) text
      onGroupWall:(NSString*) groupID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            groupID,                @"owner_id",
                            @"ru",                  @"lang",
                            text,                   @"message",
                            self.accessToken.token, @"access_token", nil];
    
    [self.sessionManager POST:@"wall.post"
                   parameters:params
                     progress:nil
                      success:^(NSURLSessionDataTask* task, NSDictionary* responseObject) {
                         NSLog(@"JSON: %@", responseObject);
                          
                          if (success) {
                             success(responseObject);
                         }
                         
                     } failure:^(NSURLSessionTask* task, NSError* error) {
                         NSLog(@"Error: %@", error);
                         
                         if (failure) {
                             failure(error, task.error.code);
                         }
                     }];
    
}

@end
