//
//  UIColor+fromHex.h
//  Hawk
//
//  Created by Savla, Sumit on 7/13/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (fromHex)
+ (UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
@end
