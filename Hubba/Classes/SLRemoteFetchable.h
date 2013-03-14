//
//  SLRemoteFetchable.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/13/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLRemoteFetchable <NSObject>
+ (NSFetchedResultsController *)allObjcetsController;
+ (id<SLRemoteFetchable>)objectForRemoteResponse:(NSDictionary *)remoteResponse;
- (void)updateWithRemoteResponse:(NSDictionary *)remoteResponse;
@end
