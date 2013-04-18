//
//  SLCompany.h
//  Hubba
//
//  Created by Raheel Ahmad on 4/3/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLManagedRemoteObject.h"

@interface SLCompany : SLManagedRemoteObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSSet *persons;
@property (nonatomic, strong) NSSet *departments;
@property (nonatomic, strong) NSSet *previousEmployees;

@end
