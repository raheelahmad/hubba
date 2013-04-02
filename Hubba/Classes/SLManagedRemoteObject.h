//
//  SLRemoteManagedObject.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/15/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SLMapping.h"
#import "SLRelationMapping.h"

@interface SLManagedRemoteObject : NSManagedObject

#pragma mark - Local

+ (NSFetchedResultsController *)allObjcetsController;
+ (NSArray *)sortDescriptors;

#pragma mark - Remote

+ (void)refresh;

+ (SLMapping *)remoteMapping;
+ (NSArray *)relationshipMappings;

@end
