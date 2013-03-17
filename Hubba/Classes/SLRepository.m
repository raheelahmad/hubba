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

@implementation SLRepository

@dynamic remoteID;
@dynamic name;
@dynamic remoteDescription;
@dynamic owner;

+ (NSString *)endPoint {
	return @"/user/repos";
}

+ (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES] ];
}

+ (NSString *)pathToObject {
	return nil;
}

+ (BOOL)appearsAsCollection {
	return YES;
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"remoteID == %@", [remoteObject valueForKey:@"id"]];
}

+ (NSDictionary *)remoteToLocalMappings {
	return @{
			   @"id"			: @"remoteID",
			   @"name"			: @"name",
			   @"description"	: @"remoteDescription",
			   @"owner"			: @"owner",
		   };
}

@end
