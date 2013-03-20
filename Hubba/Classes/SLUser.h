//
//  SLUser.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/16/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLManagedRemoteObject.h"

@class SLMe;
@interface SLUser : SLManagedRemoteObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *ownedRepositories;
@property (nonatomic, strong) SLMe *me;

@end
