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
#import <objc/runtime.h>

@implementation UIImageView (Remote)

- (void)setupWithImageAtURL:(NSString *)URLString completion:(void (^) (UIImage *))completion {
	SLURLRequest *request = [SLURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	request.parseOption = NO_PARSED_OUTPUT;
	[SLFetcher request:request completion:^(BOOL success, id response) {
		UIImage *image = [UIImage imageWithData:response];
		self.image = image;
	}];
}

@end
