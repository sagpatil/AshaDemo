//
//  Event.h
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/5/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface Event : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *ticketUrl;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSDate *eventTime;
@property (nonatomic, strong) UIImage *eventImage;
@property (nonatomic, strong) NSDictionary *pricingInfo;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *colorHighlight;
@property (nonatomic, strong) NSString *colorShadow;

- (id)initWithDictionary:(NSDictionary *)object;
@end
