//
//  EventsViewController.m
//  AshaNet_iOS
//
//  Created by Savla, Sumit on 7/5/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "EventsViewController.h"
#import <Parse/Parse.h>
#import <EventKit/EventKit.h>
#import <MapKit/MapKit.h>
#import <Social/Social.h>
#import "MBProgressHUD.h"
#import "UIColor+fromHex.h"
#import "webViewController.h"
#import "TimeLineViewController.h"
#import "SAMWebViewController.h"

static NSString * KbuttonClick = @"OnRSVPClicked";
static NSString *kLocationUpdate = @"onLocationUpdate";

@interface EventsViewController ()
@property (assign, nonatomic) BOOL reversed;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *toRotateView;
@property (weak, nonatomic) IBOutlet UIView *donateView;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *rsvpLbl;
- (IBAction)onMoreClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *nameUIView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
- (IBAction)onRSVPClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *addrLbl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *locationLbl;
@property (weak, nonatomic) IBOutlet UILabel *DescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *shareImgView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (nonatomic, assign) CGPoint NameViewCentre;
@property (weak, nonatomic) IBOutlet UIImageView *shareViewCircle1;
@property (weak, nonatomic) IBOutlet UIImageView *shareViewCircle2;
@property (weak, nonatomic) IBOutlet UIImageView *shareViewCircle3;
@property (weak, nonatomic) IBOutlet UIImageView *shareViewCircle4;
- (IBAction)shareTwitterTap:(id)sender;
- (IBAction)shareFacebookTap:(id)sender;
- (IBAction)onMapsTap:(id)sender;

- (IBAction)onCalendarTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *shareView;

@end

@implementation EventsViewController
BOOL RSVPViewUp;
BOOL detailsViewUp;
float distanceInMiles;
CLLocation *eventLocation;
CLLocationManager *locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLocationUpdated:)
                                                     name:kLocationUpdate
                                                   object:nil];
        
        //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationUpdated:) name:kLocationUpdate object:self];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
   // NSLog(@"Will  appear %ld",(long)self.index);
    
    self.nameUIView.center = CGPointMake(self.NameViewCentre.x - self.nameUIView.frame.size.width,self.NameViewCentre.y );
    self.donateView.alpha = 0;
    self.detailsView.alpha = 0;
    self.toRotateView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.donateView.alpha = 1;
        self.detailsView.alpha = 1;
        self.toRotateView.alpha = 1;
        self.nameUIView.center = CGPointMake(self.NameViewCentre.x,self.NameViewCentre.y );
    } completion:nil];
    
}
-(void)viewDidDisappear:(BOOL)animated{
  //  NSLog(@"Did Disappear %ld",(long)self.index);
}
- (void)viewWillDisappear:(BOOL)animated{
 //   NSLog(@"Will Disappear %ld",(long)self.index);
    self.donateView.alpha =1;
    self.detailsView.alpha = 1;
    self.toRotateView.alpha = 1;
    self.nameUIView.center = CGPointMake(self.NameViewCentre.x,self.NameViewCentre.y );
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.nameUIView.center = CGPointMake(self.NameViewCentre.x -self.nameUIView.frame.size.width,self.NameViewCentre.y );
        self.donateView.alpha = 0;
        self.detailsView.alpha = 0;
        self.toRotateView.alpha = 0;
    } completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getDistance];
    RSVPViewUp = NO;
    detailsViewUp = NO;
    
    self.shareView.hidden = YES;
    
    self.shareViewCircle1.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.shareViewCircle1.tintColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
    self.shareViewCircle2.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.shareViewCircle2.tintColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
    self.shareViewCircle3.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.shareViewCircle3.tintColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
    self.shareViewCircle4.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.shareViewCircle4.tintColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
    self.shareImgView.hidden = YES; // hide the old share image #TODO delete this from nib and file once we get other in
    
    self.DescriptionLabel.font = [UIFont fontWithName:@"Gotham-Light" size:14];
    self.nameLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:18];
    self.cityLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:15];
    self.addrLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:14];
    self.locationLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:15];
    self.distanceLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:18];
    self.dateTimeLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:12];
    self.moreButton.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:15];
    self.rsvpLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:12];
    
    self.imageView.image = self.selectedEvent.eventImage;
    self.DescriptionLabel.text = self.selectedEvent.description;
    [self resizeName];
    self.nameLbl.text = [self.selectedEvent.name uppercaseString];
    [self setAdressLabel];
    self.addrLbl.text = [self.selectedEvent.address uppercaseString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, MMM dd, yyyy h:mm a"];
    
    NSString *stringFromDate = [formatter stringFromDate:self.selectedEvent.eventTime];
    self.dateTimeLbl.text = [stringFromDate uppercaseString];
    self.donateView.center = CGPointMake(395, 760);
    self.detailsView.center = CGPointMake(160, 575);
    
    CGRect newFrame = self.scrollView.frame;
    newFrame.size.width = 320;
    newFrame.size.height = 170;
    [self.scrollView setFrame:newFrame];
    [self.scrollView setScrollEnabled:NO];
    self.scrollView.contentSize = CGSizeMake(280, 200);
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        self.scrollView.center = CGPointMake(160, 50);
    
    self.rsvpLbl.textColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
    UIImageView *gradientImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -140, 320, 741)];
    gradientImageView.image = [[UIImage imageNamed:@"gradient"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    gradientImageView.tintColor = [UIColor colorwithHexString:self.selectedEvent.colorHighlight alpha:1];
    [self.detailsView addSubview:gradientImageView];
    [self.detailsView sendSubviewToBack:gradientImageView];
    
    self.nameUIView.backgroundColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
    self.toRotateView.backgroundColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
    self.donateView.backgroundColor = [UIColor colorwithHexString:self.selectedEvent.colorHighlight alpha:1];
    self.toRotateView.center = CGPointMake(498,708);
    self.toRotateView.transform = CGAffineTransformMakeRotation(M_PI/4);
    self.donateView.backgroundColor = [UIColor clearColor];
    self.detailsView.backgroundColor = [UIColor clearColor];
    self.shareImgView.center = CGPointMake(30, 205);
    self.moreButton.center = CGPointMake(160, 170);
    
    newFrame = self.DescriptionLabel.frame;
    newFrame.size.width = 280;
    newFrame.size.height = 110;
    [self.DescriptionLabel setFrame:newFrame];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareTapDetected)];
    singleTap.numberOfTapsRequired = 1;
    self.shareImgView.userInteractionEnabled = YES;
    [self.shareImgView addGestureRecognizer:singleTap];
    
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.donateView addGestureRecognizer:swipeUpGestureRecognizer];
    
    UISwipeGestureRecognizer* swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.donateView addGestureRecognizer:swipeDownGestureRecognizer];
    
    [self.view sendSubviewToBack:self.baseView];
    [self.view bringSubviewToFront:self.detailsView];
    
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addToCal) ];
    [self.dateTimeLbl addGestureRecognizer:tapGesture];
    UITapGestureRecognizer *tapGestureMap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openInMaps)];
    [self.addrLbl addGestureRecognizer:tapGestureMap];
    
    [self addShadows:self.nameUIView.layer];


    
}

