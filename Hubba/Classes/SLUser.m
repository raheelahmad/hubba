//
//  SLUser.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/16/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLUser.h"


@implementation SLUser

@dynamic name;
@dynamic login;
@dynamic remoteID;
@dynamic company;
@dynamic email;
@dynamic ownedRepositories;
@dynamic me;

+ (NSString *)endPoint {
	return @"/user/%@";
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

+ (NSDictionary *)localToRemoteMappings {
	return @{
			   @"remoteID"		: @"remoteID",
			   @"name"			: @"name",
			   @"login"			: @"login",
			   @"company"		: @"company",
			   @"email"			: @"email",
	  };
}

@end
