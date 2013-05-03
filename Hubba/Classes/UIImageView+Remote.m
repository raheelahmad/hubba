//
//  UIImage+Remote.m
//  Hubba
//
//  Created by Raheel Ahmad on 4/25/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "UIImageView+Remote.h"
#import "SLFetcher.h"
#import "SLURLRequest.h"
#import "SLImageCache.h"
#import <objc/runtime.h>

@implementation UIImageView (Remote)

- (void)setupWithImageAtURL:(NSString *)URLString {
	UIImage *image = [SLImageCache imageForURLString:URLString];
	if (image) {
		self.image = image;
		return;
	}
	
	SLURLRequest *request = [SLURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	request.parseOption = NO_PARSED_OUTPUT;
	[SLFetcher request:request completion:^(BOOL success, id response) {
		UIImage *image = [UIImage imageWithData:response];
		[SLImageCache setImage:image forURLString:URLString];
		self.image = image;
	}];
}

@end
