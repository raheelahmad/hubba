//
//  SLPropertyOnlyEntity.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/31/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLPerson.h"

@implementation SLPerson
@dynamic name;
@dynamic remoteID;
@dynamic company;

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPoint = @"/dummy";
	mapping.pathToObject = nil;
	mapping.appearsAsCollection = NO;
	mapping.modelClass = self;
	mapping.localToRemoteMapping = @{
								     @"name" : @"name",
									 @"remoteID" : @"id"
			 };
	mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"remoteID", kRemoteUniquePropertyKey : @"id" };
	return mapping;
}

@end

