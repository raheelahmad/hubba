//
//  SLFetcher.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/3/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLFetcher.h"

@interface SLFetcher ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, copy) void (^completionBlock) (NSString *);
@end

@implementation SLFetcher

#pragma mark - NSURLConnection delegate

- (void)request:(NSURLRequest *)request completion:(void (^)(NSString *))completion {
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	if (self.connection) {
		self.completionBlock = completion;
		self.responseData = [NSMutableData data];
	} else {
		completion(nil);
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Error loading: %@", error);
	if (self.completionBlock) {
		self.completionBlock(nil);
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
	NSString *response = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
	if (self.completionBlock) {
		self.completionBlock(response);
	}
	self.connection = nil;
}
@end
