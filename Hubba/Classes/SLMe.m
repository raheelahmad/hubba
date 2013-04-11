//
//  SLMe.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/16/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMe.h"
#import "SLUser.h"


@implementation SLMe

@dynamic remoteID;
@dynamic totalPrivateRepos;
@dynamic totalOwnedRepos;
@dynamic diskUsage;
@dynamic planName;
@dynamic planSpace;
@dynamic planCollaborators;
@dynamic user;

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPoint = @"/user";
	mapping.appearsAsCollection = NO;
	NSDictionary *userMappings = [[SLUser remoteMapping] localToRemoteMapping];
	NSMutableDictionary *mappings = [NSMutableDictionary dictionaryWithCapacity:12];
	[userMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		NSString *localKeyPath = (NSString *)key;
		NSString *adjustedToUserKeyPath = [NSString stringWithFormat:@"user.%@", localKeyPath];
		[mappings setObject:obj forKey:adjustedToUserKeyPath];
	}];
	[mappings addEntriesFromDictionary:@{
		  @"remoteID"						: @"id",
		  @"user.remoteID"					: @"id",
		  @"totalPrivateRepos"				: @"total_private_repos",
		  @"totalOwnedRepos"				: @"owned_private_repos",
		  @"diskUsage"						: @"disk_usage",
		  @"planName"						: @"plan.name",
		  @"planSpace"						: @"plan.space",
		  @"planCollaborators"				: @"plan.collaborators",
	  }];
	mapping.localToRemoteMapping = mappings;
	mapping.modelClass = self;
	
	return mapping;
}

+ (NSString *)endPoint {
	return @"/user";
}

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES] ];
}

+ (NSString *)pathToObject {
	return nil;
}

+ (BOOL)appearsAsCollection {
	return NO;
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"remoteID == %@", [remoteObject valueForKey:@"id"]];
}

@end
