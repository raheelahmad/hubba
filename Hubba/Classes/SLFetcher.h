//
//  SLFetcher.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/3/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FetchCompletionBlock) (BOOL success, id response);

@class SLURLRequest;

@interface SLFetcher : NSObject

+ (void)request:(SLURLRequest *)request completion:(FetchCompletionBlock)completion;
// the string argument in callback will be nil if request fails
- (void)request:(SLURLRequest *)request completion:(FetchCompletionBlock)completion;

@end
