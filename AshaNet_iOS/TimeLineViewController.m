//
//  TimeLineViewController.m
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/17/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "TimeLineViewController.h"
#import "Event.h"
#import "EventsViewController.h"
#import "ProjectsViewController.h"
#import "LoginViewController.h"
#import "GeneralDonateViewController.h"
#import "AROverlayViewController.h"
#import "UIColor+fromHex.h"
#import "Project.h"
#import <Parse/Parse.h>
#import <EventKit/EventKit.h>

static NSString *kSaveCkicked = @"NewProjectorEventAdded";
static NSString *kLocationUpdate = @"onLocationUpdate";

@interface TimeLineViewController ()
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) NSArray *themeColors;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@end

@implementation TimeLineViewController

CLLocation *myLocation;
NSInteger arrayIndex;
CLLocationManager *locationManager;
Event *e;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.themeColors = @[
                                [UIColor colorWithRed:0.4f green:0.8f blue:1 alpha:1],
                                 [UIColor colorWithRed:1 green:0.4f blue:0.8f alpha:1],
                                 [UIColor colorWithRed:1 green:0.8f blue:0.4f alpha:1],
                                [UIColor colorWithRed:0.4f green:0.8f blue:1 alpha:1],
                                [UIColor colorWithRed:1 green:0.4f blue:0.8f alpha:1],
                                [UIColor colorWithRed:1 green:0.8f blue:0.4f alpha:1],
                                [UIColor colorWithRed:0.4f green:0.8f blue:1 alpha:1]];
                            }
    [self loadProjectsAndEvents];
    myLocation = [[CLLocation alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewEvent:)
                                                 name:kSaveCkicked
                                               object:e];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showGenDonate:)
                                                 name:@"Donate2Share"
                                               object:nil];
    return self;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorwithHexString:@"9c2780" alpha:1];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {}];

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
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    self.pageViewController.dataSource = self;
    
    [[self.pageViewController view] setFrame:[[self view] bounds]];
   
    UIViewController *initialViewController = [self viewControllerAtIndex:3];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [[self view] addSubview:[self.pageViewController view]];
    [self.pageViewController didMoveToParentViewController:self];
    arrayIndex = 1;
    
 
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //Touch gestures below top bar should not make the page turn.
    //EDITED Check for only Tap here instead.
        NSLog(@"TOuched ");
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
    
        CGPoint touchPoint = [touch locationInView:self.view];
        if (touchPoint.y > 40) {
            NSLog(@" in 1");
            return NO;
        }
        else if (touchPoint.x > 50 && touchPoint.x < 430) {//Let the buttons in the middle of the top bar receive the touch
            NSLog(@" in 3");
            return NO;
        }
    }
    return YES;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
   NSLog(@"VC at index  %lu",(unsigned long)index);
   if (index == 0) {
       LoginViewController *lvc = [[LoginViewController alloc]init];
       lvc.index = index;
       return lvc;
   }
    else  if (index  == 1) {
        GeneralDonateViewController *gvc = [[GeneralDonateViewController alloc]init];
        gvc.index = index;
        return gvc;
    }
    else  if (index  == 2) {
        AROverlayViewController *avc = [[AROverlayViewController alloc]init];
        avc.index = index;
        return avc;
    }
    
   else if (index % 2 == 0) {
        ProjectsViewController *projectChildViewController = [[ProjectsViewController alloc] initWithNibName:@"ProjectsViewController" bundle:nil];
        projectChildViewController.index = index;
        projectChildViewController.selectedProject = self.projects[index/2 - 1];
       return projectChildViewController;
    } else if (index % 2 != 0 || index == 3) {
        EventsViewController *eventChildViewController = [[EventsViewController alloc] initWithNibName:@"EventsViewController" bundle:nil];
        eventChildViewController.index = index;
        eventChildViewController.selectedEvent = self.events[index/2-1];
        return eventChildViewController;
    } else {
        return [[AROverlayViewController alloc]init];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [(EventsViewController *)viewController index];
    if (index == 0)
        return nil;
    
    index--;
 //   NSLog(@"  %lu  Up",(unsigned long)index);
    return [self viewControllerAtIndex:index];

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(EventsViewController *)viewController index];
    index++;
    
    if (index == (self.events.count + self.projects.count))
        return nil;
    
    //NSLog(@"  %d Down",index);
    return [self viewControllerAtIndex:index];
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
// NSLog(@"Current Page = %@", pageViewController.viewControllers);
    
}



#pragma  mark - Helper methods

- (void) getEventsFromParse{
            self.events = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query addDescendingOrder:@"createdAt"];
    [query setCachePolicy:kPFCachePolicyCacheElseNetwork];

    NSArray *objects = [query findObjects];
    NSLog(@"Successfully retrieved %lu Events.", (unsigned long)objects.count);

    for (NSDictionary *object in objects){
        Event *e = [[Event alloc]initWithDictionary:object];
        [self.events addObject:e];
    }

}

- (void) getProjectsFromParse{
    self.projects = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"Project"];
    [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
    
    NSArray *objects = [query findObjects];
    NSLog(@"Successfully retrieved %lu Projects.", (unsigned long)objects.count);
    for (NSDictionary *object in objects){
        Project *e = [[Project alloc]initWithDictionary:object];
        [self.projects addObject:e];
    }
}

-(void) loadProjectsAndEvents{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
            [self getProjectsFromParse];
            [self getEventsFromParse];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                    NSLog(@"Data Succesfully fetched");
            });
        });
}

- (void) addNewEvent:(NSNotification *) notification{
    if ([notification.name isEqualToString:@"NewProjectorEventAdded"])
    {
        NSDictionary *object = [notification object];
         Event *e = [[Event alloc]initWithDictionary:object];
        [self.events insertObject:e atIndex:0];
        
    }
}

- (void) showGenDonate:(NSNotification *) notification{
    if ([notification.name isEqualToString:@"Donate2Share"])
    {
        NSLog(@"Changeme");
        [_pageViewController setViewControllers:@[[self viewControllerAtIndex:1]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
    }
}


   


#pragma mark Location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
   // UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
   // [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSString *lon = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *lat= [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
//        NSLog(@"Lat long from GPS %@ %@", lat,lon);
    }

    myLocation = currentLocation;
        [[NSNotificationCenter defaultCenter]     postNotificationName:kLocationUpdate     object:self];
   // [locationManager stopUpdatingLocation];
}

+(CLLocation*)getLocation{
    return myLocation;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
