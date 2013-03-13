//
//  SLAPIClient.m
//  Hubba
//
//  Created by Raheel Ahmad on 3/9/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLAPIClient.h"

@interface SLAPIClient ()

@property (nonatomic, strong) SLOAuth2Client *oauthClient;
@property (nonatomic, strong) SLFetcher *fetcher;

@end

@implementation SLAPIClient

#pragma mark - Requests

- (void)get:(NSString *)getURLString onCompletion:(FetchCompletionBlock)completionBlock {
	if (!self.authenticated) {
		completionBlock(NO, nil);
	} else {
		NSURLRequest *request = [NSURLRequest requestWithURL:[self URLForPath:getURLString]];
		[self.fetcher request:request completion:completionBlock];
	}
}

- (NSURL *)URLForPath:(NSString *)path {
	NSString *URLString = [self.baseURL stringByAppendingFormat:@"%@?access_token=%@", path, self.oauthClient.token];
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

- (id)initWithAPIName:(NSString *)APIName baseURL:(NSString *)baseURL {
	self = [super init];
	if (self) {
		self.APIName = APIName;
		self.baseURL = baseURL;
		self.oauthClient = [[SLOAuth2Client alloc] initWithAPIName:self.APIName]; // create a new OAuth client
		self.fetcher = [[SLFetcher alloc] init];
	}
	return self;
}


@end
