//
//  SLFetcher.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/3/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLFetcher.h"
#import "SLURLRequest.h"

@interface SLFetcher ()
@property (nonatomic, strong) SLURLRequest *request;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, copy) FetchCompletionBlock completionBlock;
@end

@implementation SLFetcher

#pragma mark - Accessors

+ (SLFetcher *)sharedFetcher {
	static SLFetcher *_sharedFetcher = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedFetcher = [[SLFetcher alloc] init];
	});
	return _sharedFetcher;
}

#pragma mark - Making requests

+ (void)request:(SLURLRequest *)request completion:(FetchCompletionBlock)completion {
	[[self sharedFetcher] request:request completion:completion];
}

- (void)request:(SLURLRequest *)request completion:(FetchCompletionBlock)completion {
	self.request = request;
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	if (self.connection) {
		self.completionBlock = completion;
		self.responseData = [NSMutableData data];
	} else {
		completion(NO, nil);
	}
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Error loading: %@", error);
	if (self.completionBlock) {
		self.completionBlock(NO, nil);
	}
	self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSError *error;
	id response = nil;
	if (self.request.parseOption == JSON_PARSED_OUTPUT) {
		response = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&error];
	} else if (self.request.parseOption == NSSTRING_PARSED_OUTPUT) {
		response = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
	} else {
		response = self.responseData;
	}
	if (!response) {
		NSLog(@"Could not parse response: %@", error);
		self.completionBlock(NO, nil);
	}
	if (self.completionBlock) {
		self.completionBlock(YES, response);
	}
	self.connection = nil;
}

@end
