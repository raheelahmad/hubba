//
//  SLAPIClient.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/9/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLOAuth2Client.h"

@interface SLAPIClient : NSObject

// Service basics
@property (nonatomic, strong) NSString *APIName;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, readonly) BOOL authenticated;

+ (SLAPIClient *)sharedClientWithAPIName:(NSString *)APIName baseURL:(NSString *)baseURL;

- (void)initiateAuthorizationWithWebView:(UIWebView *)webView onCompletion:(AuthenticationCompletionBlock)completionBlock;
- (BOOL)resetAuthentication;
	
@end
