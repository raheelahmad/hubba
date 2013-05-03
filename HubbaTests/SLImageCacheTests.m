//
//  SLImageCacheTests.m
//  Hubba
//
//  Created by Raheel Ahmad on 5/3/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLImageCacheTests.h"
#import "SLImageCache.h"

@implementation SLImageCacheTests

- (void)testImageCache {
	NSString *testImageURLString = @"http://sakunlabs.com/test_image.png";
	UIImage *testImage = [UIImage imageNamed:@"TestImage.png"];
	
	STAssertTrue(testImage.size.width > 0, @"Test iamge should have a width");
	
	[SLImageCache setImage:testImage forURLString:testImageURLString];
	UIImage *cachedImage = [SLImageCache imageForURLString:testImageURLString];
	
	NSLog(@"Test: %@; Cached: %@", @(testImage.size.width), @(cachedImage.size.width));
	
	STAssertEqualsWithAccuracy(cachedImage.size.height, testImage.size.height, 0.5f, @"Cache and test images should have same height");
	STAssertEqualsWithAccuracy(cachedImage.size.width, testImage.size.width, 0.5f, @"Cache and test images should have same width");
	
	STAssertNoThrow([SLImageCache setImage:nil forURLString:nil], @"Setter should not throw an exception for nil params");
	STAssertNoThrow([SLImageCache imageForURLString:nil], @"Getter should not throw an exception for nil params");
}

@end
