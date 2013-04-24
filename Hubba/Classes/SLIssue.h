//
//  SLIssue.h
//  Hubba
//
//  Created by Raheel Ahmad on 4/22/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SLManagedRemoteObject.h"

@class SLUser, SLRepository;

@interface SLIssue : SLManagedRemoteObject

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * htmlURL;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) SLUser *user;
@property (nonatomic, retain) SLUser *assignee;
@property (nonatomic, retain) SLUser *repository;

@end
