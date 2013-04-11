//
//  SLCoreDataStackTestsHelper.h
//  Hubba
//
//  Created by Raheel Ahmad on 3/31/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//
extern NSString * const kAttributeNameKey;
extern NSString * const kAttributeTypeNumKey;
extern NSString * const kAttributeClassNameKey;
extern NSString * const kRelationshipSourceKey;
extern NSString * const kRelationshipDestinationKey;
extern NSString * const kRelationshipForwardNameKey;
extern NSString * const kRelationshipReverseNameKey;
extern NSString * const kRelationshipHasManyNumKey;

extern void setupStackWithEntities(NSArray *entities);

extern NSEntityDescription *setupEntity(NSString *entityName, Class entityClass, NSArray *attributesInfo, NSArray *relationshipsInfo);
extern void addRelationships(NSEntityDescription *source, NSEntityDescription *destination,
					  NSString *forwardName, NSString *reverseName, BOOL toMany);
extern NSAttributeDescription *attributeDescriptionForName(NSString *attributeName, NSAttributeType attributeType, NSString *attributeClassName);
