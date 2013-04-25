//
//  SLRelationMapping.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/30/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLRelationMapping.h"
#import "SLCoreDataManager.h"
#import "SLManagedRemoteObject.h"

@interface SLRelationMapping ()
@property NSMutableSet *updatedObjects;
@end

@implementation SLRelationMapping

#pragma mark - Initialization

- (id)init {
	self = [super init];
	if (self) {
		self.usesDestinationClassRemoteMapping = YES;
		self.shouldRefreshRelationships = NO; // do not refresh relationships of relationships
	}
	return self;
}

- (NSDictionary *)propertyMappings {
	// by default use the property mappings of the destination class
	return [[self.modelClass remoteMapping] propertyMappings];
}

- (NSDictionary *)uniquePropertyMapping {
	return [[self.modelClass remoteMapping] uniquePropertyMapping];
}

- (NSArray *)transformerInfo {
	return [[self.modelClass remoteMapping] transformerInfo];
}

- (void)updateWithRemoteResponse:(id)remoteResponse {
	self.updatedObjects = [NSMutableSet setWithCapacity:4]; // will hold all objects updated by the super call below
	[super updateWithRemoteResponse:remoteResponse];
	NSSet *existingDestinationObjects = [self.sourceObject valueForKeyPath:self.sourceRelationshipKeypath];
	if (existingDestinationObjects) {
		[self.updatedObjects addObjectsFromArray:[existingDestinationObjects allObjects]];
	}
	
	NSRelationshipDescription *relationship = [self relationshipDescription];
	if (relationship) {
		if (relationship.isToMany) {
			[self.sourceObject setValue:self.updatedObjects forKeyPath:self.sourceRelationshipKeypath];
		} else {
			id updatedRelationshipObject = [self.updatedObjects anyObject];
			[self.sourceObject setValue:updatedRelationshipObject forKey:self.sourceRelationshipKeypath];
		}
		
		NSError *error = nil;
		if (![[[SLCoreDataManager sharedManager] managedObjectContext] save:&error]) {
			NSLog(@"Error saving after updating %@ with remote response: %@", NSStringFromClass(self.modelClass), error);
		}
	} else {
		NSLog(@"Error no relation %@ on %@", self.sourceRelationshipKeypath, NSStringFromClass(self.sourceObject.class));
	}
#ifdef LOG_NETWORKING
	NSLog(@"---- Fetched %d objects for %@->%@ relationship to %@", self.updatedObjects.count, self.sourceObject, self.sourceRelationshipKeypath, NSStringFromClass(self.modelClass));
#endif
}

- (void)updateObject:(SLManagedRemoteObject *)object withRemoteInfo:(NSDictionary *)remoteInfo {
	[super updateObject:object withRemoteInfo:remoteInfo];
	[self.updatedObjects addObject:object];
}

#pragma mark - Helpers

- (NSRelationshipDescription *)relationshipDescription {
	__block NSRelationshipDescription *relationshipDescription;
	NSEntityDescription *sourceEntity = [self.sourceObject entity];
	[[sourceEntity relationshipsByName] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([key isEqualToString:self.sourceRelationshipKeypath]) {
			relationshipDescription = obj;
			*stop = YES;
		}
	}];
	return relationshipDescription;
}

@end
