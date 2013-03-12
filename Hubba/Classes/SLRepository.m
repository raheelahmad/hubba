//
//  SLRepository.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/9/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLRepository.h"
#import "SLCoreDataManager.h"

@implementation SLRepository

@dynamic remoteID;
@dynamic name;
@dynamic remoteDescription;

+ (NSFetchedResultsController *)allObjcetsController {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([SLRepository class])];
	fetchRequest.sortDescriptors = [self sortDescriptors];
//	NSArray *results [[self mainMOC] executeFetchRequest:fetchRequest error:&error];
	NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																						managedObjectContext:[self mainMOC] sectionNameKeyPath:nil cacheName:nil];
	NSError *error;
	if (![resultsController performFetch:&error]) {
		NSLog(@"Error executing fetch request for SLRepository: %@", error);
	}
	
	return resultsController;
}

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES] ];
}

+ (NSDictionary *)remoteToLocalMappings {
	return @{
			   @"id"			: @"remoteID",
			   @"name"			: @"name",
			   @"description"	: @"remoteDescription"
		   };
}

+ (void)parseFromResponse:(id)parsedResponse {
	if ([parsedResponse isKindOfClass:[NSArray class]]) {
		for (id rawRepository in parsedResponse) {
			SLRepository *repository = [SLRepository objectForRemoteResponse:rawRepository];
			[repository updateWithRemoteResponse:rawRepository];
		}
	}
}

- (void)updateWithRemoteResponse:(NSDictionary *)remoteResponse {
	NSDictionary *mappings = [self.class remoteToLocalMappings];
	for (NSString *remoteProperty in [mappings allKeys]) {
		id localProperty = mappings[remoteProperty];
		id remoteValue = remoteResponse[remoteProperty];
		if (remoteValue) {
			id localValue = [self valueForKeyPath:localProperty];
			if (![remoteValue isEqual:localValue]) {
				[self setValue:remoteValue forKeyPath:localProperty];
			}
		}
	}
}

+ (SLRepository *)objectForRemoteResponse:(NSDictionary *)remoteResponse {
	SLRepository *repository = nil;
	NSManagedObjectContext *context = [self mainMOC];
	
	NSNumber *id = remoteResponse[@"id"];
	if (!id) {
		return nil;
	}
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([SLRepository class])];
	request.predicate = [NSPredicate predicateWithFormat:@"remoteID == %@", id];
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:request error:&error];
	if (!result) {
		NSLog(@"Error fetching SLRepository: %@", error);
		return nil;
	}
	if (result.count) {
		repository = result[0];
	} else {
		repository = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SLRepository class]) inManagedObjectContext:context];
		if (![context save:&error]) {
			NSLog(@"Error saving context: %@", error);
			repository = nil;
		}
	}
	
	return repository;
}

+ (NSManagedObjectContext *)mainMOC {
	return [[SLCoreDataManager sharedManager] managedObjectContext];
}

@end
