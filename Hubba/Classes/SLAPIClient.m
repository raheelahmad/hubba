//
//  SLAPIClient.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/9/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLAPIClient.h"
#import "SLURLRequest.h"

@interface SLAPIClient ()

@property (nonatomic, strong) SLOAuth2Client *oauthClient;
@property (nonatomic, strong) NSMutableArray *fetchers;

@end

@implementation SLAPIClient

#pragma mark - Requests

- (void)get:(NSString *)getURLString onCompletion:(FetchCompletionBlock)completionBlock {
	[self get:getURLString needsAuthentication:YES onCompletion:completionBlock];
}

- (void)get:(NSString *)getURLString needsAuthentication:(BOOL)needsAuthentication onCompletion:(FetchCompletionBlock)completionBlock {
	if (needsAuthentication && !self.authenticated) {
		completionBlock(NO, nil);
	} else {
		SLURLRequest *request = [SLURLRequest requestWithURL:[self URLForPath:getURLString needsAuthentication:needsAuthentication]];
		SLFetcher *fetcher = [[SLFetcher alloc] init];
		[self.fetchers addObject:fetcher];
		// construct our wrapper completiobn block, so we can let go of fetcher upon its completion
		FetchCompletionBlock _completionBlock = ^(BOOL success, id response) {
			[self.fetchers removeObject:fetcher];
			if (completionBlock) {
				completionBlock(success, response);
			}
		};
		
		[fetcher request:request completion:_completionBlock];
	}
}

- (NSURL *)URLForPath:(NSString *)path needsAuthentication:(BOOL)needsAuthentication {
	if (path == nil) {
		return nil;
	}
	
	NSRange httpLocation = [path rangeOfString:@"http"];
	NSString *URLString = path;
	if (httpLocation.location == NSNotFound || httpLocation.location != 0) {
		URLString = [self.baseURL stringByAppendingString:URLString];
	}
	if (needsAuthentication) {
		URLString = [URLString stringByAppendingFormat:@"?access_token=%@", self.oauthClient.token];
	}
	return [NSURL URLWithString:URLString];
}

#pragma mark - Authentication

- (BOOL)resetAuthentication  {
	return [self.oauthClient resetAuthentication];
}
	
- (BOOL)authenticated {
	return self.oauthClient.authenticated;
}

#pragma mark - Startup

- (void)initiateAuthorizationWithWebView:(UIWebView *)webView onCompletion:(AuthenticationCompletionBlock)completionBlock {
	[self.oauthClient initiateAuthorizationWithWebView:webView onCompletion:completionBlock];
}

#pragma mark - Basics

- (void)setAPIName:(NSString *)APIName {
	_APIName = APIName;
	self.oauthClient = [[SLOAuth2Client alloc] initWithAPIName:APIName]; // create a new OAuth client
}

+ (SLAPIClient *)sharedClient {
	static SLAPIClient *_sharedClient = nil;
	if (!_sharedClient) {
		_sharedClient = [[SLAPIClient alloc] init];
	}
	return _sharedClient;
}

- (id)init {
	self = [super init];
	if (self) {
		self.fetchers = [NSMutableArray arrayWithCapacity:10];
	}
	return self;
}


@end
