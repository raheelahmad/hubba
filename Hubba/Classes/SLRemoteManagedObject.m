//
//  SLRemoteManagedObject.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/15/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLRemoteManagedObject.h"
#import "SLCoreDataManager.h"

@implementation SLRemoteManagedObject

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

+ (SLRemoteManagedObject *)objectForRemoteInfo:(NSDictionary *)remoteInfo {
	SLRemoteManagedObject * localObject = nil;
	NSManagedObjectContext *context = [[SLCoreDataManager sharedManager] managedObjectContext];
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
	request.predicate = [self localPredicateForRemoteObject:remoteInfo];
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:request error:&error];
	if (!result) {
		NSLog(@"Error fetching %@: %@", NSStringFromClass([self class]),	error);
		return nil;
	}
	if (result.count) {
		localObject = result[0];
	} else {
		localObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
	}
	
	return localObject;
}

+ (void)updateWithRemoteResponse:(id)remoteResponse {
	// if nested, let's access the branch
	if ([self pathToObject]) {
		remoteResponse = [remoteResponse valueForKeyPath:[self pathToObject]];
	}
	if ([self appearsAsCollection]) {
		if ([remoteResponse isKindOfClass:[NSArray class]]) {
			for (NSDictionary *remoteInfo in remoteResponse) {
				SLRemoteManagedObject *localObject = [self objectForRemoteInfo:remoteInfo];
				[localObject updateWithRemoteInfo:remoteInfo];
			}
		}
	} else {
		SLRemoteManagedObject *localObject = [self objectForRemoteInfo:remoteResponse];
		[localObject updateWithRemoteInfo:remoteResponse];
	}
	
	NSError *error;
	if (![[[SLCoreDataManager sharedManager] managedObjectContext] save:&error]) {
		NSLog(@"Error saving after updating %@ with remote response: %@", NSStringFromClass([self class]), error);
	}
}

- (void)updateWithRemoteInfo:(NSDictionary *)remoteInfo {
	NSDictionary *mapping = [self.class remoteToLocalMappings];
	
	for (NSString *remotePropery in [mapping allKeys]) {
		NSString *localPropertyPath = mapping[remotePropery];
		id remoteValue = [remoteInfo valueForKeyPath:remotePropery];
		if (remoteValue) {
			id localValue = [self valueForKeyPath:localPropertyPath];
			if (![remoteValue isEqual:localValue]) {
				[self setValue:remoteValue forKey:localPropertyPath];
			}
		}
	}
}

#pragma mark - For the subclass

+ (NSDictionary *)remoteToLocalMappings {
	return nil;
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return nil;
}

+ (NSArray *)sortDescriptors {
	return nil;
}

+ (BOOL)appearsAsCollection {
	return NO;
}

+ (NSString *)pathToObject {
	return nil;
}

@end
