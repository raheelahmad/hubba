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

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPointForObject = ^(id object) {
		return [NSString stringWithFormat:@"/user/%@", [object valueForKey:@"remoteID"]];
	};
	mapping.appearsAsCollection = NO;
	mapping.localToRemoteMapping = @{
			   @"remoteID"		: @"id",
			   @"name"			: @"name",
			   @"login"			: @"login",
			   @"company"		: @"company",
			   @"email"			: @"email",
	  };
	
	return mapping;
}

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES] ];
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"remoteID == %@", [remoteObject valueForKey:@"id"]];
}

@end
