//
//  SLPropertyOnlyEntity.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/31/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLPropertyOnlyEntity.h"

@implementation SLPropertyOnlyEntity
@dynamic name;

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPoint = @"/dummy";
	mapping.pathToObject = nil;
	mapping.appearsAsCollection = NO;
	mapping.localToRemoteMapping = @{
								     @"name" : @"name"
			 };
	return mapping;
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"name = %@", remoteObject[@"name"]];
}

@end

