//
//  SLRemoteManagedObject.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/15/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SLRemoteManagedObject : NSManagedObject

#pragma mark - Local

+ (NSFetchedResultsController *)allObjcetsController;
+ (NSArray *)sortDescriptors;

#pragma mark - Remote

+ (void)refresh;
+ (NSString *)endPoint;
+ (SLRemoteManagedObject *)objectForRemoteInfo:(NSDictionary *)remoteInfo;
+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject;
+ (void)updateWithRemoteResponse:(id)remoteResponse;
- (void)updateWithRemoteInfo:(NSDictionary *)remoteInfo;
// local -> remote, since local properties ought to be unique in this mapping
// (not the other way; so we can have different local properties map to same remote property
+ (NSDictionary *)localToRemoteMappings;
+ (BOOL)appearsAsCollection;
+ (NSString *)pathToObject;

@end
