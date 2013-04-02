#import "SLMapping.h"
#import "SLRelationMapping.h"
#import "SLCoreDataManager.h"
#import "SLPropertyOnlyEntity.h"
#import "SLCoreDataStackTestsHelper.h"
#import "Kiwi.h"

// -----------------------------------

NSAttributeDescription *attributeDescriptionForName(NSString *attributeName, NSString *attributeClassName) {
	NSAttributeDescription *description = [[NSAttributeDescription alloc] init];
	description.name = attributeName;
	description.attributeType = NSStringAttributeType; description.attributeValueClassName = attributeClassName;
	return description;
}

NSArray *buildEntities() {
	NSEntityDescription *descriptionForDummyClass = [[NSEntityDescription alloc] init];
	descriptionForDummyClass.name = NSStringFromClass([SLPropertyOnlyEntity class]);
	descriptionForDummyClass.managedObjectClassName = NSStringFromClass([SLPropertyOnlyEntity class]);
	descriptionForDummyClass.properties = @[ attributeDescriptionForName(@"name", @"NSString"),  attributeDescriptionForName(@"remoteID", @"NSNumber")  ];
	
	return @[ descriptionForDummyClass ];
}


SPEC_BEGIN(MappingSpecs)

describe(@"Property mapping", ^{
	
	it(@"should provide correct local predicate for given remote object info", ^{
		NSDictionary *remoteObject = @{ @"id" : @(1234), @"name" : @"Salim" };
		NSComparisonPredicate *predicate = (NSComparisonPredicate *) [[SLPropertyOnlyEntity remoteMapping] localPredicateForRemoteObject:remoteObject];
		[[predicate.leftExpression.keyPath should] equal:@"remoteID"];
		NSLog(@"predicate: %@", predicate.rightExpression.constantValue);
		[[predicate.rightExpression.constantValue should] equal:@(1234)];
	});
	
	context(@"Remote update", ^{
		beforeEach(^{
			NSArray *entities = buildEntities();
			setupStackWithEntities(entities);
			SLPropertyOnlyEntity *existingObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(SLPropertyOnlyEntity.class)
																				 inManagedObjectContext:[[SLCoreDataManager sharedManager] managedObjectContext]];
			existingObject.name = @"Raheel";
			existingObject.remoteID = @(1234);
			
			SLPropertyOnlyEntity *anotherExistingObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(SLPropertyOnlyEntity.class)
																				 inManagedObjectContext:[[SLCoreDataManager sharedManager] managedObjectContext]];
			anotherExistingObject.name = @"Raheel";
			anotherExistingObject.remoteID = @(5234);
			
		});
		
		it(@"should find the existing local object for given remote info", ^{
			NSDictionary *remoteObjectInfo = @{ @"name" : @"Updated Raheel", @"id" : @(1234) };
			SLManagedRemoteObject *foundObject = [[SLPropertyOnlyEntity remoteMapping] objectForRemoteInfo:remoteObjectInfo];
			[foundObject shouldNotBeNil];
			[[[foundObject valueForKey:@"name"] should] equal:@"Raheel"]; // should be the local property value, as we haven't updated it here
		});
		
		it(@"should give a new local object when given remote info for an object that doesn't exist locally", ^{
			NSDictionary *remoteObjectInfo = @{ @"name" : @"Updated Raheel", @"id" : @(2333) };
			SLManagedRemoteObject *newObject = [[SLPropertyOnlyEntity remoteMapping] objectForRemoteInfo:remoteObjectInfo];
			[newObject shouldNotBeNil];
			[[newObject valueForKey:@"name"] shouldBeNil];
			[[[newObject valueForKey:@"remoteID"] should] equal:@(2333)]; // only the unique property should be set
		});
		
		/**
		describe(@"#updateWithRemoteInfo", ^{
			__block NSFetchRequest *request;
			__block NSArray *objects;
			beforeEach(^{
				[[SLPropertyOnlyEntity remoteMapping] updateWithRemoteResponse:@{ @"name" : @"Raheel", @"id" : @"1234" }];
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
		 **/
	});
});

SPEC_END