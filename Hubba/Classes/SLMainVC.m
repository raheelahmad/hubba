//
//  SLMainVCViewController.m
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMainVC.h"
#import "SLAPIClient.h"
#import "SLFSQCheckin.h"
#import "SLCoreDataManager.h"

#import "SLRepository.h"
#import "SLUser.h"
#import "SLMe.h"
#import "SLOrganization.h"

@interface SLMainVC ()

- (IBAction)initiateLogin:(id)sender;

@property (nonatomic, strong) IBOutlet UIWebView *authWebView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *repositoriesResultsController;

@end


@implementation SLMainVC

#pragma mark - Fetching Data

- (void)refresh {
	if ([SLAPIClient sharedClient].authenticated) {
		[SLMe refresh];
		NSArray *repositories = [[[SLCoreDataManager sharedManager] managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([SLRepository class])]
																				error:nil];
		for (SLRepository *repo in repositories) {
			NSLog(@"Repo: %@", repo);
		}
	}
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
	if (repository.owner.login) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"Owner: %@", repository.owner.login];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 64.0f;
}

#pragma mark - Login

- (IBAction)initiateLogin:(id)sender {
	[self.view addSubview:self.authWebView];
	[[SLAPIClient sharedClient] initiateAuthorizationWithWebView:self.authWebView onCompletion:^(BOOL success) {
		if (success) {
			[self refresh];
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
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([SLMe class])];
	NSArray *mes = [[[SLCoreDataManager sharedManager] managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	SLMe *me = [mes lastObject];
	SLUser *user = me.user;
	NSLog(@"Me: %@", me);
	NSLog(@"Me user: %@", user);
	
	[[SLCoreDataManager sharedManager] resetCoreDataStack];
	[[SLAPIClient sharedClient] resetAuthentication];
	[self updateUI];
	self.repositoriesResultsController.delegate = nil;
	self.repositoriesResultsController = nil;
	[self.tableView reloadData];
}

#pragma mark - UI

- (void)showUser {
	
}

- (void)updateUI {
	if ([SLAPIClient sharedClient].authenticated) {
		self.loginButton.action = @selector(logout:);
		[self.loginButton setTitle:NSLocalizedString(@"Logout", nil)];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showUser)];
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
	self.title = [[SLAPIClient sharedClient] APIName];
	self.loginButton.target = self;
	
	[self refresh];
	[self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
