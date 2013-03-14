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
#import "SLCoreDataManager.h"

NSString * const kServiceName = @"Foursquare";
NSString * const kServiceBaseURL = @"https://api.foursquare.com/v2";

@interface SLMainVC ()

- (IBAction)initiateLogin:(id)sender;

@property (nonatomic, strong) IBOutlet UIWebView *authWebView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *fetchButton;
@property (strong, nonatomic) SLAPIClient *APIClient;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *repositoriesResultsController;

@end


@implementation SLMainVC

#pragma mark - Fetching Data

- (IBAction)fetchFromRemote:(id)sender {
	[self.APIClient get:@"/user/repos" onCompletion:^(BOOL success, id response) {
		if (success) {
			[SLRepository parseFromResponse:response];
			[self.tableView reloadData];
		} else {
			NSLog(@"Could not fetch! %@", response);
		}
	}];
}

- (NSFetchedResultsController *)repositoriesResultsController {
	if (!_repositoriesResultsController) {
		_repositoriesResultsController = [SLRepository allObjcetsController];
		_repositoriesResultsController.delegate = self;
	}
	return _repositoriesResultsController;
}

#pragma mark - NSFetchedResultsController delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		default:
			break;
	}
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	switch (type) {
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
			[self configureCell:[self.tableView cellForRowAtIndexPath:newIndexPath] atIndexPath:newIndexPath];
			break;
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
			[self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			
		default:
			break;
	}
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
}

#pragma mark - UITableView delegate + data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"Repository Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
	}
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.repositoriesResultsController sections];
	return [[sections objectAtIndex:section] numberOfObjects];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	SLRepository *repository = [self.repositoriesResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = repository.name;
	cell.detailTextLabel.text = repository.remoteDescription;
}


#pragma mark - Login

- (IBAction)initiateLogin:(id)sender {
	self.APIClient = [[SLAPIClient alloc] initWithAPIName:kServiceName baseURL:kServiceBaseURL];
	[self.view addSubview:self.authWebView];
	NSLog(@"Current: %@", self.authWebView.request.URL);
	[self.APIClient initiateAuthorizationWithWebView:self.authWebView onCompletion:^(BOOL success) {
		if (success) {
			NSLog(@"Yay! success");
			NSLog(@"Authenticated: %d", self.APIClient.authenticated);
			[self fetchFromRemote:nil];
		} else {
			NSLog(@"FAIL!!!");
		}
		[self.authWebView removeFromSuperview];
		self.authWebView = nil;
		[[NSURLCache sharedURLCache] removeAllCachedResponses];
		[self updateUI];
	}];
}

- (IBAction)logout:(id)sender {
	[[SLCoreDataManager sharedManager] resetCoreDataStack];
	[self.APIClient resetAuthentication];
//	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[self updateUI];
	self.repositoriesResultsController.delegate = nil;
	self.repositoriesResultsController = nil;
	[self.tableView reloadData];
}

#pragma mark - UI

- (void)updateUI {
	if (self.APIClient.authenticated) {
		self.loginButton.action = @selector(logout:);
		[self.loginButton setTitle:NSLocalizedString(@"Logout", nil)];
		self.navigationItem.leftBarButtonItem = self.fetchButton;
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
		self.title = kServiceName;
    }
    return self;
}

- (UIWebView *)authWebView {
	if (!_authWebView) {
		_authWebView = [[UIWebView alloc] init];
		_authWebView.frame = CGRectMake(10, 48, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame) - 80);
		_authWebView.layer.borderWidth = 1.0f;
	}
	
	return _authWebView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.APIClient = [[SLAPIClient alloc] initWithAPIName:@"Github" baseURL:@"https://api.github.com"];
	self.loginButton.target = self;
	self.fetchButton.target = self;
	self.fetchButton.action = @selector(fetchFromRemote:);
	
	[self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
