//
//  SiSLoginViewController.h
//  46_Client_Server_APIs_OAuth_T
//
//  Created by Stanly Shiyanovskiy on 16.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SiSAccessToken;

typedef void(^SiSLoginCompletionBlock)(SiSAccessToken* token);

@interface SiSLoginViewController : UIViewController

- (id) initWithCompletionBlock:(SiSLoginCompletionBlock) completionBlock;

@end
