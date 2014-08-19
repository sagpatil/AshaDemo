//
//  webViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/27/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webViewController : UIViewController <UIWebViewDelegate>
  @property(strong,nonatomic)  NSURL *url;
  @property (nonatomic, strong) NSString *color;
@end
