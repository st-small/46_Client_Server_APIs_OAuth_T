//
//  SiSServerManager.h
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SiSFriend;

@interface SiSServerManager : NSObject

@property (strong, nonatomic, readonly) SiSFriend* currentUser;

+ (SiSServerManager*) sharedManager;

- (void) authorizeUser:(void(^)(SiSFriend* user)) completion;

- (void) getFriend:(NSString*) friendID
         onSuccess:(void(^)(SiSFriend* friend)) success
         onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getFriendsWithOffset:(NSInteger) offset
                     andCount:(NSInteger) count
                    onSuccess:(void(^)(NSArray* friends)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


@end
