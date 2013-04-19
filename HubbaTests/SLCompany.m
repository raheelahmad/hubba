//
//  SLCompany.m
//  Hubba
//
//  Created by Raheel Ahmad on 4/3/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLCompany.h"

@implementation SLCompany
@dynamic title;
@dynamic address;
@dynamic id;
@dynamic persons;
@dynamic departments;
@dynamic previousEmployees;
@dynamic peopleThinkWeAreDesirable;

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPoint = @"/dummy";
	mapping.pathToObject = nil;
	mapping.appearsAsCollection = NO;
	mapping.modelClass = self;
	mapping.propertyMappings = @{
								     @"title" : @"title",
									 @"id" : @"id",
									 @"address" : @"address",
									 @"departments" : @"departments"
									};
	mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"id", kRemoteUniquePropertyKey : @"id" };
	return mapping;
}

@end
