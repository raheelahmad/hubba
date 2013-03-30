//
//  SLRelationMapping.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/30/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMapping.h"

@interface SLRelationMapping : SLMapping

@property (nonatomic, strong) NSString *localRelationKeypath; // the relationship in Core Data associated with this mapping

@end
