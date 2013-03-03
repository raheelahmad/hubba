//
//  SLOAuth2Client.m
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLOAuth2Client.h"

static NSString * const kSLClientID = @"0cd6f03185bbf7def542";
static NSString * const kSLClientSecret = @"a2ca98bb09b0b95ef284d87515d84bde6db9194c";
static NSString * const kSLCallBackURL = @"hubba://oauth";
static NSString * const kSLAuthorizationURL = @"https://github.com/login/oauth/authorize?client_id=%@";;
static NSString * const kSLTokenRequestURL = @"https://github.com/login/oauth/access_token";
static NSString * const kSLTokenPostBody = @"client_id=%@&client_secret=%@&code=%@";

@interface SLTokenFetcher : NSObject <NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation SLTokenFetcher

#pragma mark - NSURLConnection delegate

+ (SLTokenFetcher *)fetcherWithRequest:(NSURLRequest *)request {
	SLTokenFetcher *fetcher = [[SLTokenFetcher alloc] init];
	fetcher.request = request;
	return fetcher;
}

- (void)fetch {
	self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
	if (self.connection) {
		self.responseData = [NSMutableData data];
	}
}

+ (NSURLRequest *)tokenRequestForCode:(NSString *)code {
	NSString *body = [NSString stringWithFormat:kSLTokenPostBody, kSLClientID, kSLClientSecret, code];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kSLTokenRequestURL]];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	return request;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Error loading: %@", error);
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *response = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
	NSLog(@"Finished!!!!\n%@", response);
}

@end

@interface SLOAuth2Client ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) SLTokenFetcher *tokenFetcher;

@end

@implementation SLOAuth2Client

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"Error loading: %@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (isTemporaryCodeRequest(request)) {
		[self fetchTokenForRequest:request];
		return NO;
	}
	return YES;
}

- (void)fetchTokenForRequest:(NSURLRequest *)request {
	NSURLRequest *redirectedRequestForToken = [self tokenRequestForCode:[self codeFromRequest:request]];
	self.tokenFetcher = [SLTokenFetcher fetcherWithRequest:redirectedRequestForToken];
	[self.tokenFetcher fetch];
}

#pragma mark - Loading requests

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

- (void)initiateAuthorizationWithWebView:(UIWebView *)webView {
	self.webView.delegate = nil;
	self.webView = webView;
	self.webView.delegate = self;
	[webView loadRequest:self.authorizationRequest];
}

- (NSURLRequest *)authorizationRequest {
	NSString *URLString = [NSString stringWithFormat:kSLAuthorizationURL, kSLClientID];
	NSURL *url = [NSURL URLWithString:URLString];
	return [NSURLRequest requestWithURL:url];
}

- (NSURLRequest *)tokenRequestForCode:(NSString *)code {
	return [SLTokenFetcher tokenRequestForCode:code];
}

#pragma mark - Basics

+ (SLOAuth2Client *) sharedClient {
	static SLOAuth2Client *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedClient = [[SLOAuth2Client alloc] init];
	});
	
	return _sharedClient;
}


- (void)dealloc {
	self.webView.delegate = nil;
}

@end
