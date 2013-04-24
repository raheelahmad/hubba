//
//  SLUser.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/16/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLUser.h"
#import "SLRepository.h"
#import "SLOrganization.h"

@implementation SLUser

@dynamic name;
@dynamic login;
@dynamic remoteID;
@dynamic company;
@dynamic email;
@dynamic ownedRepositories;
@dynamic repositories;
@dynamic followers;
@dynamic following;
@dynamic me;
@dynamic organizations;
@dynamic issues;
@dynamic assignedIssues;

- (NSString *)description {
	return [NSString stringWithFormat:@"User: %@, %@ (%@)", self.remoteID, self.name, self.login];
}

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPointForObject = ^(id object) {
		return [NSString stringWithFormat:@"/user/%@", [object valueForKey:@"remoteID"]];
	};
	mapping.appearsAsCollection = NO;
	mapping.modelClass = self;
	mapping.propertyMappings = @{
			   @"remoteID"		: @"id",
			   @"name"			: @"name",
			   @"login"			: @"login",
			   @"company"		: @"company",
			   @"email"			: @"email",
	  };
	mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"remoteID", kRemoteUniquePropertyKey : @"id" };
	return mapping;
}

- (NSArray *)relationshipMappings {
	SLRelationMapping *organizationMapping = [[SLRelationMapping alloc] init];
	organizationMapping.endPoint = [NSString stringWithFormat:@"/user/%@/orgs", self.remoteID];
	organizationMapping.sourceObject = self;
	organizationMapping.modelClass = [SLOrganization class];
	organizationMapping.sourceRelationshipKeypath = @"organizations";
	organizationMapping.pathToObject = nil;
	organizationMapping.appearsAsCollection = YES;
	
	SLRelationMapping *repositoryMapping = [[SLRelationMapping alloc] init];
	repositoryMapping.endPoint = [NSString stringWithFormat:@"/user/%@/repos", self.remoteID];
	repositoryMapping.sourceObject = self;
	repositoryMapping.modelClass = [SLRepository class];
	repositoryMapping.sourceRelationshipKeypath = @"repositories";
	repositoryMapping.pathToObject = nil;
	repositoryMapping.appearsAsCollection = YES;
	repositoryMapping.afterRemoteUpdate = ^(NSArray *updatedObjects) {
		for (SLRepository *repository in updatedObjects) {
			[repository refreshRelationships];
		}
	};
	
	SLRelationMapping *followersMapping = [[SLRelationMapping alloc] init];
	followersMapping.endPoint = [NSString stringWithFormat:@"/user/%@/followers", self.remoteID];
	followersMapping.sourceObject = self;
	followersMapping.modelClass = [SLUser class];
	followersMapping.sourceRelationshipKeypath = @"followers";
	followersMapping.pathToObject = nil;
	followersMapping.appearsAsCollection = YES;
	
	return @[ organizationMapping, repositoryMapping, followersMapping ];
}

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES] ];
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"remoteID == %@", [remoteObject valueForKey:@"id"]];
}

@end