-(void) addShadows:(CALayer *)layer{
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 4;
    layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
}


-(void)shareTapDetected{
    NSLog(@"shareTapDetected    shareTapDetected   ");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM dd, yyyy h:mm a"];
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    NSArray *lines = @[@"Hey checkout this Asha event! I am going to.\n\n", [NSString stringWithFormat:@"%@ : ", self.selectedEvent.name], self.selectedEvent.ticketUrl];
    NSString *linesString = [lines componentsJoinedByString:@""];
    [sharingItems addObject: linesString];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void) resizeName{
    CGRect r = [[self.selectedEvent.name uppercaseString]boundingRectWithSize:CGSizeMake(300, 0)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName:[UIFont fontWithName:@"COCOGOOSE" size:18]}
                                                                      context:nil];
    CGRect frm = self.nameUIView.frame;
    frm.size.width = r.size.width + 40;
    self.nameUIView.frame = frm;
    CGRect frm2 = self.nameLbl.frame;
    frm2.size.width = r.size.width + 40;
    self.nameLbl.frame = frm2;
    self.NameViewCentre = self.nameUIView.center;
}

- (void) handleSwipeUpFrom:(UIGestureRecognizer*)recognizer {
    //  self.donateView.backgroundColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
    webViewController *webVC = [[webViewController alloc]initWithNibName:@"webViewController" bundle:nil];
    
    webVC.url = [NSURL URLWithString:self.selectedEvent.ticketUrl];
    webVC.color = self.selectedEvent.color;
    webVC.modalPresentationStyle = UIModalPresentationCustom;
    webVC.transitioningDelegate = self;
    [self presentViewController:webVC animated:YES completion:nil];
    
    
//	SAMWebViewController *webViewController = [[SAMWebViewController alloc] init];
//	[webViewController.webView loadURL:[NSURL URLWithString:self.selectedEvent.ticketUrl]];
//    webViewController.modalPresentationStyle = UIModalPresentationCustom;
//    webViewController.transitioningDelegate = self;
//    [self presentViewController:webViewController animated:YES completion:nil];
}

