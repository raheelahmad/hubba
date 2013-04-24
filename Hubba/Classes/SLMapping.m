//
//  SLMapping.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/30/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMapping.h"
#import "SLManagedRemoteObject.h"
#import "SLCoreDataManager.h"

NSString * const kLocalUniquePropertyKey = @"kLocalUniquePropertyKey";
NSString * const kRemoteUniquePropertyKey = @"kRemoteUniquePropertyKey";

@implementation SLMapping

- (id)init {
	self = [super init];
	if (self) {
		self.shouldRefreshRelationships = YES;
	}
	
	return self;
}

- (SLManagedRemoteObject *)objectForRemoteInfo:(NSDictionary *)remoteInfo {
	SLManagedRemoteObject * localObject = nil;
	NSManagedObjectContext *context = [[SLCoreDataManager sharedManager] managedObjectContext];
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self.modelClass)];
	request.predicate = [self localPredicateForRemoteObject:remoteInfo];
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:request error:&error];
	if (!result) {
		NSLog(@"Error fetching %@: %@", NSStringFromClass(self.modelClass),	error);
		return nil;
	}
	if (result.count) {
		localObject = result[0];
	} else {
		localObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.modelClass) inManagedObjectContext:context];
		// also set the unique property value for the fresh object
		NSString *remoteUniqueProperty = self.uniquePropertyMapping[kRemoteUniquePropertyKey];
		NSString *localUniqueProperty = self.uniquePropertyMapping[kLocalUniquePropertyKey];
		id remoteUniqueValue = remoteInfo[remoteUniqueProperty];
		[localObject setValue:remoteUniqueValue forKey:localUniqueProperty];
	}
	
	return localObject;
}

- (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObjectInfo {
	NSString *localProperty = self.uniquePropertyMapping[kLocalUniquePropertyKey];
	id remoteValue = [remoteObjectInfo valueForKey:self.uniquePropertyMapping[kRemoteUniquePropertyKey]];
	
	return [NSPredicate predicateWithFormat:@"%K == %@", localProperty, remoteValue];
}

- (void)updateWithRemoteResponse:(id)remoteResponse {
	NSMutableArray *updatedObjects = [NSMutableArray arrayWithCapacity:4];
	// if nested, let's access the branch
	if (self.pathToObject) {
		remoteResponse = [remoteResponse valueForKeyPath:self.pathToObject];
	}
	if (self.appearsAsCollection) {
		if ([remoteResponse isKindOfClass:[NSArray class]]) {
			for (NSDictionary *remoteInfo in remoteResponse) {
				SLManagedRemoteObject *localObject = [self objectForRemoteInfo:remoteInfo];
				[self updateObject:localObject withRemoteInfo:remoteInfo];
				[updatedObjects addObject:localObject];
				if (self.shouldRefreshRelationships) {
					[localObject refreshRelationships];
				}
			}
		}
	} else {
		SLManagedRemoteObject *localObject = [self objectForRemoteInfo:remoteResponse];
		[self updateObject:localObject withRemoteInfo:remoteResponse];
		[updatedObjects addObject:localObject];
		if (self.shouldRefreshRelationships) {
			[localObject refreshRelationships];
		}
	}
	
	NSError *error = nil;
	if (![[[SLCoreDataManager sharedManager] managedObjectContext] save:&error]) {
		NSLog(@"Error saving after updating %@ with remote response: %@", NSStringFromClass(self.modelClass), error);
	}
	
	if ([self isKindOfClass:[SLRelationMapping class]]) {
		SLRelationMapping *mapping = (SLRelationMapping *)self;
		for (id object in updatedObjects) {
			NSLog(@"Fetched: %@ for %@", object, [mapping sourceRelationshipKeypath]);
		}
	}
	
	if (self.afterRemoteUpdate) {
		self.afterRemoteUpdate(updatedObjects);
	}
}

- (void)updateObject:(SLManagedRemoteObject *)object withRemoteInfo:(NSDictionary *)remoteInfo {
	SLMapping *mapping = [self.modelClass remoteMapping];
	NSDictionary *mappingDictioanry = mapping.propertyMappings;
	for (NSString *localPropertyPath in [mappingDictioanry allKeys]) {
		NSString *remotePropery = mappingDictioanry[localPropertyPath];
		id remoteValue = [remoteInfo valueForKeyPath:remotePropery];
		if (remoteValue) {
			NSArray *localPropertyPathArray = [localPropertyPath componentsSeparatedByString:@"."];
			SLManagedRemoteObject *receiver = object; // in the loop, the object on which to do valueForKey:
			for (NSString *key in localPropertyPathArray) {
				// this property's description in the model
				id entityProperty = [self entityPropertyForPropertyName:key];
				if ([entityProperty isKindOfClass:[NSRelationshipDescription class]]) {
					// if the key is a relationship
					NSRelationshipDescription *relationshipDescription = (NSRelationshipDescription *)entityProperty;
					Class destinationClass = NSClassFromString(relationshipDescription.destinationEntity.managedObjectClassName);
					if ([destinationClass isSubclassOfClass:[SLManagedRemoteObject class]]) {
						// if this is a remote managed object, we can insert/update it
						if (relationshipDescription.isToMany) {
							// then we should be dealing with an array of remote obejcts
							NSArray *remoteObjects = nil;
							if ([remoteValue isKindOfClass:[NSArray class]]) {
								// making sure it *is* an array
								remoteObjects = remoteValue;
							} else {
								// we are pretending that remoteValue in this case is a dictionary for a single object
								remoteObjects = @[ remoteValue ];
							}
							NSMutableArray *allObjects = [NSMutableArray arrayWithCapacity:remoteObjects.count];
							for (id aRemoteObject in remoteObjects) {
								id localObject = [[destinationClass remoteMapping] objectForRemoteInfo:aRemoteObject];
								[[destinationClass remoteMapping] updateObject:localObject withRemoteInfo:aRemoteObject];
								[allObjects addObject:localObject];
							}
							NSSet *relationshipObjects = [NSSet setWithArray:allObjects];
							[receiver setValue:relationshipObjects forKey:key];
						} else {
							SLManagedRemoteObject *destinationObject = nil;
							if ([localPropertyPathArray lastObject] == key) {
								// if this is the last key, then since it maps to an object, we should expect
								// that the remoteValue is a dictionary, and try to fetch and update it as we do in
								// + updateWithRemoteInfo
								destinationObject = [[destinationClass remoteMapping] objectForRemoteInfo:remoteValue];
								[[destinationClass remoteMapping] updateObject:destinationObject withRemoteInfo:remoteValue];
								
								[receiver setValue:destinationObject forKeyPath:key];
							} else {
								// if an intermediate relation, then we just make sure that there is a placeholder
								// relationship object whose values will be set in further runs of this loop
								destinationObject = [receiver valueForKey:key];
								if (!destinationObject) {
									destinationObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(destinationClass)
																					  inManagedObjectContext:receiver.managedObjectContext];
									[receiver setValue:destinationObject forKey:key];
								}
							}
							
							receiver = destinationObject; // get ready for the next run of the loop
						}
					} else { // FUTURE: not bothering with the case when the relationship is to a non-managed object
						
					}
				} else {
					// key is a property
					[receiver setValue:remoteValue forKeyPath:key];
				}
			}
			
		}
	}
}

- (id)entityPropertyForPropertyName:(NSString *)propertyName {
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.modelClass) inManagedObjectContext:[SLCoreDataManager sharedManager].managedObjectContext];
	NSDictionary *propertiesByName = [entityDescription propertiesByName];
	return propertiesByName[propertyName];
}


@end
