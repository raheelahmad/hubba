#import "Kiwi.h"
#import "SLCoreDataManager.h"
#import "SLCoreDataStackTestsHelper.h"

SPEC_BEGIN(CoreDataStackSetup)

describe(@"Core Data stack", ^{
	it(@"should be set up properly", ^{
		setupStackWithEntities(nil);
		[[theValue([[SLCoreDataManager sharedManager] managedObjectContext]) shouldNot] beNil];
		[[theValue([[SLCoreDataManager sharedManager] managedObjectModel]) shouldNot] beNil];
		[[theValue([[SLCoreDataManager sharedManager] persistentStoreCoordinator]) shouldNot] beNil];
	});
	
	it(@"should be set up with provided entities", ^{
		NSEntityDescription *descriptionForDummyClass = [[NSEntityDescription alloc] init];
		descriptionForDummyClass.name = @"DummyClass";
		descriptionForDummyClass.managedObjectClassName = @"DummyClass";
		NSAttributeDescription *nameDescription = [[NSAttributeDescription alloc] init];
		nameDescription.name = @"name";
		nameDescription.attributeType = NSStringAttributeType; nameDescription.attributeValueClassName = @"NSString";
		descriptionForDummyClass.properties = @[ nameDescription ];
		
		setupStackWithEntities(@[ descriptionForDummyClass ]);
		
		NSDictionary *entitiesByName = [[[SLCoreDataManager sharedManager] managedObjectModel] entitiesByName];
		[[theValue(entitiesByName.count) should] equal:theValue(1)];
		NSString *firstEntityName = [entitiesByName allKeys][0];
		[[theValue([firstEntityName isEqualToString:@"DummyClass"]) should] beTrue];
	});
});

SPEC_END

