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
	[[SLAPIClient sharedClient] get:[self endPoint] onCompletion:^(BOOL success, id response) {
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

+ (SLManagedRemoteObject *)objectForRemoteInfo:(NSDictionary *)remoteInfo {
	SLManagedRemoteObject * localObject = nil;
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
				SLManagedRemoteObject *localObject = [self objectForRemoteInfo:remoteInfo];
				[localObject updateWithRemoteInfo:remoteInfo];
			}
		}
	} else {
		SLManagedRemoteObject *localObject = [self objectForRemoteInfo:remoteResponse];
		[localObject updateWithRemoteInfo:remoteResponse];
	}
	
	NSError *error;
	if (![[[SLCoreDataManager sharedManager] managedObjectContext] save:&error]) {
		NSLog(@"Error saving after updating %@ with remote response: %@", NSStringFromClass([self class]), error);
	}
}

- (void)updateWithRemoteInfo:(NSDictionary *)remoteInfo {
	
	NSDictionary *mapping = [self.class localToRemoteMappings];
	for (NSString *localPropertyPath in [mapping allKeys]) {
		NSString *remotePropery = mapping[localPropertyPath];
		id remoteValue = [remoteInfo valueForKeyPath:remotePropery];
		if (remoteValue) {
			NSArray *localPropertyPathArray = [localPropertyPath componentsSeparatedByString:@"."];
			SLManagedRemoteObject *receiver = self; // in the loop, the object on which to do valueForKey:
			for (NSString *key in localPropertyPathArray) {
				// this property's description in the model
				id entityProperty = [receiver entityPropertyForPropertyName:key];
				if ([entityProperty isKindOfClass:[NSRelationshipDescription class]]) {
					// if the key is a relationship
					NSRelationshipDescription *relationshipDescription = (NSRelationshipDescription *)entityProperty;
					Class destinationClass = NSClassFromString(relationshipDescription.destinationEntity.managedObjectClassName);
					if ([destinationClass isSubclassOfClass:[SLManagedRemoteObject class]]) {
						// if this is a remote managed object, we can insert/update it
						SLManagedRemoteObject *destinationObject = nil;
						if ([localPropertyPathArray lastObject] == key) {
							// if this is the last key, then since it maps to an object, we should expect
							// that the remoteValue is a dictionary, and try to fetch and update it as we do in
							// + updateWithRemoteInfo
							destinationObject = [destinationClass objectForRemoteInfo:remoteValue];
							[destinationObject updateWithRemoteInfo:remoteValue];
							
							[receiver setValue:destinationObject forKeyPath:key];
						} else {
							// if an intermediate relation, then we just make sure that there is a placeholder
							// relationship object whose values will be set in further runs of this loop
							destinationObject = [receiver valueForKey:key];
							if (!destinationObject) {
								destinationObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(destinationClass)
																				  inManagedObjectContext:self.managedObjectContext];
								[receiver setValue:destinationObject forKey:key];
							}
						}
						
						receiver = destinationObject; // get ready for the next run of the loop
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
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:[SLCoreDataManager sharedManager].managedObjectContext];
	NSDictionary *propertiesByName = [entityDescription propertiesByName];
	return propertiesByName[propertyName];
}

#pragma mark - For the subclass

+ (NSString *)endPoint {
	return nil;
}

+ (NSDictionary *)localToRemoteMappings {
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
