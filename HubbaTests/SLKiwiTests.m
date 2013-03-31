#import "Kiwi.h"

SPEC_BEGIN(MathSpec)

describe(@"Math", ^{
	it(@"is pretty cool", ^{
		NSUInteger a = 31;
		NSUInteger b = 12;
		[[theValue(a + b) should] equal:theValue(43)];
	});
});

SPEC_END