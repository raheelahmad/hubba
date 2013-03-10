//
//  SLMainVCViewController.m
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMainVC.h"
#import "SLAPIClient.h"
#import "SLRepository.h"

@interface SLMainVC ()

- (IBAction)initiateLogin:(id)sender;

@property (nonatomic, strong) IBOutlet UIWebView *authWebView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *fetchReposButton;
@property (strong, nonatomic) SLAPIClient *APIClient;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *repositoriesResultsController;

@end


@implementation SLMainVC

#pragma mark - Fetching Data

- (IBAction)fetchRepos:(id)sender {
	[self.APIClient get:@"/user/repos" onCompletion:^(BOOL success, id response) {
		if (success) {
			[self parseRepositories:response];
			[self.tableView reloadData];
		} else {
			NSLog(@"Could not fetch! %@", response);
		}
	}];
}

- (void)parseRepositories:(id)parsedResponse {
	if ([parsedResponse isKindOfClass:[NSArray class]]) {
		for (id rawRepository in parsedResponse) {
			SLRepository *repository = [SLRepository objectForRemoteResponse:rawRepository];
			[repository updateWithRemoteResponse:rawRepository];
		}
	}
}

#pragma mark - UITableView delegate + data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"Repository Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId forIndexPath:indexPath];
//	cell.textLabel
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
		self.loginButton.action = @selector(logout:);
		[self.loginButton setTitle:NSLocalizedString(@"Logout", nil)];
		self.navigationItem.leftBarButtonItem = self.fetchReposButton;
		[self.authWebView removeFromSuperview];
	} else {
		self.loginButton.action = @selector(initiateLogin:);
		[self.loginButton setTitle:NSLocalizedString(@"Log In", nil)];
		self.navigationItem.leftBarButtonItem = nil;
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
	self.fetchReposButton.target = self;
	self.fetchReposButton.action = @selector(fetchRepos:);
	
	[self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
