//
//  SiSFriendsTableViewController.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSFriendsTableViewController.h"
#import "SiSServerManager.h"
#import "UIImageView+AFNetworking.h"

#import "SiSFriend.h"

@interface SiSFriendsTableViewController ()

@property (strong, nonatomic) NSMutableArray* friendsArray;

@property (assign, nonatomic) BOOL firstTimeAppear;

@end

@implementation SiSFriendsTableViewController

static NSInteger friendsInRequest = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Мои друзья:";
    
    self.friendsArray = [NSMutableArray array];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor grayColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Avenir Next" size:23.0], NSFontAttributeName, nil]];
    
    //[self getFriendsFromServer];
    
    self.firstTimeAppear = YES;

}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppear) {
        self.firstTimeAppear = NO;
        
        [[SiSServerManager sharedManager] authorizeUser:^(SiSFriend *friend) {
            NSLog(@"AUTHORIZED!");
            NSLog(@"%@ %@", friend.firstName, friend.lastName);
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - API

- (void) getFriendsFromServer {
    
    [[SiSServerManager sharedManager]
     getFriendsWithOffset:[self.friendsArray count]
     andCount:friendsInRequest
     onSuccess:^(NSArray *friends) {
         
         [self.friendsArray addObjectsFromArray:friends];
         
         NSMutableArray* newPaths = [NSMutableArray array];
         for (NSUInteger i = [self.friendsArray count] - [friends count]; i < [self.friendsArray count]; i++) {
             
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         
         [self.tableView beginUpdates];
         [self.tableView insertRowsAtIndexPaths:newPaths
                               withRowAnimation:UITableViewRowAnimationTop];
         [self.tableView endUpdates];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@ code = %d", [error localizedDescription], statusCode);
     }];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.friendsArray count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    if (indexPath.row == [self.friendsArray count]) {
        
        cell.textLabel.text = @"LOAD MORE";
        cell.imageView.image = nil;
        
    } else {
        
        // Заполняем ячейки друзьями из словаря
        
        SiSFriend* friend = [self.friendsArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
        
        // Добавим картинку к каждой строке
        
        NSURLRequest* request = [NSURLRequest requestWithURL:friend.image100URL
                                                 cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                             timeoutInterval:60];
        
        __weak UITableViewCell* weakCell = cell;
        
        cell.imageView.image = nil;
        
        [cell.imageView setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"preview.png"]
                                       success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
                                           
                                           [UIView transitionWithView:weakCell.imageView
                                                             duration:0.3f
                                                              options:UIViewAnimationOptionTransitionCrossDissolve
                                                           animations:^{
                                                               weakCell.imageView.image = image;
                                                               
                                                               CALayer* imageLayer = weakCell.imageView.layer;
                                                               [imageLayer setCornerRadius:imageLayer.frame.size.width/2];
                                                               [imageLayer setMasksToBounds:YES];
                                                               
                                                           } completion:NULL];
                                           
                                       } failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error) {
                                           NSLog(@"Something bad...");
                                       }];
        
    }
    
    
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [self.friendsArray count]) {
        [self getFriendsFromServer];
    }
    
}



@end
