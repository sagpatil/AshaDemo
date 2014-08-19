//
//  Project.h
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/6/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Project : NSObject
@property (nonatomic, strong) NSNumber *projectId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *projectImage;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *purpose;
@property (nonatomic, strong) NSString *orgDescription;
@property (nonatomic, strong) NSString *area;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDate *year;
@property (nonatomic, strong) NSString *fundsDonated;
@property (nonatomic, strong) NSString *chapter;
@property (nonatomic, strong) NSNumber *projectType;
@property (nonatomic, strong) NSNumber *focus;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *colorHighlight;
@property (nonatomic, strong) NSString *colorShadow;


- (id)initWithDictionary:(NSDictionary *)object;
+ (NSArray *) TYPES;
+ (NSArray *) PRIMARY_FOCUSES;
+ (NSArray *) AREAS;
+ (NSMutableArray *) CHAPTERS;
@end
