//
//  SLMapping.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/30/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kLocalUniquePropertyKey;
extern NSString * const kRemoteUniquePropertyKey;

@class SLManagedRemoteObject;
@interface SLMapping : NSObject

@property (nonatomic, strong) Class modelClass;
@property (nonatomic, strong) NSDictionary *localToRemoteMapping;
@property (nonatomic, strong) NSDictionary *uniquePropertyMapping;
@property (nonatomic, strong) NSString * (^endPointForObject) (id);
@property (nonatomic, strong) NSString *endPoint;
@property (nonatomic, strong) NSString *pathToObject;
@property (nonatomic) BOOL appearsAsCollection;

//- (void)updateWithRemoteResponse:(id)remoteResponse;
- (SLManagedRemoteObject *)objectForRemoteInfo:(NSDictionary *)remoteInfo;
- (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObjectInfo;
	
@end
