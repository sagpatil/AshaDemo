//
//  Project.m
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/6/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "Project.h"
#import <Parse/Parse.h>

@implementation Project
- (id)initWithDictionary:(NSDictionary *)object{
    
    self = [super init];
    if (self) {
        self.name = object[@"Name"];
        self.address = object [@"Address"];
        self.projectId  = object[@"project_id"];
        self.description  = object[@"Description"];
        self.purpose  = object[@"Purpose"];
        self.orgDescription  = object[@"Org_Description"];
        self.projectType  = object[@"Project_type"];
        self.focus  = object[@"Focus"];
        self.area  = object[@"Area"];
        self.chapter  = object[@"Chapter"];
        self.year  = object[@"Year"];
        self.status = object[@"Status"];
        self.fundsDonated = object[@"Funds_donated"];
        PFFile *userImageFile = object[@"Image"];
        NSData *imageData = [userImageFile getData];
        self.projectImage = [UIImage imageWithData:imageData];
//        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//            if (!error) {
//                self.projectImage = [UIImage imageWithData:imageData];
//            }
//        }];
        self.color = object[@"color"];
        self.colorHighlight = object[@"color_highlight"];
        self.colorShadow = object[@"color_shadow"];
    }
    return self;
}

+ (NSArray *)TYPES
{
    static NSArray *types = nil;
    if (!types) {
        types = @[@"Alternative Education", @"Child Home", @"Community Awareness", @"Community Based Interventions", @"Disabilities", @"Educational Experiments", @"Fellowships", @"Formal Schools", @"Internships", @"Non-Formal Educational Centers", @"One Time / Infrastructure", @"Other", @"Pre-Primary", @"Residential School" , @"Resource Centers", @"Special Needs", @"Support a Child", @"Tuition Centers", @"Vocational Training", @"Government Projects"];
    }
    
    return types;
}

+ (NSArray *)PRIMARY_FOCUSES
{
    static NSArray *primaryFocuses = nil;
    if (!primaryFocuses) {
        primaryFocuses = @[@"children from slums", @"children of (ex)convicts", @"children of dalits/tribals", @"children of lepers", @"children of migrant workers", @"children of sex workers", @"children who are working", @"children with disabilities", @"children with hemophilia", @"creating resources", @"dropouts", @"girls", @"health and cleanliness", @"orphans" , @"other", @"remedial education", @"to go to formal school", @"vocational training"];
    }
    
    return primaryFocuses;
}

+ (NSArray *)AREAS
{
    static NSArray *areas = nil;
    if (!areas) {
        areas = @[@"ANDAMAN AND NICOBAR ISLANDS", @"ANDHRA PRADESH", @"ARUNACHAL PRADESH", @"ASSAM", @"BIHAR", @"CHANDIGARH", @"CHHATTISGARH", @"DADRA AND NAGAR HAVELI", @"DAMAN AND DIU", @"DELHI", @"GOA", @"GUJARAT", @"HARYANA", @"HIMACHAL PRADESH" , @"JAMMU AND KASHMIR", @"JHARKHAND", @"KARNATAKA", @"KERALA"];//TODO add more states
    }
    
    return areas;
}

+ (NSArray *)CHAPTERS
{
    static NSMutableArray *chapters = nil;
    if (!chapters) {
        PFQuery *query = [PFQuery queryWithClassName:@"Chapter"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu records.", (unsigned long)objects.count);
                for (PFObject *object in objects) {
                    // NSLog(@"%@", object[@"name"]);
                    [chapters addObject:object[@"name"]];
                }
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);                   }
        }];
    }
    
    return chapters;
}

@end
