//
//  SiSFriendsTableViewController.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSFriendsTableViewController.h"
#import "SiSServerManager.h"
#import "SiSFriend.h"
#import "UIImageView+AFNetworking.h"
#import "SiSFriendDetails.h"
#import "SiSDefaultFrinedCell.h"
#import "UIImageView+Haneke.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SiSFriendsTableViewController ()

@property (strong, nonatomic) NSMutableArray* friendsArray;
@property (assign, nonatomic) BOOL loadingData;

@end

@implementation SiSFriendsTableViewController

static NSInteger friendsInRequest = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Мои друзья:";
    
    self.friendsArray = [NSMutableArray array];
    
    self.loadingData = YES;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor grayColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Avenir Next" size:23.0], NSFontAttributeName, nil]];
    
    [self getFriendsFromServer];

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
         
         self.loadingData = NO;
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@ code = %d", [error localizedDescription], statusCode);
     }];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.friendsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    SiSDefaultFrinedCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[SiSDefaultFrinedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    // Заполняем ячейки друзьями из словаря
    
    SiSFriend* friend = [self.friendsArray objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
    
    NSString* onlineStatusText;
    UIColor* onlineStatusColor;
    
    if (friend.isOnline) {
        onlineStatusText = @"Доступен";
        onlineStatusColor = [UIColor colorWithRed:10.0f/255.0f green:142.0f/255.0f blue:78.0/255.0f alpha:1.0];
    } else {
        onlineStatusText = @"Отсутствует";
        onlineStatusColor = [UIColor redColor];
    }
    
    cell.isOnline.text = onlineStatusText;
    cell.isOnline.textColor = onlineStatusColor;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Добавим картинку к каждой строке
    
    // Попытка кеширования с помощью SDWebImage
    
//    __block UIActivityIndicatorView *activityIndicator;
//    __weak SiSDefaultFrinedCell* weakCell = cell;
//    
//    [cell.imageView sd_setImageWithURL:friend.image50URL
//                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]
//                               options:SDWebImageCacheMemoryOnly
//                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                  if (!activityIndicator) {
//                                      [weakCell.imageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
//                                      activityIndicator.center = weakCell.imageView.center;
//                                      [activityIndicator startAnimating];
//                                  }
//                              }
//                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                 [activityIndicator removeFromSuperview];
//                                 activityIndicator = nil;
//                             }];
//    return cell;
//

//    // Попытка кеширования с помощью Haneke
//    
//    cell.imageView.image = nil;
//    
//    HNKCacheFormat *format = [HNKCache sharedCache].formats[@"origin"];
//    if (!format) {
//        format = [[HNKCacheFormat alloc] initWithName:@"origin"];
//        format.size = CGSizeMake(100, 100);
//        format.scaleMode = HNKScaleModeAspectFill;
//        format.compressionQuality = 0.5;
//        format.diskCapacity = 10 * 1024 * 1024; // 10MB
//        format.preloadPolicy = HNKPreloadPolicyLastSession;
//    }
//    
//    cell.imageView.hnk_cacheFormat = format;
//   
//    [cell.imageView hnk_setImageFromURL:friend.image100URL];
//    
//    return cell;
    
    // Попытка кеширования с помощью AFNetworking
    
    NSURLRequest* request = [NSURLRequest requestWithURL:friend.image100URL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:60];
    
    __weak SiSDefaultFrinedCell* weakCell = cell;
    
    cell.photoView.image = nil;
    
    [cell.photoView setImageWithURLRequest:request
                          placeholderImage:[UIImage imageNamed:@"preview.png"]
                                   success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
                                       
                                       [UIView transitionWithView:weakCell.photoView
                                                         duration:0.3f
                                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                                       animations:^{
                                                           weakCell.photoView.image = image;
                                                           
                                                           CALayer* imageLayer = weakCell.photoView.layer;
                                                           [imageLayer setCornerRadius:imageLayer.frame.size.width/2];
                                                           [imageLayer setMasksToBounds:YES];
                                                           
                                                       } completion:NULL];
                                     
                                   } failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error) {
                                       NSLog(@"Something bad...");
                                   }];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getFriendsFromServer];
        }
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    SiSFriend* friend = [self.friendsArray objectAtIndex:indexPath.row];
//    SiSFriendDetails* vc = [[SiSFriendDetails alloc] init];
//    [vc setFriendID:friend.friendID];
//    [self.navigationController pushViewController:vc animated:YES];
//    
//}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"FriendDetails"]) {
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForCell:sender];
        SiSFriend* friend = [self.friendsArray objectAtIndex:selectedIndexPath.row];
        
        SiSFriendDetails* vc = [segue destinationViewController];
        vc.friend = friend;
        vc.friendID = friend.friendID;
        
    }
}


@end
