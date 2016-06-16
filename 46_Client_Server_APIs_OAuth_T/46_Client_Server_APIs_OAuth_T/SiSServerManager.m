//
//  SiSServerManager.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSServerManager.h"
#import "AFNetworking.h"
#import "SiSFriend.h"
#import "SiSLoginViewController.h"
#import "SiSAccessToken.h"

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

- (instancetype)init
{
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
        
        if (completion) {
            completion(nil);
        }
    }];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nav
                         animated:YES
                       completion:nil];
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


@end
