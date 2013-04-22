//
//  SLOrganization.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/19/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLManagedRemoteObject.h"

@interface SLOrganization : SLManagedRemoteObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * blog;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * htmlURL;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * publicRepos;
@property (nonatomic, retain) NSNumber * publicGists;
@property (nonatomic, retain) NSDate * createdAt;

@property (nonatomic, strong) NSSet *users;
@property (nonatomic, strong) NSSet *repositories;


@end
