//
//  LoginViewController.m
//  FBLogin
//
//  Created by Austin Soldner on 6/24/14.
//  Copyright (c) 2014 Austin Soldner. All rights reserved.
//

#import "LoginViewController.h"
#import "FeedViewController.h"
#import "RequestsViewController.h"
#import "MessagesViewController.h"
#import "NotificationsViewController.h"
#import "MoreViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *allContainer;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)loginButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *loginFieldContainer;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;


// Declare some methods that will be called when the keyboard is about to be shown or hidden
- (void)willShowKeyboard:(NSNotification *)notification;
- (void)willHideKeyboard:(NSNotification *)notification;


@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Register the methods for the keyboard hide/show events
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    [self.emailField addTarget:self action:@selector(checkEmailField) forControlEvents:UIControlEventEditingChanged];
    
    //PWField
    self.passwordField.secureTextEntry = YES;
    
    [self.passwordField addTarget:self action:@selector(checkPasswordField) forControlEvents:UIControlEventEditingChanged];
    self.indicator.hidden = YES;
    
    self.loginButton.enabled = NO;
}
-(void)checkEmailField {
    
    
    if (self.emailField.text.length && self.passwordField.text.length) {
       self.loginButton.enabled = YES;
    } else {
        self.loginButton.enabled = NO;
    }
}
-(void)checkPasswordField {
//    NSLog(@"check that PW ");
    if (self.emailField.text.length && self.passwordField.text.length) {
        self.loginButton.enabled = YES;
    } else {
        self.loginButton.enabled = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    
    [self performSelector:@selector(validatePassword) withObject:nil afterDelay:2];
    
    
}
-(void) validatePassword {
    
    self.indicator.hidden = YES;
    [self.indicator stopAnimating];
    if ([self.passwordField.text isEqualToString: @"password"]) {
        
        FeedViewController *vc = [[FeedViewController alloc] init];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.tabBarItem.title = @"Feed";
        nav.tabBarItem.image = [UIImage imageNamed:@"nb-newsfeed-off"];
        
        RequestsViewController *rvc = [[RequestsViewController alloc] init];
        UINavigationController *rnav = [[UINavigationController alloc] initWithRootViewController:rvc];
        rnav.tabBarItem.title = @"Requests";
        rnav.tabBarItem.image = [UIImage imageNamed:@"nb-request-off"];
        
        MessagesViewController *mvc = [[MessagesViewController alloc] init];
        UINavigationController *mnav = [[UINavigationController alloc] initWithRootViewController:mvc];
        mnav.tabBarItem.title = @"Messages";
        mnav.tabBarItem.image = [UIImage imageNamed:@"comment-off"];
        
        
        NotificationsViewController *nvc = [[NotificationsViewController alloc] init];
        UINavigationController *nnav = [[UINavigationController alloc] initWithRootViewController:nvc];
        nnav.tabBarItem.title = @"Notifications";
        nnav.tabBarItem.image = [UIImage imageNamed:@"nb-notifications-off"];
        
        MoreViewController *morevc = [[MoreViewController alloc] init];
        UINavigationController *morenav = [[UINavigationController alloc] initWithRootViewController:morevc];
        morenav.tabBarItem.title = @"More";
        morenav.tabBarItem.image = [UIImage imageNamed:@"nb-more-off"];
        
        
        
        
        
        UITabBarController *tab = [[UITabBarController alloc] init];
        tab.viewControllers = @[nav, rnav, mnav, nnav, morenav ];
        
        [self presentViewController:tab animated:YES completion: nil];
        
        
        
       

        
        
        
    }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong Password" message:@"Try again!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];        }
    
}

- (void)willShowKeyboard:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the keyboard height and width from the notification
    // Size varies depending on OS, language, orientation
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"Height: %f Width: %f", kbSize.height, kbSize.width);
    
    // Get the animation duration and curve from the notification
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    // Move the view with the same duration and animation curve so that it will match with the keyboard animation
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:^{
                         self.allContainer.frame = CGRectMake(0, self.view.frame.size.height - kbSize.height - self.allContainer.frame.size.height, self.allContainer.frame.size.width, self.allContainer.frame.size.height);
                     }
                     completion:nil];
}

-(void)dismissKeyboard {
    
    [self.view endEditing:YES];
    
}
- (void)willHideKeyboard:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the keyboard height and width from the notification
    // Size varies depending on OS, language, orientation
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"Height: %f Width: %f", kbSize.height, kbSize.width);
    
    // Get the animation duration and curve from the notification
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    // Move the view with the same duration and animation curve so that it will match with the keyboard animation
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:^{
                         self.allContainer.frame = CGRectMake(0, 100, self.allContainer.frame.size.width, self.allContainer.frame.size.height);
                     }
                     completion:nil];}

@end
