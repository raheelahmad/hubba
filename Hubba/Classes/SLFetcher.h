//
//  SLFetcher.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/3/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLFetcher : NSObject

- (void)request:(NSURLRequest *)request completion:(void (^)(NSString *))completion;
@end
