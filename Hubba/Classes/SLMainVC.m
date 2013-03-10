//
//  SLMainVCViewController.m
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMainVC.h"
#import "SLAPIClient.h"

@interface SLMainVC ()

- (IBAction)initiateLogin:(id)sender;

@property (nonatomic, strong) IBOutlet UIWebView *authWebView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (strong, nonatomic) SLAPIClient *APIClient;

@end


@implementation SLMainVC

#pragma mark - Fetching Data

- (IBAction)fetchRepos:(id)sender {
	[self.APIClient get:@"/user/repos" onCompletion:^(BOOL success, NSString *response) {
		if (success) {
			NSLog(@"Got: %@", response);
		} else {
			NSLog(@"Could not fetch! %@", response);
		}
	}];
}

#pragma mark - Login

- (IBAction)initiateLogin:(id)sender {
	[self.view addSubview:self.authWebView];
	NSLog(@"Authenticated: %d", self.APIClient.authenticated);
	[self.APIClient initiateAuthorizationWithWebView:self.authWebView onCompletion:^(BOOL success) {
		if (success) {
			NSLog(@"Yay! success");
			NSLog(@"Authenticated: %d", self.APIClient.authenticated);
			[self fetchRepos:nil];
		} else {
			NSLog(@"FAIL!!!");
		}
		[self updateUI];
	}];
}

- (IBAction)	logout:(id)sender {
	[self.APIClient resetAuthentication];
	[self updateUI];
}

#pragma mark - UI

- (void)updateUI {
	if (self.APIClient.authenticated) {
		self.loginButton.action = @selector(fetchRepos:);
		[self.loginButton setTitle:NSLocalizedString(@"Fetch Repos", nil)];
		[self.authWebView removeFromSuperview];
	} else {
		self.loginButton.action = @selector(initiateLogin:);
		[self.loginButton setTitle:NSLocalizedString(@"Log In", nil)];
	}
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
	self.authWebView.frame = CGRectMake(10, 48, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame) - 80);
	self.authWebView.layer.borderWidth = 1.0f;
	self.APIClient = [SLAPIClient sharedClientWithAPIName:@"Github" baseURL:@"https://api.github.com"];
	self.loginButton.target = self;
	
	[self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
