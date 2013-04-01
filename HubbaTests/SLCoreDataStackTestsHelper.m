//
//  SLCoreDataStackTestsHelper.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/31/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLCoreDataStackTestsHelper.h"
#import "SLCoreDataManager.h"

void setupStackWithEntities(NSArray *entities) {
	[[SLCoreDataManager sharedManager] setManagedObjectContext:nil];
	[[SLCoreDataManager sharedManager] setPersistentStoreCoordinator:nil];
	[[SLCoreDataManager sharedManager] setManagedObjectModel:nil];
	
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
	if (entities.count > 0) {
		[model setEntities:entities];
	}
	
	NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	[coordinator addPersistentStoreWithType:NSInMemoryStoreType
							  configuration:nil
										URL:nil
									options:nil
									  error:NULL];
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[context setPersistentStoreCoordinator:coordinator];
	[[SLCoreDataManager sharedManager] setManagedObjectModel:model];
	[[SLCoreDataManager sharedManager] setPersistentStoreCoordinator:coordinator];
	[[SLCoreDataManager sharedManager] setManagedObjectContext:context];
}
