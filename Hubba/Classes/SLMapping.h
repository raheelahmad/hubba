//
//  SLMapping.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/30/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLMapping : NSObject

@property (nonatomic, strong) NSDictionary *localToRemoteMapping;

@property (nonatomic, strong) NSString * (^endPointForObject) (id);
@property (nonatomic, strong) NSString *endPoint;
@property (nonatomic, strong) NSString *pathToObject;
@property (nonatomic) BOOL appearsAsCollection;

@end
