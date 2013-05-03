//
//  SLURLRequest.h
//  Hubba
//
//  Created by Raheel Ahmad on 4/26/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PARSE_OUTPUT) {
	NO_PARSED_OUTPUT,
	JSON_PARSED_OUTPUT,
	NSSTRING_PARSED_OUTPUT
};

@interface SLURLRequest : NSMutableURLRequest

@property (nonatomic, assign) PARSE_OUTPUT parseOption;

+ (SLURLRequest *)requestWithURL:(NSURL *)URL;

@end
