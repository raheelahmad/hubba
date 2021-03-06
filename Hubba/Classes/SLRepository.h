//
//  SLRepository.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/9/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLManagedRemoteObject.h"

@class SLUser, SLOrganization;
@interface SLRepository : SLManagedRemoteObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * remoteDescription;
@property (nonatomic, retain) SLUser *owner;
@property (nonatomic, strong) SLOrganization *organization;
@property (nonatomic, strong) NSSet *issues;

@end
