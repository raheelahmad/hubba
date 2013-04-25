//
//  SLPropertyOnlyEntity.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/31/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLPerson.h"
#import "SLCompany.h"

@implementation SLPerson

@dynamic name;
@dynamic title;
@dynamic remoteID;
@dynamic company;
@dynamic previousCompany;
@dynamic desirableCompanies;

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPoint = @"/dummy";
	mapping.pathToObject = nil;
	mapping.appearsAsCollection = NO;
	mapping.modelClass = self;
	
	mapping.propertyMappings = @{
								     @"name" : @"name",
								     @"title" : @"title",
			 @"remoteID" : @"id",
									 @"company" : @"company",
			 };
	mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"remoteID", kRemoteUniquePropertyKey : @"id" };
	RemoteToLocalTransformer titleTransformer = (id)^(id remoteValue) {
		return [NSString stringWithFormat:@"Senior %@", remoteValue];
	};
	mapping.transformerInfo = @[
						  @{ @"title" : titleTransformer }
		];
	return mapping;
}

- (NSArray *)relationshipMappings {
	SLRelationMapping *previousCompanyMapping = [[SLRelationMapping alloc] init];
	previousCompanyMapping.endPoint = @"/dummy";
	previousCompanyMapping.pathToObject = nil;
	previousCompanyMapping.appearsAsCollection = NO;
	previousCompanyMapping.modelClass = [SLCompany class];
	previousCompanyMapping.sourceObject = self;
	previousCompanyMapping.sourceRelationshipKeypath = @"previousCompany";
	
	SLRelationMapping *desirableCompaniesMapping = [[SLRelationMapping alloc] init];
	desirableCompaniesMapping.endPoint = @"/dummy";
	desirableCompaniesMapping.pathToObject = nil;
	desirableCompaniesMapping.appearsAsCollection = YES;
	desirableCompaniesMapping.modelClass = [SLCompany class];
	desirableCompaniesMapping.sourceObject = self;
	desirableCompaniesMapping.sourceRelationshipKeypath = @"desirableCompanies";
	return @[ previousCompanyMapping, desirableCompaniesMapping ];
}

@end

