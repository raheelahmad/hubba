//
//  SLOAuth2Client.m
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLOAuth2Client.h"
#import "SLFetcher.h"
#import "SFHFKeychainUtils.h"

static NSString * const kSLClientID = @"0cd6f03185bbf7def542";
static NSString * const kSLClientSecret = @"a2ca98bb09b0b95ef284d87515d84bde6db9194c";
static NSString * const kSLAuthorizationURL = @"https://github.com/login/oauth/authorize?client_id=%@";;
static NSString * const kSLTokenRequestURL = @"https://github.com/login/oauth/access_token";
static NSString * const kSLTokenPostBody = @"client_id=%@&client_secret=%@&code=%@";

static NSString * const kAccessTokenKey = @"access_token";
static NSString * const kServiceName = @"com.sakunlabs.access_tokens";

@interface SLOAuth2Client ()

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, strong) SLFetcher *fetcher;
@property (nonatomic, copy) AuthenticationCompletionBlock completionBlock;

@end

@implementation SLOAuth2Client

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//	NSLog(@"Error loading: %@", error);
	[self.webView stopLoading];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// intercept load request from auth server containing temporary code
	if (isTemporaryCodeRequest(request)) {
		// fetch token instead using NSURLConnection
		[self fetchTokenForRequest:request];
		return NO;
	}
	return YES;
}

- (void)fetchTokenForRequest:(NSURLRequest *)request {
	NSURLRequest *redirectedRequestForToken = [self tokenRequestForCode:[self codeFromRequest:request]];
	[[NSURLCache sharedURLCache] removeCachedResponseForRequest:redirectedRequestForToken];
	[self.fetcher request:redirectedRequestForToken completion:^(BOOL success, NSString *response) {
		if (success) {
			NSString *token = [self accessTokenFromResponse:response];
			NSLog(@"Token is: %@", token);
			NSError *error;
			if (![SFHFKeychainUtils storeUsername:self.APIName andPassword:token forServiceName:kServiceName updateExisting:YES error:&error]) {
				NSLog(@"ERROR: could not fetch token to KeyChain: %@", error);
				self.completionBlock(NO);
				return;
			}
			self.completionBlock(YES);
		} else {
			self.completionBlock(NO);
		}
	}];
}

#pragma mark - Authenticated?

- (BOOL)authenticated {
	return self.token != nil;
}

- (NSString *)token {
	return [SFHFKeychainUtils getPasswordForUsername:self.APIName andServiceName:kServiceName error:NULL];
}

#pragma mark - Helpers

- (NSString *)accessTokenFromResponse:(NSString *)response {
	if (!response) {
		return nil;
	}
	NSString *accessToken;
	
	NSArray *components = [response componentsSeparatedByString:@"&"];
	for (NSString *component in components) {
		NSArray *keyValue = [component componentsSeparatedByString:@"="];
		if (keyValue.count != 2 || ![keyValue[0] isEqualToString:kAccessTokenKey]) {
			continue;
		}
		accessToken = keyValue[1];
		break;
	}

	return accessToken;
}

- (NSString *)codeFromRequest:(NSURLRequest *)request {
	NSString *URLString = request.URL.absoluteString;
	NSArray *components = [URLString componentsSeparatedByString:@"code="];
	if (components.count < 2) {
		return nil;
	}
	NSString *stringIncludingCode = components[1];
	NSRange rangeOfAmp = [stringIncludingCode rangeOfString:@"&"];
	if (rangeOfAmp.location == NSNotFound) {
		return stringIncludingCode;
	} else {
		return [stringIncludingCode substringToIndex:rangeOfAmp.location];
	}
}

BOOL isTemporaryCodeRequest(NSURLRequest *request) {
	NSArray *components = [[request.URL absoluteString] componentsSeparatedByString:@"code="];
	NSRange clientSecretRange = [[request.URL absoluteString] rangeOfString:@"client_secret="];
	return components.count >= 2 && clientSecretRange.location == NSNotFound;
}

- (NSURLRequest *)authorizationRequest {
	NSString *URLString = [NSString stringWithFormat:kSLAuthorizationURL, kSLClientID];
	NSURL *url = [NSURL URLWithString:URLString];
	return [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
}

- (NSURLRequest *)tokenRequestForCode:(NSString *)code {
	NSString *body = [NSString stringWithFormat:kSLTokenPostBody, kSLClientID, kSLClientSecret, code];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kSLTokenRequestURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
															timeoutInterval:60];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	return request;
}

#pragma mark - Authentication

- (BOOL)resetAuthentication {
	self.webView = nil;
	NSHTTPCookie *aCookie;
	for (aCookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:aCookie];
	}
	NSError *error;
	if (![SFHFKeychainUtils deleteItemForUsername:self.APIName andServiceName:kServiceName error:&error]) {
		NSLog(@"Unable to reset authentication: %@", error);
		return NO;
	}
	return YES;
}

- (void)initiateAuthorizationWithWebView:(UIWebView *)webView onCompletion:(AuthenticationCompletionBlock)completionBlock {
	self.completionBlock = completionBlock;
	
	self.webView.delegate = nil;
	self.webView = webView;
	self.webView.delegate = self;
	NSURLRequest *authorizationRequest = self.authorizationRequest;
	[[NSURLCache sharedURLCache] removeCachedResponseForRequest:authorizationRequest];
	[webView loadRequest:authorizationRequest];
}

#pragma mark - Basics

- (id)initWithAPIName:(NSString *)APIName {
	self = [super init];
	if (self) {
		_fetcher = [[SLFetcher alloc] init];
		_fetcher.parseAsJSON = NO;
		_APIName = APIName;
	}
	return self;
}

- (void)dealloc {
	self.webView.delegate = nil;
}

@end
