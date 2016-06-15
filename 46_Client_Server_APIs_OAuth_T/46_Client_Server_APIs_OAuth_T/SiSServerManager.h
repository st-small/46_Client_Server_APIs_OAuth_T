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

+ (SiSServerManager*) sharedManager;

- (void) getFriendsWithOffset:(NSInteger) offset
                     andCount:(NSInteger) count
                    onSuccess:(void(^)(NSArray* friends)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getFriendInfoWithId:(NSString*)friendID
                 onSuccess:(void(^)(SiSFriend* friend))success
                 onFailure:(void(^)(NSError *error))failure;

- (void) getFollowersOrSubsriptionsWithMethod:(NSString*) method
                                    ForUserID:(NSString*) friendID
                                   WithOffset:(NSInteger) offset
                                        count:(NSInteger) count
                                    onSuccess:(void(^)(NSArray* objects)) success
                                    onFailure:(void(^)(NSError* error)) failure;

- (void) getWallPostsForUser:(NSString*) friendID
                  withOffset:(NSInteger) offset
                       count:(NSInteger) count
                   onSuccess:(void(^)(NSArray* posts)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
