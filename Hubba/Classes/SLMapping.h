//
//  SLMapping.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/30/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AfterRemoteUpdate)(NSArray *updatedObjects);

extern NSString * const kLocalUniquePropertyKey;
extern NSString * const kRemoteUniquePropertyKey;

@class SLManagedRemoteObject;
@interface SLMapping : NSObject

@property (nonatomic, strong) Class modelClass;
@property (nonatomic, strong) NSDictionary *propertyMappings;
@property (nonatomic, strong) NSDictionary *uniquePropertyMapping;
@property (nonatomic, strong) NSString * (^endPointForObject) (id);
@property (nonatomic, strong) NSString *endPoint;
@property (nonatomic, strong) NSString *pathToObject;
@property (nonatomic) BOOL appearsAsCollection;
@property (nonatomic) BOOL shouldRefreshRelationships;
@property (nonatomic, strong) AfterRemoteUpdate afterRemoteUpdate;

- (void)updateWithRemoteResponse:(id)remoteResponse;
- (void)updateObject:(SLManagedRemoteObject *)object withRemoteInfo:(NSDictionary *)remoteInfo;
- (SLManagedRemoteObject *)objectForRemoteInfo:(NSDictionary *)remoteInfo;
- (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObjectInfo;
	
@end
