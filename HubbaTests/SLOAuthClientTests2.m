#import "Kiwi.h"
#import "SLOAuth2Client.h"

SPEC_BEGIN(OAuthClientTests)

describe(@"Authentication Code", ^{
	__block SLOAuth2Client *client;
	
	beforeAll(^{
		client = [[SLOAuth2Client alloc] init];
	});
	
	describe(@"should detect an authorization request", ^{
		__block NSArray *componentsWithClientId = nil;
		beforeAll(^{
			NSURLRequest *request = [client authorizationRequest];
			NSString *string = [request.URL absoluteString];
			componentsWithClientId = [string componentsSeparatedByString:@"client_id="];
		});
		
		it(@"should split the URL by client_id", ^{
			[[theValue(componentsWithClientId.count) should] equal:theValue(2)];
		});
		it(@"should have a non-nil client id", ^{
			NSString *clientId = componentsWithClientId[1];
			[theValue(clientId) shouldNotBeNil];
		});
	});
});

SPEC_END