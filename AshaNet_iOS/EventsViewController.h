//
//  EventsViewController.h
//  AshaNet_iOS
//
//  Created by Savla, Sumit on 7/5/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "Event.h"
#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController <UIActionSheetDelegate,UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>
@property (strong, nonatomic, readwrite) Event *selectedEvent;
@property (assign, nonatomic) NSInteger index;

@end
