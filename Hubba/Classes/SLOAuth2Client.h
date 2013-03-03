//
//  SLOAuth2Client.h
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLOAuth2Client : NSObject <UIWebViewDelegate, NSURLConnectionDataDelegate>

+ (SLOAuth2Client *) sharedClient;
- (void)initiateAuthorizationWithWebView:(UIWebView *)webView;

// exposing for testing
- (NSString *)codeFromRequest:(NSURLRequest *)request;
- (NSURLRequest *)tokenRequestForCode:(NSString *)code;
- (NSURLRequest *)authorizationRequest;

BOOL isTemporaryCodeRequest(NSURLRequest *request);
	
@end
