//
//  SLOAuth2Client.h
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLOAuth2Client : NSObject <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSString *APIName;

+ (SLOAuth2Client *) sharedClientWithAPIName:(NSString *)APIName;
- (void)initiateAuthorizationWithWebView:(UIWebView *)webView;

// exposing for testing
- (NSString *)codeFromRequest:(NSURLRequest *)request;
- (NSURLRequest *)tokenRequestForCode:(NSString *)code;
- (NSURLRequest *)authorizationRequest;
- (NSString *)accessTokenFromResponse:(NSString *)response;
BOOL isTemporaryCodeRequest(NSURLRequest *request);
	
@end
