//
//  SiSLoginViewController.m
//  46_Client_Server_APIs_OAuth_T
//
//  Created by Stanly Shiyanovskiy on 16.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSLoginViewController.h"
#import "SiSAccessToken.h"

@interface SiSLoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) SiSLoginCompletionBlock completionBlock;
@property (weak, nonatomic) UIWebView* webView;

@end

@implementation SiSLoginViewController

- (id) initWithCompletionBlock:(SiSLoginCompletionBlock) completionBlock {
    
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    r.origin = CGPointZero;
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:r];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    
    self.webView = webView;
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    
    self.navigationItem.title = @"Login";
    
    NSString* urlString = @"https://oauth.vk.com/authorize?"
                           "client_id=5508572&"
                           "display=mobile&"
                           "redirect_uri=https://oauth.vk.com/blank.html&"
                           "scope=139286&"
                           "response_type=token&"
                           "revoke=1&"
                           "v=5.52";
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    webView.delegate =self;
    
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    
    self.webView.delegate = nil;
}

#pragma mark - Actions

- (void) actionCancel:(UIBarButtonItem*) sender {
    
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"%@", [request URL]);
    
    return YES;
}




@end
