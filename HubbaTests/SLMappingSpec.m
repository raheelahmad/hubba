#import "SLMapping.h"
#import "SLRelationMapping.h"
#import "SLCoreDataManager.h"
#import "SLPropertyOnlyEntity.h"
#import "SLCoreDataStackTestsHelper.h"
#import "Kiwi.h"

// -----------------------------------

NSArray *buildEntities() {
	NSEntityDescription *descriptionForDummyClass = [[NSEntityDescription alloc] init];
	descriptionForDummyClass.name = NSStringFromClass([SLPropertyOnlyEntity class]);
	descriptionForDummyClass.managedObjectClassName = NSStringFromClass([SLPropertyOnlyEntity class]);
	NSAttributeDescription *nameDescription = [[NSAttributeDescription alloc] init];
	nameDescription.name = @"name";
	nameDescription.attributeType = NSStringAttributeType; nameDescription.attributeValueClassName = @"NSString";
	descriptionForDummyClass.properties = @[ nameDescription ];
	
	return @[ descriptionForDummyClass ];
}


SPEC_BEGIN(MappingSpecs)

describe(@"Property mapping", ^{
	beforeEach(^{
		NSArray *entities = buildEntities();
		setupStackWithEntities(entities);
	});
	
	it(@"#objectForRemoteInfo", ^{
		SLPropertyOnlyEntity *existingObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(SLPropertyOnlyEntity.class)
																			 inManagedObjectContext:[[SLCoreDataManager sharedManager] managedObjectContext]];
		existingObject.name = @"Raheel";
		
		SLManagedRemoteObject *foundObject = [SLPropertyOnlyEntity objectForRemoteInfo:@{ @"name" : @"Raheel" }];
		[theValue(foundObject) shouldNotBeNil];
		[[theValue([[foundObject valueForKey:@"name"] isEqualToString:@"Raheel"]) should] beTrue];
	});
	
	describe(@"#updateWithRemoteInfo", ^{
		__block NSFetchRequest *request;
		__block NSArray *objects;
		beforeEach(^{
			[SLPropertyOnlyEntity updateWithRemoteResponse:@{ @"name" : @"Raheel" }];
			request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(SLPropertyOnlyEntity.class)];
			objects = [[[SLCoreDataManager sharedManager] managedObjectContext] executeFetchRequest:request error:NULL];
		});
		
		it(@"should yield a new managed object", ^{
			[[theValue(objects.count) should] equal:theValue(1)];
		});
		
		it(@"should have a new managed object with properties set", ^{
			SLPropertyOnlyEntity *newDummy = objects[0];
			[[theValue(newDummy.name) should] equal:theValue(@"Raheel")];
		});
	});
});

SPEC_END