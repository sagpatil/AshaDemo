//
//  ProjectsViewController.h
//  AshaNet_iOS
//
//  Created by Savla, Sumit on 7/5/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"
#import <Parse/Parse.h>
#import "PayPalConfig.h"
#import "Capture2SessionManager.h"

@class CIDetector;

@interface ProjectsViewController : UIViewController <PayPalPaymentDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, UIDocumentInteractionControllerDelegate>
{
    UIImage *mTakenPhoto;
}
@property (strong, nonatomic) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) Project *selectedProject;
@property (assign, nonatomic) NSInteger index;
@property (retain) Capture2SessionManager *captureManager;


@end
