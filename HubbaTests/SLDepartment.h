//
//  SLDepartment.h
//  Hubba
//
//  Created by Raheel Ahmad on 4/11/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLManagedRemoteObject.h"

@class SLCompany;
@interface SLDepartment : SLManagedRemoteObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) SLCompany *company;
@end
