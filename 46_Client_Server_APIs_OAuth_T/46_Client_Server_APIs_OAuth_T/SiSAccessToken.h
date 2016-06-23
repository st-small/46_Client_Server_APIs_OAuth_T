//
//  SiSAccessToken.h
//  46_Client_Server_APIs_OAuth_T
//
//  Created by Stanly Shiyanovskiy on 16.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SiSAccessToken : NSObject

@property (strong, nonatomic) NSString* token;
@property (strong, nonatomic) NSDate* expirationDate;
@property (strong, nonatomic) NSString* friendID;

@end
