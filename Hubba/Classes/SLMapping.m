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

/**
- (void)updateWithRemoteResponse:(id)remoteResponse {
	// if nested, let's access the branch
	if (self.pathToObject) {
		remoteResponse = [remoteResponse valueForKeyPath:self.pathToObject];
	}
	if (self.appearsAsCollection) {
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
 **/

@end
