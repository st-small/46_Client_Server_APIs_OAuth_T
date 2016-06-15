//
//  SiSFriend.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSFriend.h"

@implementation SiSFriend

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        self.friendID = [responseObject objectForKey:@"user_id"];
        
        NSString* urlString50 = [responseObject objectForKey:@"photo_50"];
        
        if (urlString50) {
            
            self.image50URL = [NSURL URLWithString:urlString50];
        }
        
        NSString* urlString100 = [responseObject objectForKey:@"photo_100"];
        
        if (urlString100) {
            
            self.image100URL = [NSURL URLWithString:urlString100];
        }

        
        NSString* urlString200 = [responseObject objectForKey:@"photo_200"];
        
        if (urlString200) {
            
            self.image200URL = [NSURL URLWithString:urlString200];
        }
        
        self.isOnline = [[responseObject objectForKey:@"online"]boolValue];
        
        self.city = [responseObject objectForKey:@"city"];
        self.country = [responseObject objectForKey:@"country"];
        
        NSString* bday = [responseObject objectForKey:@"bdate"];
        self.dateOfBirth = [self convertDate:bday];
        self.uid = [responseObject objectForKey:@"uid"];
        
    }
    return self;
}

- (NSString*) convertDate:(NSString*) rawStringDate {
    
    NSArray* partsOfDate = [rawStringDate componentsSeparatedByString:@"."];
    
    if ([partsOfDate count] == 2) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d.M"];
        
        NSDate* dateTemp = [dateFormatter dateFromString:rawStringDate];
        
        NSDateFormatter* finalDateFormatter = [[NSDateFormatter alloc] init];
        [finalDateFormatter setDateFormat:@"dd MMMM"];
        
        NSString* finalDateString = [finalDateFormatter stringFromDate:dateTemp];
        
        return finalDateString;
        
        
        
    } else if ([partsOfDate count] == 3) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d.M.yyyy"];
        
        NSDate* dateTemp = [dateFormatter dateFromString:rawStringDate];
        
        NSDateFormatter* finalDateFormatter = [[NSDateFormatter alloc] init];
        [finalDateFormatter setDateFormat:@"dd MMMM yyyy"];
        
        NSString* finalDateString = [finalDateFormatter stringFromDate:dateTemp];
        
        return finalDateString;
        
    }
    
    
    return nil;
}


@end
