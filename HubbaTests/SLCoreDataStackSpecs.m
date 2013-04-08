#import "SLCoreDataManager.h"
#import "SLCoreDataStackTestsHelper.h"
#import "Kiwi.h"
#import "SLPerson.h"
#import "SLCompany.h"

NSArray *buildEntities() {
	NSArray *personAttributesInfo = @[
									@{ kAttributeNameKey: @"name", kAttributeTypeNumKey : @(NSStringAttributeType), kAttributeClassNameKey : @"NSString" },
									@{ kAttributeNameKey: @"remoteID", kAttributeTypeNumKey : @(NSInteger32AttributeType), kAttributeClassNameKey : @"NSNumber" }
							];
	NSEntityDescription *personEntity = setupEntity(@"SLPerson", [SLPerson class], personAttributesInfo, nil);
	
	NSArray *companyAttributesInfo = @[
									@{ kAttributeNameKey: @"title", kAttributeTypeNumKey : @(NSStringAttributeType), kAttributeClassNameKey : @"NSString" },
									@{ kAttributeNameKey: @"address", kAttributeTypeNumKey : @(NSStringAttributeType), kAttributeClassNameKey : @"NSString" },
									@{ kAttributeNameKey: @"id", kAttributeTypeNumKey : @(NSInteger32AttributeType), kAttributeClassNameKey : @"NSNumber" }
							];
	NSArray *companyRelationshipsInfo = @[
								@{	kRelationshipDestinationKey : personEntity,
		   kRelationshipForwardNameKey	: @"persons",
		   kRelationshipReverseNameKey : @"company",
		   kRelationshipHasManyNumKey	: @(YES),
		   }
		];
	
	NSEntityDescription *companyEntity = setupEntity(@"SLCompany", [SLCompany class], companyAttributesInfo, companyRelationshipsInfo);
	
	return @[ companyEntity, personEntity ];
}

SPEC_BEGIN(CoreDataStackSetup)

describe(@"Core Data stack", ^{
	it(@"should be set up properly", ^{
		setupStackWithEntities(nil);
		[[theValue([[SLCoreDataManager sharedManager] managedObjectContext]) shouldNot] beNil];
		[[theValue([[SLCoreDataManager sharedManager] managedObjectModel]) shouldNot] beNil];
		[[theValue([[SLCoreDataManager sharedManager] persistentStoreCoordinator]) shouldNot] beNil];
	});
	
	it(@"should be set up with provided entities", ^{
		setupStackWithEntities(buildEntities()); // with SLPerson and SLCompany
		
		// now let's query the stack for the entities it knows about
		NSDictionary *entitiesByName = [[[SLCoreDataManager sharedManager] managedObjectModel] entitiesByName];
		
		[[theValue(entitiesByName.count) should] equal:theValue(2)];
		
		[[[entitiesByName allKeys] should] contain:@"SLCompany"];
		[[[entitiesByName allKeys] should] contain:@"SLPerson"];
		
		[entitiesByName enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			if ([key isEqualToString:@"SLPerson"]) {
				NSEntityDescription *personEntity = (NSEntityDescription *)obj;
				// attributes
				[[[personEntity.attributesByName allKeys] should] contain:@"name"];
				[[[personEntity.attributesByName allKeys] should] contain:@"remoteID"];
				// relationships
				[[[personEntity.relationshipsByName allKeys] should] contain:@"company"];
			} else if ([key isEqualToString:@"SLCompany"]) {
				NSEntityDescription *companyEntity = (NSEntityDescription *)obj;
				// attributes
				[[[companyEntity.propertiesByName allKeys] should] contain:@"title"];
				[[[companyEntity.propertiesByName allKeys] should] contain:@"id"];
				[[[companyEntity.propertiesByName allKeys] should] contain:@"address"];
				// relationships
				[[[companyEntity.relationshipsByName allKeys] should] contain:@"persons"];
			}
		}];
	});
	
	it(@"should set up the entity relationships properly", ^{
		setupStackWithEntities(buildEntities());
		NSEntityDescription *company = [NSEntityDescription entityForName:@"SLCompany"
					inManagedObjectContext:[[SLCoreDataManager sharedManager] managedObjectContext]];
		NSEntityDescription *person = [NSEntityDescription entityForName:@"SLPerson"
					inManagedObjectContext:[[SLCoreDataManager sharedManager] managedObjectContext]];
		[company shouldNotBeNil];
		[person shouldNotBeNil];
		
		NSArray *companyRelationships = [company.relationshipsByName allKeys];
		[[companyRelationships should] contain:@"persons"];
		NSArray *personRelationships = [person.relationshipsByName allKeys];
		[[personRelationships should] contain:@"company"];
	});
	
});

SPEC_END

