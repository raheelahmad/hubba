//
//  SLIssue.m
//  Hubba
//
//  Created by Raheel Ahmad on 4/22/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLIssue.h"
#import "SLUser.h"


@implementation SLIssue

@dynamic number;
@dynamic htmlURL;
@dynamic state;
@dynamic title;
@dynamic body;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic user;
@dynamic assignee;
@dynamic repository;

- (NSString *)description {
	return [NSString stringWithFormat:@"Issue (#%@): %@ %@", self.number, self.title, self.body];
}

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.appearsAsCollection = YES;
	mapping.modelClass = self;
	RemoteToLocalTransformer dateTransformer = ^(NSString *createdAtString) {
								 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
								 [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
								 [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
								 return [dateFormatter dateFromString:createdAtString];
	};
	mapping.transformerInfo = @[
							 @{ @"createdAt" : dateTransformer},
							 @{ @"updatedAt" : dateTransformer},
		];
	mapping.propertyMappings = @{
							  @"number" : @"number",
							  @"htmlURL" : @"html_url",
							  @"state" : @"state",
							  @"title" : @"title",
							  @"body" : @"body",
							  @"createdAt" : @"created_at",
							  @"updatedAt" : @"updated_at",
							  @"user" : @"user",
							  @"assignee" : @"assignee",
		 };
	mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"number", kRemoteUniquePropertyKey : @"number" };
	
	return mapping;
}

@end
