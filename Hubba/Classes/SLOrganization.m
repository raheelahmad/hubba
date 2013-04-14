//
//  SLOrganization.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/19/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLOrganization.h"

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

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES] ];
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"id == %@", [remoteObject valueForKey:@"id"]];
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
	
	return mapping;
}
@end
