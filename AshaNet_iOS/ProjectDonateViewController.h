//
//  ProjectDonateViewController.h
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/6/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PayPalConfig.h"

@interface ProjectDonateViewController : UIViewController <PayPalPaymentDelegate>

@property(nonatomic, strong) NSString *projectName;
@end
