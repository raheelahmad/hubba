//
//  SLFetcher.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/3/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FetchCompletionBlock) (BOOL success, NSString *response);

@interface SLFetcher : NSObject

// the string argument in callback will be nil if request fails
- (void)request:(NSURLRequest *)request completion:(FetchCompletionBlock)completion;

@end
