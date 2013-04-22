//
//  SLRepository.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/9/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLRepository.h"
#import "SLCoreDataManager.h"
#import "SLUser.h"
#import "SLOrganization.h"

@implementation SLRepository

@dynamic remoteID;
@dynamic name;
@dynamic remoteDescription;
@dynamic owner;
@dynamic organization;

- (NSString *)description {
	return [NSString stringWithFormat:@"Repository: %@, %@", self.remoteID, self.name];
}

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.appearsAsCollection = YES;
	mapping.modelClass = self;
	mapping.propertyMappings = @{
			   @"remoteID"			: @"id",
			   @"name"				: @"name",
			   @"remoteDescription"	: @"description",
			   @"owner"				: @"owner",
		   };
	mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"remoteID", kRemoteUniquePropertyKey : @"id" };
	return mapping;
}

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES] ];
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"remoteID == %@", [remoteObject valueForKey:@"id"]];
}

@end