- (void) handleSwipeDownFrom:(UIGestureRecognizer*)recognizer {
    self.donateView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.3 animations:^{
        self.toRotateView.center = CGPointMake(460, 700);
        self.donateView.center = CGPointMake(395, 760);
        RSVPViewUp = NO;
    }];
}

- (IBAction)onMoreClick:(id)sender {
    // slide down
    if (detailsViewUp) {
        CGRect newFrame = self.scrollView.frame;
        newFrame.size.width = 320;
        newFrame.size.height = 170;
        [self.scrollView setFrame:newFrame];
        [self.scrollView setScrollEnabled:NO];
        self.scrollView.contentSize = CGSizeMake(280, 200);
        [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [self.moreButton setTitle:@"MORE.." forState:UIControlStateNormal];
        
        self.moreButton.center = CGPointMake(160, 170);
        self.DescriptionLabel.numberOfLines = 7;
        newFrame = self.DescriptionLabel.frame;
        newFrame.size.width = 280;
        newFrame.size.height = 100;
        [self.DescriptionLabel setFrame:newFrame];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        newFrame = self.detailsView.bounds;
        newFrame.size = CGSizeMake(320, 205);
        gradient.frame = newFrame;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor colorwithHexString:self.selectedEvent.color alpha:1].CGColor, nil];
        gradient.startPoint = CGPointMake(1.0f, 0.0f);
        gradient.endPoint = CGPointMake(1.0f, 1.0f);
        [self.detailsView.layer insertSublayer:gradient atIndex:0];
        self.detailsView.backgroundColor = [UIColor clearColor];
        self.shareView.alpha = 1;
        
        
        [UIView animateWithDuration:.3 animations:^{
              self.shareView.alpha = 0;
            self.detailsView.center = CGPointMake(160, 575);
            self.detailsView.backgroundColor = [UIColor clearColor];
            self.shareImgView.center = CGPointMake(30, 205);
        }completion:^(BOOL finished) {
            self.shareImgView.center = CGPointMake(30, 205);
            self.shareView.hidden = YES;

        }];
        detailsViewUp = NO;
        
        // Enabble PageViewController scroll when RotatedView is down
        for (UIScrollView *view in self.parentViewController.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                view.scrollEnabled = YES;
            }
            
        }
        
    }
    else{
        //        [self.detailsView.layer.sublayers[0] removeFromSuperlayer];
        CGRect newFrame = self.scrollView.frame;
        newFrame.size.width = 320;
        newFrame.size.height = 285;
        [self.scrollView setFrame:newFrame];
        [self.scrollView setScrollEnabled:YES];
        
        self.DescriptionLabel.numberOfLines = 0;
        [self.DescriptionLabel sizeToFit];
        [self.scrollView setContentSize: CGSizeMake(280, self.DescriptionLabel.frame.size.height + self.addrLbl.frame.size.height + 90)];
        
        CGRect frm = self.addrLbl.frame;
        frm.origin.y = self.DescriptionLabel.frame.size.height + 80;
        self.addrLbl.frame = frm;
        self.addrLbl.numberOfLines = 0;
        [self.addrLbl sizeToFit];
        self.moreButton.center = CGPointMake(160, 300);
        
        self.shareView.hidden = NO;
        self.shareView.alpha = 0;
        
        [UIView animateWithDuration:.3 animations:^{
            [self.moreButton setTitle:@"LESS.." forState:UIControlStateNormal];
            self.shareView.alpha = 1;
            self.detailsView.center = CGPointMake(160, 400);
           // self.shareImgView.center = CGPointMake(30, 350);
            //  self.detailsView.backgroundColor = [UIColor colorwithHexString:self.selectedEvent.color alpha:1];
        }];
        detailsViewUp = YES;
        // Enabble PageViewController scroll when RotatedView is down
        for (UIScrollView *view in self.parentViewController.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                view.scrollEnabled = NO;
            }
            
        }
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (float)getDistance
{
    
    CLLocation *location = [TimeLineViewController getLocation];
    //NSLog(@"     %f %f         ",location.coordinate.latitude, location.coordinate.longitude);
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:self.selectedEvent.address
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     for (CLPlacemark* aPlacemark in placemarks)
                     {
                         CLLocationDistance distance = [location distanceFromLocation:aPlacemark.location];
                         // set global variable
                         eventLocation = aPlacemark.location;
                         distanceInMiles = distance * 0.00062137;
                         self.distanceLabel.text = [NSString stringWithFormat:@"%.01f MI",distanceInMiles];
                     }
                 }];
    // return 1 as gloabl variable is already set to the distance
    return 1;
}

