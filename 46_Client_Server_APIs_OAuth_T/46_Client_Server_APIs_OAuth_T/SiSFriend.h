//
//  SiSFriend.h
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSServerObject.h"

@interface SiSFriend : SiSServerObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSURL* image50URL;
@property (strong, nonatomic) NSURL* image100URL;
@property (strong, nonatomic) NSURL* image200URL;
@property (strong, nonatomic) NSString* friendID;
@property (strong, nonatomic) NSString* uid;
@property (assign, nonatomic) BOOL isOnline;
@property (strong, nonatomic) NSString* city;
@property (strong, nonatomic) NSString* country;
@property (strong, nonatomic) NSString* dateOfBirth;

@end
