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

@end

@implementation SLAPIClient

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

+ (SLAPIClient *)sharedClientWithAPIName:(NSString *)APIName baseURL:(NSString *)baseURL {
	static SLAPIClient *_client;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_client = [[SLAPIClient alloc] init];
		_client.APIName = APIName;
		_client.oauthClient = [[SLOAuth2Client alloc] initWithAPIName:APIName];
	});
	
	return _client;
}

@end
