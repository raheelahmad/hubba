//
//  SLCoreDataStackTestsHelper.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/31/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLCoreDataStackTestsHelper.h"
#import "SLCoreDataManager.h"

NSString * const kAttributeNameKey = @"kAttributeNameKey";
NSString * const kAttributeTypeNumKey = @"kAttributeTypeNumKey";
NSString * const kAttributeClassNameKey = @"kAttributeClassNameKey";
NSString * const kRelationshipSourceKey = @"kRelationshipSourceKey";
NSString * const kRelationshipDestinationKey = @"kRelationshipDestinationKey";
NSString * const kRelationshipForwardNameKey = @"kRelationshipForwardNameKey";
NSString * const kRelationshipReverseNameKey = @"kRelationshipReverseNameKey";
NSString * const kRelationshipHasManyNumKey = @"kRelationshipHasManyNumKey";

void setupStackWithEntities(NSArray *entities) {
	[[SLCoreDataManager sharedManager] setManagedObjectContext:nil];
	[[SLCoreDataManager sharedManager] setPersistentStoreCoordinator:nil];
	[[SLCoreDataManager sharedManager] setManagedObjectModel:nil];
	
	NSManagedObjectModel *model;
	if (entities.count > 0) {
		model = [[NSManagedObjectModel alloc] init];
		[model setEntities:entities];
	} else {
		model = [NSManagedObjectModel mergedModelFromBundles:nil];
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

NSEntityDescription *setupEntity(NSString *entityName, Class entityClass, NSArray *attributesInfo, NSArray *relationshipsInfo) {
	NSEntityDescription *entity = [[NSEntityDescription alloc] init];
	entity.name = entityName;
	entity.managedObjectClassName = NSStringFromClass(entityClass);
	NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:attributesInfo.count];
	for (NSDictionary *attributeInfo in attributesInfo) {
		[attributes addObject:attributeDescriptionForName(attributeInfo[kAttributeNameKey], [attributeInfo[kAttributeTypeNumKey] intValue], attributeInfo[kAttributeClassNameKey])];
	}
	entity.properties = attributes;
	
	for (NSDictionary *relationshipInfo in relationshipsInfo) {
		addRelationships(entity, relationshipInfo[kRelationshipDestinationKey],
						 relationshipInfo[kRelationshipForwardNameKey], relationshipInfo[kRelationshipReverseNameKey], [relationshipInfo[kRelationshipHasManyNumKey] boolValue]);
	}
	return entity;
}

NSAttributeDescription *attributeDescriptionForName(NSString *attributeName, NSAttributeType attributeType, NSString *attributeClassName) {
	NSAttributeDescription *description = [[NSAttributeDescription alloc] init];
	description.name = attributeName;
	description.attributeType = attributeType; description.attributeValueClassName = attributeClassName;
	return description;
}

void addRelationships(NSEntityDescription *source, NSEntityDescription *destination,
														  NSString *forwardName, NSString *reverseName, BOOL toMany) {
	NSRelationshipDescription *forwardDescription = [[NSRelationshipDescription alloc] init];
	forwardDescription.destinationEntity = destination;
	forwardDescription.name = forwardName;
	NSRelationshipDescription *reverseDescription = [[NSRelationshipDescription alloc] init];
	reverseDescription.destinationEntity = source;
	reverseDescription.name = reverseName;
	
	forwardDescription.inverseRelationship = reverseDescription;
	reverseDescription.inverseRelationship = forwardDescription;
	
	NSArray *existingForwardRelationships = source.properties;
	NSMutableArray *newForwardRelationships = [NSMutableArray arrayWithObject:forwardDescription];
	[newForwardRelationships addObjectsFromArray:existingForwardRelationships];
	source.properties = newForwardRelationships;
	
	NSArray *existingReverseRelationships = destination.properties;
	NSMutableArray *newReverseRelationships = [NSMutableArray arrayWithObject:reverseDescription];
	[newReverseRelationships addObjectsFromArray:existingReverseRelationships];
	destination.properties = newReverseRelationships;
	
	// use the toMany BOOL
	if (toMany) {
		forwardDescription.maxCount = -1;
	} else {
		forwardDescription.maxCount = 1;
	}
	reverseDescription.maxCount = 1;
}

