//
//  SLMainVCViewController.m
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMainVC.h"
#import "SLOAuth2Client.h"

@interface SLMainVC ()

- (IBAction)initiateLogin:(id)sender;

@property (nonatomic, strong) IBOutlet UIWebView *authWebView;

@end


@implementation SLMainVC

#pragma mark - Login

- (IBAction)initiateLogin:(id)sender {
	[self.view addSubview:self.authWebView];
	[[SLOAuth2Client sharedClientWithAPIName:@"Github"] initiateAuthorizationWithWebView:self.authWebView];
}

#pragma mark - View Controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.authWebView.frame = CGRectMake(10, 40, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame) - 80);
	self.authWebView.layer.borderWidth = 1.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
