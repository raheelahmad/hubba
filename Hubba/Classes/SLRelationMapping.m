//
//  SLRelationMapping.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/30/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLRelationMapping.h"

@implementation SLRelationMapping

#pragma mark - Initialization

- (id)init {
	self = [super init];
	if (self) {
		self.useDestinationClassRemoteMapping = YES;
	}
	return self;
}

@end
