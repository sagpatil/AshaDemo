//
//  TimeLineViewController.h
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/17/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TimeLineViewController : UIViewController <UIPageViewControllerDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIPageViewController *pageViewController;
+(CLLocation*) getLocation;
@end
