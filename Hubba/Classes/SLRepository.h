//
//  SLRepository.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/9/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SLRepository : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * remoteDescription;

+ (SLRepository *)objectForRemoteResponse:(NSDictionary *)remoteResponse;
- (void)updateWithRemoteResponse:(NSDictionary *)remoteResponse;
+ (NSFetchedResultsController *)allObjcetsController;
+ (void)parseFromResponse:(id)parsedResponse;
	
@end
