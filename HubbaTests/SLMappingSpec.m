#import "SLMapping.h"
#import "SLRelationMapping.h"
#import "SLCoreDataManager.h"
#import "SLPerson.h"
#import "SLCompany.h"
#import "SLCoreDataStackTestsHelper.h"
#import "Kiwi.h"

// -----------------------------------

static NSArray *buildEntities() {
	NSEntityDescription *personEntity = [[NSEntityDescription alloc] init];
	personEntity.name = NSStringFromClass([SLPerson class]);
	personEntity.managedObjectClassName = NSStringFromClass([SLPerson class]);
	personEntity.properties = @[ attributeDescriptionForName(@"name", NSStringAttributeType, @"NSString"),  attributeDescriptionForName(@"remoteID", NSInteger32AttributeType, @"NSNumber")  ];
	
	NSEntityDescription *companyEntity = [[NSEntityDescription alloc] init];
	companyEntity.name = NSStringFromClass([SLCompany class]);
	companyEntity.managedObjectClassName = NSStringFromClass([SLCompany class]);
	companyEntity.properties = @[ attributeDescriptionForName(@"title", NSStringAttributeType, @"NSString"),
							   attributeDescriptionForName(@"address", NSStringAttributeType, @"NSString"),
							   attributeDescriptionForName(@"id", NSInteger32AttributeType, @"NSNumber")  ];
	
	addRelationships(companyEntity, personEntity, @"persons", @"company", YES);
	
	return @[ companyEntity, personEntity ];
}


SPEC_BEGIN(MappingSpecs)

describe(@"Property mapping", ^{
	
	it(@"should provide correct local predicate for given remote object info", ^{
		NSDictionary *remoteObject = @{ @"id" : @(1234), @"name" : @"Salim" };
		NSComparisonPredicate *predicate = (NSComparisonPredicate *) [[SLPerson remoteMapping] localPredicateForRemoteObject:remoteObject];
		[[predicate.leftExpression.keyPath should] equal:@"remoteID"];
		[[predicate.rightExpression.constantValue should] equal:@(1234)];
	});
	
	describe(@"#updateWithRemoteInfo for attributes", ^{
		__block NSArray *objects;
		beforeEach(^{
			setupStackWithEntities(buildEntities());
			[[SLPerson remoteMapping] updateWithRemoteResponse:@{ @"name" : @"Someone really new", @"id" : @(4522),
																 @"company" : @{
																	 @"title" : @"Fitbit Inc.",
																	 @"address" : @"150 Spear St.",
																	 @"id" : @(333)
																 },
			 }];
			NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(SLPerson.class)];
			objects = [[[SLCoreDataManager sharedManager] managedObjectContext] executeFetchRequest:request error:NULL];
		});
		
		it(@"should yield a new managed object", ^{
			[[theValue(objects.count) should] equal:theValue(1)];
		});
		
		it(@"should have a new managed object with properties set", ^{
			SLPerson *newPerson = objects[0];
			[[newPerson.name should] equal:@"Someone really new"];
			[[newPerson.remoteID should] equal:@(4522)];
		});
		
		it(@"should update relationships", ^{
			SLPerson *newPerson = objects[0];
			NSLog(@"99999999999999999999999999 Company: %@", newPerson.company);
			id company = newPerson.company;
			[company shouldNotBeNil];
//			[[company.title should] equal:@"Fitbit Inc."];
//			[[company.address should] equal:@"150 Spear St."];
//			[[company.id should] equal:@(333)];
		});
		
		it(@"should handle mocks properly", ^{
			[SLPerson stub:@selector(remoteMapping) andReturn:@(22)];
//			NSLog(@"00000000000000000 %@", [personMock remoteMapping]);
			[[[SLPerson remoteMapping] should] equal:@(22)];
		});
	});
	
	context(@"#objectForRemoteInfo", ^{
		beforeEach(^{
			setupStackWithEntities(buildEntities());
			SLPerson *existingObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(SLPerson.class)
																				 inManagedObjectContext:[[SLCoreDataManager sharedManager] managedObjectContext]];
			existingObject.name = @"Raheel";
			existingObject.remoteID = @(1234);
			
			SLPerson *anotherExistingObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(SLPerson.class)
																				 inManagedObjectContext:[[SLCoreDataManager sharedManager] managedObjectContext]];
			anotherExistingObject.name = @"Raheel";
			anotherExistingObject.remoteID = @(5234);
			
		});
		
		it(@"should find the existing local object for given remote info", ^{
			NSDictionary *remoteObjectInfo = @{ @"name" : @"Updated Raheel", @"id" : @(1234) };
			SLManagedRemoteObject *foundObject = [[SLPerson remoteMapping] objectForRemoteInfo:remoteObjectInfo];
			[foundObject shouldNotBeNil];
			[[[foundObject valueForKey:@"name"] should] equal:@"Raheel"]; // should be the local property value, as we haven't updated it here
		});
		
		it(@"should give a new local object when given remote info for an object that doesn't exist locally", ^{
			NSDictionary *remoteObjectInfo = @{ @"name" : @"Someone New", @"id" : @(2333) };
			SLManagedRemoteObject *newObject = [[SLPerson remoteMapping] objectForRemoteInfo:remoteObjectInfo];
			[newObject shouldNotBeNil];
			[[newObject valueForKey:@"name"] shouldBeNil];
			[[[newObject valueForKey:@"remoteID"] should] equal:@(2333)]; // only the unique property should be set
		});
		
	});
});

SPEC_END