-(void) openInMaps{
    
    {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps",@"Google Maps" , nil];
        
        [actionSheet showInView:self.detailsView];
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //Apple Maps, using the MKMapItem class
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:eventLocation.coordinate addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = self.selectedEvent.name;
        [item openInMapsWithLaunchOptions:nil];
    }
    else if (buttonIndex == 1){
        
        if ([[UIApplication sharedApplication] canOpenURL:
             [NSURL URLWithString:@"comgooglemaps://"]])
        {
            NSString * newString = [self.selectedEvent.address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            NSLog(@"%@xx",newString);
            NSString *query = [NSString stringWithFormat:@"comgooglemaps://?q=%@&center=%f,%f",newString, eventLocation.coordinate.latitude,eventLocation.coordinate.longitude];
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:query
              ]];
        } else {
            UIAlertView *addAlert = [[UIAlertView alloc]
                                     initWithTitle:@"Error opening Google Maps" message:@"Google maps not installed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [addAlert show];
            
            
        }
    }
}


-(void) addToCal{
    
    
    
    UIAlertView *addAlert = [[UIAlertView alloc]
                             initWithTitle:@"Add event to calendar" message:@"Do you want to add this event to your calendar ?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [addAlert show];
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        event.title     = self.selectedEvent.name;
        event.location = self.selectedEvent.address;
        
        event.startDate = self.selectedEvent.eventTime;
        event.endDate   = [[NSDate alloc] initWithTimeInterval:3600 sinceDate:event.startDate];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        NSLog(@"     Added event to calendar         ");
    }
    else{
        NSLog(@"Cancel CLicked");
    }
    
    
}

- (IBAction)onRSVPClick:(id)sender {
    if (RSVPViewUp) {
        [self handleSwipeDownFrom:nil];
    }
    else
        [self handleSwipeUpFrom:nil];
}

- (void) onLocationUpdated:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:kLocationUpdate]){
        [self getDistance];
    }
}

- (void )setAdressLabel{
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:self.selectedEvent.address
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     for (CLPlacemark* aPlacemark in placemarks)
                     {
                         self.cityLbl.text =   [aPlacemark.addressDictionary[@"City"] uppercaseString];
                         
                         
                     }
                 }];
}


#pragma Mark animation VC
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.reversed = NO;
    return  self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.reversed = YES;
    return  self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    return 1;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    toVC.view.frame = containerView.frame;
    [containerView addSubview:toVC.view];
    
    CGRect myFrame = CGRectMake(320, 568, 320, 568);
    CGRect myFrame2 = CGRectMake(0, 0, 320, 568);
    
    // the retuen after dismiss animation is not working cause once trnasitionCOntext complete is set to yes no further animation work
    if (self.reversed) {
        NSLog(@" back!!");
        
        fromVC.view.frame = myFrame2;
        
        
        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromVC.view.frame = myFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
        
        
        
    } else {
        toVC.view.frame = myFrame;
        
        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toVC.view.frame = myFrame2;
            
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    
    

    
    
}

- (IBAction)shareTwitterTap:(id)sender {
    NSLog(@" Twitter ");
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSArray *lines = @[@"Check out the Asha Event:\n", [NSString stringWithFormat:@"Name: %@\n", self.selectedEvent.name],[NSString stringWithFormat:@"%@",self.selectedEvent.ticketUrl]];
    NSString *linesString = [lines componentsJoinedByString:@"\n"];
    [controller setInitialText:linesString];

    [self presentViewController:controller animated:YES completion:nil];

    
}

- (IBAction)shareFacebookTap:(id)sender {
    NSLog(@" FB ");
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSArray *lines = @[@"Check out the Asha Event:\n", [NSString stringWithFormat:@"Name: %@\n", self.selectedEvent.name],[NSString stringWithFormat:@"%@",self.selectedEvent.ticketUrl]];
    NSString *linesString = [lines componentsJoinedByString:@"\n"];
    [controller setInitialText:linesString];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onMapsTap:(id)sender {
         NSLog(@"     MAP         ");
    [self openInMaps];
}
- (IBAction)onCalendarTap:(id)sender {
     NSLog(@"       Cal       ");
    [self addToCal];
}
@end
