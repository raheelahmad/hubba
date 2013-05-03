//
//  SLAPIClient.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/9/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLOAuth2Client.h"
#import "SLFetcher.h"

@interface SLAPIClient : NSObject

// Service basics
@property (nonatomic, strong) NSString *APIName;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, readonly) BOOL authenticated;

+ (SLAPIClient *)sharedClient;
	
// Authentication
- (void)initiateAuthorizationWithWebView:(UIWebView *)webView onCompletion:(AuthenticationCompletionBlock)completionBlock;
- (BOOL)resetAuthentication;

// Requests
- (void)get:(NSString *)getURLString onCompletion:(FetchCompletionBlock)completionBlock;
- (void)get:(NSString *)getURLString
		needsAuthentication:(BOOL)needsAuthentication
		onCompletion:(FetchCompletionBlock)completionBlock;

@end
