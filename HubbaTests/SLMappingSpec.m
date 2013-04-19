#import "SLMapping.h"
#import "SLRelationMapping.h"
#import "SLCoreDataManager.h"
#import "SLPerson.h"
#import "SLCompany.h"
#import "SLDepartment.h"
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
	
	NSEntityDescription *departmentEntity = [[NSEntityDescription alloc] init];
	departmentEntity.name = NSStringFromClass([SLDepartment class]);
	departmentEntity.managedObjectClassName = NSStringFromClass([SLDepartment class]);
	departmentEntity.properties = @[ attributeDescriptionForName(@"name", NSStringAttributeType, @"NSString") ];
	
	addRelationships(companyEntity, personEntity, @"persons", @"company", YES, NO);
	addRelationships(companyEntity, departmentEntity, @"departments", @"company", YES, NO);
	addRelationships(companyEntity, personEntity, @"previousEmployees", @"previousCompany", YES, NO);
	addRelationships(personEntity, companyEntity, @"desirableCompanies", @"peopleThinkWeAreDesirable", YES, YES);
	
	return @[ companyEntity, personEntity, departmentEntity ];
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
			
			// for testing updates in the "main" endpoint
			
			SLMapping *mapping = [[SLMapping alloc] init];
			mapping.endPoint = @"/dummy";
			mapping.pathToObject = nil;
			mapping.appearsAsCollection = NO;
			mapping.modelClass = self;
			
			mapping.propertyMappings = @{
											 @"name" : @"name",
											 @"remoteID" : @"id",
											 @"company" : @"company",
					 };
			mapping.uniquePropertyMapping = @{ kLocalUniquePropertyKey : @"remoteID", kRemoteUniquePropertyKey : @"id" };
			[[SLPerson remoteMapping] updateWithRemoteResponse:@{ @"name" : @"Someone really new", @"id" : @(4522),
																	@"company" : @{
																	 @"title" : @"Fitbit Inc.",
																	 @"address" : @"150 Spear St.",
																	 @"id" : @(333),
																	 @"departments" : @[
																	 @{ @"name" : @"Development" },
																	 @{ @"name" : @"Design" },
																	]
																 }
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
		
		it(@"should update a to-one relationship that is included in the main response", ^{
			SLPerson *newPerson = objects[0];
			SLCompany *company = newPerson.company;
			[company shouldNotBeNil];
			[[company.title should] equal:@"Fitbit Inc."];
			[[company.address should] equal:@"150 Spear St."];
			[[company.id should] equal:@(333)];
		});
		
		it(@"should update a to-many relationship that is included in the main response", ^{
			SLPerson *newPerson = objects[0];
			SLCompany *company = newPerson.company;
			NSSet *departments = company.departments;
			[[theValue(departments.count) should] equal:theValue(2)];
		});
		
		it(@"should update a to-one relationship at a different endpoint from the main", ^{
			// for testing relationship updates that require a separate endpoint
			SLPerson *newPerson = objects[0];
			SLRelationMapping *perviousCompanyMapping = [newPerson relationshipMappings][0]; // the first one is the to-one relationship
			
			[perviousCompanyMapping updateWithRemoteResponse:@{
			 @"title" : @"Manchester U.", @"address" : @"604 E. College Ave.", @"id" : @(332)
			 }];
			
			[newPerson.previousCompany shouldNotBeNil];
			[[newPerson.previousCompany.title should] equal:@"Manchester U."];
			[[newPerson.previousCompany.address should] equal:@"604 E. College Ave."];
			[[newPerson.previousCompany.id should] equal:@(332)];
			[[newPerson.previousCompany.previousEmployees should] contain:newPerson];
		});
		
		it(@"should update a to-many relationship at a different endpoint from the main", ^{
			SLPerson *newPerson = objects[0];
			SLRelationMapping *desirableCompaniesMapping = [newPerson relationshipMappings][1]; // the to-many relationship
			[desirableCompaniesMapping updateWithRemoteResponse:@[
			 @{@"title":@"Manchester U.", @"address":@"604 E. College Ave.", @"id":@(332)},
			 @{@"title":@"Fitbit", @"address":@"150 Spear St.", @"id":@(212)}
			 ]
			 ];
			[[theValue(newPerson.desirableCompanies.count) should] equal:theValue(2)];
			[[[newPerson.desirableCompanies valueForKey:@"title"] should] contain:@"Manchester U."];
			[[[newPerson.desirableCompanies valueForKey:@"title"] should] contain:@"Fitbit"];
		});
		
		it(@"should handle mocks properly", ^{
			[SLPerson stub:@selector(remoteMapping) andReturn:@(22)];
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