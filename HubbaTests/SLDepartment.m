//
//  SLDepartment.m
//  Hubba
//
//  Created by Raheel Ahmad on 4/11/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLDepartment.h"

@implementation SLDepartment

@dynamic company;
@dynamic name;

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.appearsAsCollection = NO;
	mapping.modelClass = self;
	mapping.localToRemoteMapping = @{
								  @"name" : @"name"
		  };
	mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"name", kRemoteUniquePropertyKey : @"name" };
	return mapping;
}

@end
