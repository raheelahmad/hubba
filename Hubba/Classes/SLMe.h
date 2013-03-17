//
//  SLMe.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/16/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLRemoteManagedObject.h"

@class SLUser;

@interface SLMe : SLRemoteManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSNumber * totalPrivateRepos;
@property (nonatomic, retain) NSNumber * totalOwnedRepos;
@property (nonatomic, retain) NSNumber * diskUsage;
@property (nonatomic, retain) NSString * planName;
@property (nonatomic, retain) NSNumber * planSpace;
@property (nonatomic, retain) NSNumber * planCollaborators;
@property (nonatomic, retain) SLUser * user;

@end
