//
//  LoginViewController.m
//  FBLogin
//
//  Created by Austin Soldner on 6/24/14.
//  Copyright (c) 2014 Austin Soldner. All rights reserved.
//

#import "LoginViewController.h"
#import "NewProjectViewController.h"
#import "NewEventViewController.h"
#import <Parse/Parse.h>
#import "UIColor+fromHex.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *allContainer;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)loginButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *loginFieldContainer;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIImageView *childrenImageView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *createNewVIew;
@property (weak, nonatomic) IBOutlet UILabel *createLbl;

@property (strong, nonatomic) IBOutlet UIView *createView;

@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIButton *eventLbl;
@property (weak, nonatomic) IBOutlet UIButton *projectLbl;

- (IBAction)onCreateEvent:(id)sender;
- (IBAction)onCreateProject:(id)sender;
@property (assign, nonatomic) CGPoint orignalNameCentre;
@property (assign, nonatomic) CGPoint orignalCreateCentre;

@property (nonatomic, assign) CGPoint NameViewCentre;


@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Register the methods for the keyboard hide/show events
        }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self resizeName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *admin = [defaults objectForKey:@"admin"];
    if ([admin isEqualToString:@"YES"]) {
        self.createView.hidden = NO;
        self.createView.alpha = 1;
        self.allContainer.alpha = 0;
        self.childrenImageView.alpha = 0;
        
        self.createLbl.center = CGPointMake(self.orignalCreateCentre.x -self.createLbl.frame.size.width,self.orignalCreateCentre.y );
        [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.createLbl.center = CGPointMake(self.orignalCreateCentre.x,self.orignalCreateCentre.y );
            self.createView.alpha = 1;
        } completion:nil];
    } else {
        self.nameLbl.center = CGPointMake(self.orignalNameCentre.x -self.nameLbl.frame.size.width,self.orignalNameCentre.y );
        [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.nameLbl.center = CGPointMake(self.orignalNameCentre.x,self.orignalNameCentre.y );
            self.allContainer.alpha = 1;
        } completion:nil];
    }
}




- (void) resizeName{
    CGRect r = [[@"ADMIN" uppercaseString]boundingRectWithSize:CGSizeMake(300, 0)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"COCOGOOSE" size:18]}
                                                                        context:nil];
    CGRect frm = self.nameView.frame;
    frm.size.width = r.size.width + 40;

    self.nameView.frame = frm;
    CGRect frm2 = self.nameLbl.frame;
    frm2.size.width = r.size.width + 40;
    self.nameLbl.frame = frm2;
    self.NameViewCentre = self.nameView.center;
    
    r = [[@"CREATE NEW" uppercaseString]boundingRectWithSize:CGSizeMake(300, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"COCOGOOSE" size:18]}
                                                       context:nil];
    frm = self.createNewVIew.frame;
    frm.size.width = r.size.width + 40;
    self.createNewVIew.frame = frm;
    frm2 = self.createLbl.frame;
    frm2.size.width = r.size.width + 40;
    self.createLbl.frame = frm2;
  //  self.NameViewCentre = self.createNewVIew.center;
}

- (void)viewWillDisappear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *admin = [defaults objectForKey:@"admin"];
    if ([admin isEqualToString:@"YES"]) {
        self.createView.alpha =1;
        [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.createLbl.center = CGPointMake(self.orignalCreateCentre.x -self.nameLbl.frame.size.width,self.orignalCreateCentre.y );
            self.createView.alpha = 0;
        } completion:nil];
    } else {
        self.allContainer.alpha =1;
        [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.nameLbl.center = CGPointMake(self.orignalNameCentre.x -self.nameLbl.frame.size.width,self.orignalNameCentre.y );
            self.allContainer.alpha = 0;
        } completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.orignalNameCentre = self.nameLbl.center;
    self.orignalCreateCentre = self.createLbl.center;
    self.nameLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:18];
    self.nameView.backgroundColor = [UIColor colorwithHexString:@"E91E63" alpha:1];
    self.createLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:18];
    self.eventLbl.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:30];
    self.projectLbl.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:30];

    [self resizeName];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
        self.passwordField.delegate = self;
        
        [self.emailField addTarget:self action:@selector(checkEmailField) forControlEvents:UIControlEventEditingChanged];
        
        //PWField
        self.passwordField.secureTextEntry = YES;
        
        [self.passwordField addTarget:self action:@selector(checkPasswordField) forControlEvents:UIControlEventEditingChanged];
        self.indicator.hidden = YES;
        
        self.loginButton.enabled = NO;
        [self.view addSubview:self.createView];
        self.createView.hidden = YES;
    
    [self addShadows:self.loginButton.layer];
    [self addShadows:self.projectLbl.layer];
    [self addShadows:self.eventLbl.layer];
    [self addShadows:self.nameView.layer];
    [self addShadows:self.createNewVIew.layer];
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

-(void) addShadows:(CALayer *)layer{
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 4;
    layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    [self.passwordField resignFirstResponder];
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    
    [self performSelector:@selector(validatePassword) withObject:nil afterDelay:0.3];
    
    
}
-(void) validatePassword {
    
    self.indicator.hidden = YES;
    
    [PFUser logInWithUsernameInBackground:self.emailField.text password:self.passwordField.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                              self.createView.alpha = 0;
                                          [UIView animateKeyframesWithDuration:1 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                                             
                                              self.createView.hidden = NO;
                                              self.createView.alpha = 1;
                                              self.allContainer.alpha = 0;
                                              self.childrenImageView.alpha = 0;
                                             
                                          } completion:^(BOOL finished) {
                                              
                                          }];
                                            NSString *logggedIn = @"YES";
                                            [[NSUserDefaults standardUserDefaults] setObject:logggedIn forKey:@"admin"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                        } else {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Announcement" message: @"Failed Login" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            
                                            [alert show];
                                        }
                                    }];
    [self.indicator stopAnimating];
}

- (IBAction)onCreateEvent:(id)sender {
    NewEventViewController *nevc = [[NewEventViewController alloc]init];
    
    [self presentViewController:nevc animated:YES completion:nil];

}

- (IBAction)onCreateProject:(id)sender {
    NewProjectViewController *npvc = [[NewProjectViewController alloc]init];
    [self presentViewController:npvc animated:YES completion:nil];
}



-(void)dismissKeyboard {
    
    [self.view endEditing:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSLog(@"Change me done");
    [textField resignFirstResponder];
    [self loginButtonPressed:nil];
    return NO;
}

@end
