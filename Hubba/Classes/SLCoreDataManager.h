//
//  SLCoreDataManager.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/10/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLCoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+ (SLCoreDataManager *)sharedManager;

- (void)resetCoreDataStack;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
