#import "Kiwi.h"

#import "SLUser.h"
#import "SLMapping.h"
#import "SLRelationMapping.h"
#import "SLCoreDataManager.h"

@interface SLPropertyOnlyEntity : SLManagedRemoteObject
@property (strong) NSString *name;
@end

@implementation SLPropertyOnlyEntity
@dynamic name;

+ (SLMapping *)remoteMapping {
	SLMapping *mapping = [[SLMapping alloc] init];
	mapping.endPoint = @"/dummy";
	mapping.pathToObject = nil;
	mapping.appearsAsCollection = NO;
	mapping.localToRemoteMapping = @{
								     @"name" : @"name"
			 };
	return mapping;
}

+ (NSPredicate *)localPredicateForRemoteObject:(NSDictionary *)remoteObject {
	return [NSPredicate predicateWithFormat:@"name = %@", remoteObject[@"name"]];
}

@end

SPEC_BEGIN(MappingSpecs)

describe(@"Mapping", ^{
	beforeAll(^{
		NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
		NSEntityDescription *descriptionForDummyClass = [[NSEntityDescription alloc] init];
		descriptionForDummyClass.name = NSStringFromClass([SLPropertyOnlyEntity class]);
		descriptionForDummyClass.managedObjectClassName = NSStringFromClass([SLPropertyOnlyEntity class]);
		NSAttributeDescription *nameDescription = [[NSAttributeDescription alloc] init];
		nameDescription.name = @"name";
		nameDescription.attributeType = NSStringAttributeType; nameDescription.attributeValueClassName = @"NSString";
		descriptionForDummyClass.properties = @[ nameDescription ];
		[model setEntities:@[ descriptionForDummyClass ]];
		NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
		[coordinator addPersistentStoreWithType:NSInMemoryStoreType
											configuration:nil
													  URL:nil
												  options:nil
													error:NULL];
		NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[context setPersistentStoreCoordinator:coordinator];
		[[SLCoreDataManager sharedManager] setManagedObjectContext:context];
		[[SLCoreDataManager sharedManager] setManagedObjectModel:model];
		[[SLCoreDataManager sharedManager] setPersistentStoreCoordinator:coordinator];
	});
	
	it(@"Core Data stack setup", ^{
		[theValue([[SLCoreDataManager sharedManager] managedObjectModel]) shouldNotBeNil];
		[theValue([[SLCoreDataManager sharedManager] persistentStoreCoordinator]) shouldNotBeNil];
		[theValue([[SLCoreDataManager sharedManager] managedObjectContext]) shouldNotBeNil];
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
		beforeAll(^{
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