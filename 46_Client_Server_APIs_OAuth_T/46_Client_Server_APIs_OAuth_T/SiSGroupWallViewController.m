//
//  SiSGroupWallViewController.m
//  46_Client_Server_APIs_OAuth_T
//
//  Created by Stanly Shiyanovskiy on 03.07.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSGroupWallViewController.h"
#import "SiSServerManager.h"
#import "SiSPostCell.h"

#import "SiSFriend.h"
#import "SiSPost.h"

@interface SiSGroupWallViewController ()

@property (strong, nonatomic) NSMutableArray* postsArray;

@property (assign, nonatomic) BOOL firstTimeAppear;

@end

@implementation SiSGroupWallViewController

static NSInteger postsInRequest = 20;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postsArray = [NSMutableArray array];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor grayColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Avenir Next" size:23.0], NSFontAttributeName, nil]];
    
    self.firstTimeAppear = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self
                action:@selector(refreshWall)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    UIBarButtonItem* plus = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                             target:self
                             action:@selector(postOnWall:)];
    
    self.navigationItem.rightBarButtonItem = plus;

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
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void) postOnWall: (id) sender {
    
    [[SiSServerManager sharedManager]
     postText:@"Приветики! Проверка 47-го )))"
     onGroupWall:@"92664696"
     onSuccess:^(id result) {
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

- (void) refreshWall {
    
    [[SiSServerManager sharedManager]
     getGroupWall:@"92664696"
     withOffset:0
     andCount:MAX(postsInRequest, [self.postsArray count])
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray removeAllObjects];
         
         [self.postsArray addObjectsFromArray:posts];
         
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@ code = %d", [error localizedDescription], statusCode);
     }];
}

- (void) getPostsFromServer {
    
    [[SiSServerManager sharedManager]
     getGroupWall:@"92664696"
     withOffset:[self.postsArray count]
     andCount:postsInRequest
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray addObjectsFromArray:posts];
         
         NSMutableArray* newPaths = [NSMutableArray array];
         for (NSUInteger i = [self.postsArray count] - [posts count]; i < [self.postsArray count]; i++) {
             
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
    
    return [self.postsArray count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.postsArray count]) {
        
        static NSString* identifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
        }
        
        cell.textLabel.text = @"LOAD MORE";
        cell.imageView.image = nil;
        
        return cell;
        
    } else {
        
        static NSString* identifier = @"PostCell";
        
        SiSPostCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
        SiSPost* post = [self.postsArray objectAtIndex:indexPath.row];
        
        cell.postTextLabel.text = post.text;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.postsArray count]) {
        
        return 44.f;
        
    } else {
        
        SiSPost* post = [self.postsArray objectAtIndex:indexPath.row];
        return [SiSPostCell heightForText:post.text];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [self.postsArray count]) {
        
        [self getPostsFromServer];
    }
    
}

@end
