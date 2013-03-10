//
//  SLOAuth2Client.h
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AuthenticationCompletionBlock) (BOOL success);

@interface SLOAuth2Client : NSObject <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSString *APIName;
@property (readonly) BOOL authenticated;

- (id)initWithAPIName:(NSString *)APIName;
- (void)initiateAuthorizationWithWebView:(UIWebView *)webView onCompletion:(AuthenticationCompletionBlock)completionBlock;
- (BOOL)resetAuthentication; // aka, logout

// exposing for testing
- (NSString *)codeFromRequest:(NSURLRequest *)request;
- (NSURLRequest *)tokenRequestForCode:(NSString *)code;
- (NSURLRequest *)authorizationRequest;
- (NSString *)accessTokenFromResponse:(NSString *)response;
BOOL isTemporaryCodeRequest(NSURLRequest *request);
	
@end
