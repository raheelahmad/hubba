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

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPoint = @"/user/repos";
	mapping.appearsAsCollection = YES;
	mapping.modelClass = self;
	mapping.propertyMappings = @{
			   @"remoteID"			: @"id",
			   @"name"				: @"name",
			   @"remoteDescription"	: @"description",
			   @"owner"				: @"owner",
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
