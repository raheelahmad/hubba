//
//  SLFSQCheckin.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/13/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLFSQCheckin.h"
#import "SLCoreDataManager.h"

@implementation SLFSQCheckin

@dynamic remoteId;
@dynamic venueName;
@dynamic venueCity;

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

+ (id<SLRemoteFetchable>)objectForRemoteInfo:(NSDictionary *)remoteInfo {
	id<SLRemoteFetchable> localObject = nil;
	NSManagedObjectContext *context = [[SLCoreDataManager sharedManager] managedObjectContext];
	
	NSNumber *id = remoteInfo[@"id"];
	if (!id) {
		return nil;
	}
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
	request.predicate = [NSPredicate predicateWithFormat:@"remoteId == %@", id];
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:request error:&error];
	if (!result) {
		NSLog(@"Error fetching SLRepository: %@", error);
		return nil;
	}
	if (result.count) {
		localObject = result[0];
	} else {
		localObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
		if (![context save:&error]) {
			NSLog(@"Error saving context: %@", error);
			localObject = nil;
		}
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
				id<SLRemoteFetchable> localObject = [self objectForRemoteInfo:remoteInfo];
				[localObject updateWithRemoteInfo:remoteInfo];
			}
		}
	} else {
		id<SLRemoteFetchable> localObject = [self objectForRemoteInfo:remoteResponse];
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

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"remoteId" ascending:YES] ];
}

+ (BOOL)appearsAsCollection {
	return YES;
}

+ (NSString *)pathToObject {
	return @"response.recent";
}

+ (NSDictionary *)remoteToLocalMappings {
	return @{
		  @"id" : @"remoteId",
		  @"venue.name" : @"venueName",
		  @"venue.location.city" : @"venueCity"
	};
}
@end
