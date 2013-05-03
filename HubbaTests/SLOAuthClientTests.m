//
//  SLOAuthClientTests.m
//  Hubba
//
//  Created by Raheel Ahmad on 2/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLOAuthClientTests.h"
#import "SLOAuth2Client.h"
#import "SLURLRequest.h"

@interface SLOAuthClientTests ()
@property (nonatomic, strong) SLOAuth2Client *client;
@end

@implementation SLOAuthClientTests

- (void)testCheckForTokenRequest {
	NSURLRequest *request = [self requestForTokenWithCode:@"casjkdka"]; // includes the temporary code
	STAssertTrue(isTemporaryCodeRequest(request), @"A redirected request with the code should be recognized");
	NSURLRequest *incorrectRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token?client_id=0cd6f03185bbf7def542&client_secret=a2ca98bb09b0b95ef284d87515d84bde6db9194c&code=10b46b94b74be46d755e"]];
	STAssertFalse(isTemporaryCodeRequest(incorrectRequest), @"A POST request with code should not be parsed as token request");
}

- (void)testTokenParsingFromResponse {
	NSString *response = @"access_token=868d3eefad5a046607bb31a5a3089329977397ff&token_type=bearer";
	NSString *anotherResponse = @"token_type=bearer&access_token=868d3eefad5a046607bb31a5a3089329977397ff";
	STAssertTrue([[self.client accessTokenFromResponse:response] isEqualToString:@"868d3eefad5a046607bb31a5a3089329977397ff"],
				 @"Access token should be parsed properly from the response");
	STAssertTrue([[self.client accessTokenFromResponse:anotherResponse] isEqualToString:@"868d3eefad5a046607bb31a5a3089329977397ff"],
				 @"Access token should be parsed properly from the response");
}

- (void)testCodeParsingFromRequest {
	NSString *code = @"asjdhkjasd";
	NSURLRequest *request = [self requestForTokenWithCode:code];
	STAssertTrue([code isEqualToString:[self.client codeFromRequest:request]], @"Code should be correctly parsed from a request");
}

- (void)testTokenRequest {
	NSString *code = @"abcdefg";
	NSString *HTTPBody = [[NSString alloc] initWithData:[self.client tokenRequestForCode:code].HTTPBody encoding:NSUTF8StringEncoding];
	NSRange codeRange = [HTTPBody rangeOfString:code];
	STAssertTrue(codeRange.location < HTTPBody.length, @"Code should be in the token request");
}

- (void)testAuthorizationRequest {
	SLURLRequest *request = [self.client authorizationRequest];
	NSString *string = [request.URL absoluteString];
	NSArray *componentsWithClientId = [string componentsSeparatedByString:@"client_id="];
	STAssertEquals(componentsWithClientId.count, (NSUInteger)2, @"URL should be splittable by client_id");
	NSString *clientId = componentsWithClientId[1];
	STAssertNotNil(clientId, @"Client id should not be nil");
}

#pragma mark - Helpers

- (NSURLRequest *)requestForTokenWithCode:(NSString *)code {
	NSString *URLString = [NSString stringWithFormat:@"https://sakunlabs.com/oauth2_could_be_anything_really?code=%@", code];
	NSURL *url = [NSURL URLWithString:URLString];
	return [[NSURLRequest alloc] initWithURL:url];
}

- (void)setUp {
	self.client = [[SLOAuth2Client alloc] init];
}

@end
