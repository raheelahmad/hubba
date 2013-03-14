//
//  SLFSQCheckin.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/13/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLRemoteFetchable.h"

@interface SLFSQCheckin : NSManagedObject <SLRemoteFetchable>

@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) NSString * venueCity;

@end
