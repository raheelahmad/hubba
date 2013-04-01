#import "Kiwi.h"
#import "SLCoreDataManager.h"
#import "SLCoreDataStackTestsHelper.h"

SPEC_BEGIN(CoreDataStackSetup)

describe(@"Core Data stack", ^{
	beforeEach(^{
		setupStackWithEntities(nil);
	});
	it(@"should be set up properly", ^{
		[[theValue([[SLCoreDataManager sharedManager] managedObjectContext]) shouldNot] beNil];
		[[theValue([[SLCoreDataManager sharedManager] managedObjectModel]) shouldNot] beNil];
		[[theValue([[SLCoreDataManager sharedManager] persistentStoreCoordinator]) shouldNot] beNil];
	});
});

SPEC_END

