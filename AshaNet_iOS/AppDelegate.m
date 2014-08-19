//
//  AppDelegate.m
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/1/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "AppDelegate.h"
#import "ProjectsViewController.h"
#import "EventsViewController.h"
#import "GeneralDonateViewController.h"
#import "XOSplashVideoController.h"
#import <Parse/Parse.h>
#import "TimeLineViewController.h"
#import "NewEventViewController.h"

static NSString *KApp_id = @"0Kz1Jdnz3PZHlWjY1IBdzuv4tJZcpc8hrnT2mnbR";
static NSString *KClient_Key = @"k6lG4PhbwxJp2zpwo7pgEGUA73zxtYplMBLvtGnS";

@interface AppDelegate ()

@property (nonatomic, strong) TimeLineViewController *timeLineController;
@end

@implementation AppDelegate

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [Parse setApplicationId:KApp_id clientKey:KClient_Key];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.timeLineController = [[TimeLineViewController alloc]init];
   
    
    // Code to hide Status Bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    if([UIScreen mainScreen].bounds.size.height != 568){
        // iPhone 4
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Unsupported Device" message:@"As of now Asha is only supported on iPhone 5 and above" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    } else{
   
        NSString *portraitVideoName = @"splash";
        NSString *portraitImageName = @"Default.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.window.frame.size.height > 480) {
            portraitImageName = @"Default-568h@2x.png";
            portraitVideoName = @"splash-568h~iphone";
        }
        
        NSString *landscapeVideoName = nil; // n/a
        NSString *landscapeImageName = nil; // n/a
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            portraitVideoName = @"splash";
            portraitImageName = @"Default-Portrait.png";
            landscapeVideoName = @"splash-landscape";
            landscapeImageName = @"Default-Landscape.png";
        }
        
        // our video
        NSURL *portraitUrl = [[NSBundle mainBundle] URLForResource:@"asha-intro" withExtension:@"mp4"];
        NSURL *landscapeUrl = [[NSBundle mainBundle] URLForResource:landscapeVideoName withExtension:@"mp4"];
        
        // our splash controller
        XOSplashVideoController *splashVideoController =
        [[XOSplashVideoController alloc] initWithVideoPortraitUrl:portraitUrl
                                                portraitImageName:portraitImageName
                                                     landscapeUrl:landscapeUrl
                                               landscapeImageName:landscapeImageName
                                                         delegate:self];
        // we'll start out with the spash view controller in the window
        self.window.rootViewController = splashVideoController;
        //self.window.rootViewController = [[TimeLineViewController alloc]init];
        //self.window.rootViewController = [[NewEventViewController alloc]init];
        
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    }
    return YES;
}
- (void)splashVideoLoaded:(XOSplashVideoController *)splashVideo
{
    // load up our real view controller, but don't put it in to the window until the video is done
    // if there's anything expensive to do it should happen in the background now
    //self.viewController = [[XOViewController alloc] initWithNibName:@"XOViewController" bundle:nil];
    
}

- (void)splashVideoComplete:(XOSplashVideoController *)splashVideo
{
    self.window.rootViewController = self.timeLineController;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"OK CLicked");
    exit(0);
}

@end
