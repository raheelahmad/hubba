//
//  SLImageCache.h
//  Hubba
//
//  Created by Raheel Ahmad on 5/2/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLImageCache : NSObject
+ (void)setImage:(UIImage *)image forURLString:(NSString *)URLString;
+ (UIImage *)imageForURLString:(NSString *)URLString;
@end
