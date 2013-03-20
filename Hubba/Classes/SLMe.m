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

+ (NSDictionary *)remoteToLocalMappings {
	NSDictionary *userMappings = [SLUser remoteToLocalMappings];
	NSMutableDictionary *mappings = [NSMutableDictionary dictionaryWithCapacity:12];
	[userMappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		NSString *localKeyPath = (NSString *)obj;
		NSString *adjustedToUserKeyPath = [NSString stringWithFormat:@"user.%@", localKeyPath];
		[mappings setObject:adjustedToUserKeyPath forKey:key];
	}];
	[mappings addEntriesFromDictionary:@{
		  @"id"								: @"remoteID",
		  @"total_private_repos"			: @"totalPrivateRepos",
		  @"owned_private_repos"			: @"totalOwnedRepos",
		  @"disk_usage"						: @"diskUsage",
		  @"plan.name"						: @"planName",
		  @"plan.space"						: @"planSpace",
		  @"plan.collaborators"				: @"planCollaborators",
	  }];
	
	return mappings;
}

@end
