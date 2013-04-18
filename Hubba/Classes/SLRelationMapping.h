//
//  SLRelationMapping.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/30/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMapping.h"

@interface SLRelationMapping : SLMapping

@property (nonatomic, assign) BOOL usesDestinationClassRemoteMapping;
@property (nonatomic, assign) SLManagedRemoteObject *sourceObject;
@property (nonatomic, assign) NSString *sourceRelationshipKeypath;

@end
