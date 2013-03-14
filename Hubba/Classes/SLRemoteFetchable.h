//
//  SLRemoteFetchable.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/13/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLRemoteFetchable <NSObject>

#pragma mark - Local

+ (NSFetchedResultsController *)allObjcetsController;
+ (NSArray *)sortDescriptors;

#pragma mark - Remote

+ (id<SLRemoteFetchable>)objectForRemoteInfo:(NSDictionary *)remoteInfo;
+ (void)updateWithRemoteResponse:(id)remoteResponse;
- (void)updateWithRemoteInfo:(NSDictionary *)remoteInfo;
+ (NSDictionary *)remoteToLocalMappings;
+ (BOOL)appearsAsCollection;
+ (NSString *)pathToObject;

@end
