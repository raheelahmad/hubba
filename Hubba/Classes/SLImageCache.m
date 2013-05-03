//
//  SLImageCache.m
//  Hubba
//
//  Created by Raheel Ahmad on 5/2/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLImageCache.h"

@interface SLImageCache ()
@end

@implementation SLImageCache

static NSMutableDictionary *imageCacheForURLString;

+ (void)initialize {
	imageCacheForURLString = [NSMutableDictionary dictionaryWithCapacity:10];
}

+ (void)setImage:(UIImage *)image forURLString:(NSString *)URLString {
	if (!image || !URLString) {
		return;
	}
	
	[imageCacheForURLString setValue:image forKey:URLString];
}

+ (UIImage *)imageForURLString:(NSString *)URLString {
	return imageCacheForURLString[URLString];
}

@end
