//
//  SLURLRequest.m
//  Hubba
//
//  Created by Raheel Ahmad on 4/26/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLURLRequest.h"

@implementation SLURLRequest

+ (SLURLRequest *)requestWithURL:(NSURL *)URL {
	SLURLRequest *request = [super requestWithURL:URL];
	request.parseOption = JSON_PARSED_OUTPUT;
	
	return request;
}

- (id)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
	self = [super initWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
	if (self) {
		self.parseOption = JSON_PARSED_OUTPUT;
	}
	return self;
}
@end
