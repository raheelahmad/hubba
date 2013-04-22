//
//  SLOrganization.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/19/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLOrganization.h"
#import "SLRepository.h"

@implementation SLOrganization

@dynamic id;
@dynamic login;
@dynamic url;
@dynamic avatarURL;
@dynamic name;
@dynamic company;
@dynamic blog;
@dynamic location;
@dynamic email;
@dynamic htmlURL;
@dynamic type;
@dynamic publicRepos;
@dynamic publicGists;
@dynamic createdAt;
@dynamic users;
@dynamic repositories;

- (NSString *)description {
	return [NSString stringWithFormat:@"Organization: %@, %@, %@", self.id, self.name, self.login];
}

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES] ];
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"id == %@", [remoteObject valueForKey:@"id"]];
}

- (NSArray *)relationshipMappings {
	SLRelationMapping *repositoryMapping = [[SLRelationMapping alloc] init];
	repositoryMapping.modelClass = [SLRepository class];
	repositoryMapping.sourceObject = self;
	repositoryMapping.sourceRelationshipKeypath = @"repositories";
	repositoryMapping.appearsAsCollection = YES;
	repositoryMapping.pathToObject = nil;
	repositoryMapping.endPoint = [NSString stringWithFormat:@"/orgs/%@/repos", self.id];
	
	return @[ repositoryMapping ];
}

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.propertyMappings = @{
			   @"id"			: @"id",
			   @"name"			: @"name",
			   @"login"			: @"login",
			   @"company"		: @"company",
			   @"email"			: @"email",
			   @"url"			: @"url",
			   @"location"		: @"location",
			   @"htmlURL"		: @"html_url",
			   @"type"			: @"type",
			   @"publicRepos"	: @"public_repos",
			   @"publicGists"	: @"public_gists",
			   @"createdat"		: @"created_at",
	  };
	mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"id", kRemoteUniquePropertyKey : @"id" };
	
	return mapping;
}
@end
