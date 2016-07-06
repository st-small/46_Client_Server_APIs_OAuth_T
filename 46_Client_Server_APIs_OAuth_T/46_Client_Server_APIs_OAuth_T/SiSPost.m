//
//  SiSPost.m
//  46_Client_Server_APIs_OAuth_T
//
//  Created by Stanly Shiyanovskiy on 03.07.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSPost.h"

@implementation SiSPost

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        self.text = [responseObject objectForKey:@"text"];
        self.text = [self.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        
    }
    
    return self;
}


@end
