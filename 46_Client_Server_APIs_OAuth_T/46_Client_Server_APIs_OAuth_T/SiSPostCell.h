//
//  SiSPostCell.h
//  46_Client_Server_APIs_OAuth_T
//
//  Created by Stanly Shiyanovskiy on 03.07.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiSPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* postTextLabel;

+ (CGFloat) heightForText:(NSString *) text;

@end
