//
//  SLPropertyOnlyEntity.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/31/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLManagedRemoteObject.h"

@class SLCompany;
@interface SLPerson : SLManagedRemoteObject
@property (strong) NSString *name;
@property (strong) NSNumber *remoteID;
@property (strong) SLCompany *company;
@end
