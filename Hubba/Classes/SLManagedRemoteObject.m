//
//  SLRemoteManagedObject.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/15/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLManagedRemoteObject.h"
#import "SLCoreDataManager.h"
#import "SLAPIClient.h"

@implementation SLManagedRemoteObject

+ (void)refresh {
	[[SLAPIClient sharedClient] get:[self remoteMapping].endPoint onCompletion:^(BOOL success, id response) {
		if (success) {
			NSLog(@"Fetched for: %@", NSStringFromClass([self class]));
			[self updateWithRemoteResponse:response];
		} else {
			NSLog(@"Could not fetch! %@", response);
		}
	}];
}

+ (NSFetchedResultsController *)allObjcetsController {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
	fetchRequest.sortDescriptors = [self sortDescriptors];
	NSManagedObjectContext *context = [[SLCoreDataManager sharedManager] managedObjectContext];
	NSFetchedResultsController *fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
	NSError *error;
	if (![fetchController performFetch:&error]) {
		NSLog(@"Error fetching %@: %@", NSStringFromClass([self class]), error);
	}
	
	return fetchController;
}

+ (void)updateWithRemoteResponse:(id)remoteResponse {
	[[self remoteMapping] updateWithRemoteResponse:remoteResponse];
}

#pragma mark - For the subclass

+ (SLMapping *)remoteMapping {
	return nil;
}

+ (NSArray *)relationshipMappings {
	return nil;
}

+ (NSArray *)sortDescriptors {
	return nil;
}

@end
