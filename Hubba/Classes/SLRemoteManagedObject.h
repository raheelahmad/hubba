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

+ (SLRemoteManagedObject *)objectForRemoteInfo:(NSDictionary *)remoteInfo;
+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject;
+ (void)updateWithRemoteResponse:(id)remoteResponse;
- (void)updateWithRemoteInfo:(NSDictionary *)remoteInfo;
+ (NSDictionary *)remoteToLocalMappings;
+ (BOOL)appearsAsCollection;
+ (NSString *)pathToObject;

@end
