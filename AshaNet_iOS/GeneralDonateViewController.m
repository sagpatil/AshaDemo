//
//  GeneralDonateViewController.m
//  AshaNet_iOS
//
//  Created by Savla, Sumit on 7/5/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "GeneralDonateViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PayPalConfig.h"
#import <Parse/Parse.h>


@interface GeneralDonateViewController ()
- (IBAction)onDonateTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *successView;
@property (weak, nonatomic) IBOutlet UIView *donateView;
@property (weak, nonatomic) IBOutlet UITextField *donationAmountTextField;
@property (weak, nonatomic) IBOutlet UIButton *donateButton;
@property (assign, nonatomic) CGPoint orignalCentre;
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property (assign, nonatomic) CGPoint orignalNameCentre;
@property (weak, nonatomic) IBOutlet UILabel *dollarSignLabel;
@property (nonatomic, strong) NSNumber *donationAmount;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@end

@implementation GeneralDonateViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    self.donateView.alpha =0;
        self.nameLbl.center = CGPointMake(self.orignalNameCentre.x -self.nameLbl.frame.size.width,self.orignalNameCentre.y );
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.nameLbl.center = CGPointMake(self.orignalNameCentre.x,self.orignalNameCentre.y );
        self.donateView.alpha = 1;
    } completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.donateView.alpha =1;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.nameLbl.center = CGPointMake(self.orignalNameCentre.x -self.nameLbl.frame.size.width,self.orignalNameCentre.y );
        self.donateView.alpha = 0;
    } completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    
    PayPalConfig *PPconfig  = [PayPalConfig sharedConfig];
    [PPconfig setupForTakingPayments];
    self.successView.hidden = YES;
    self.donationAmountTextField.delegate = self;
    self.donationAmountTextField.text=@"20";
    [self.donationAmountTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.orignalCentre = self.donateView.center;
    self.orignalNameCentre = self.nameLbl.center;
    [self.view addSubview:self.successView];
        self.successView.center = CGPointMake(160, 300);
    self.successView.hidden = YES;


    self.nameLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:18];
    self.donationAmountTextField.font = [UIFont fontWithName:@"COCOGOOSE" size:100];
    self.dollarSignLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:100];
    self.donateButton.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:28];
    [self addShadows:self.donateButton.layer];
    [self addShadows:self.nameView.layer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Donate Button action
- (IBAction)onDonateTap:(id)sender {
   

   
    [self resignFirstResponder];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Invalid amount"
                                                      message:@"Please enter a valid value greater than 0"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
 
    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:self.donationAmountTextField.text];
    if ([[NSDecimalNumber notANumber] isEqualToNumber:total]){
        [message show];
        return;
    }
    else if (total.floatValue <= 0){
        NSLog(@"Amount Less than 0");
        [message show];
        return;
    }
    
    self.donationAmount = total;
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    payment.shortDescription = [NSString stringWithFormat:@"Donation towards Ashanet"];
    payment.intent = PayPalPaymentIntentSale;
    
    if (!payment.processable) {
        NSLog(@"Payment not processable");
    }
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];

}
#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    [self showSuccess];
    self.donationAmountTextField.text = @"";
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    self.successView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your Parse.com for confirmation and fulfillment.", completedPayment.confirmation);
    NSDictionary *response = (NSDictionary*)completedPayment.confirmation;
    PFObject *donation = [PFObject objectWithClassName:@"Donations"];
    donation[@"donation_amount"] = self.donationAmount;
    donation[@"chapter"] = @"Global Asha";
    donation[@"paypal_confirmation_id"] = response[@"response"][@"id"];
    [donation saveInBackground];
}


#pragma mark - Helpers

// Animation effect where the success message can be shown on our View controller which disappears after 2 seconds
- (void)showSuccess {
    self.successView.hidden = NO;
    self.donateView.hidden = YES;
  
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    [UIView setAnimationDelay:2.0];
      self.successView.alpha = 1.0f;
    [UIView commitAnimations];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
 // DIssmiss keyboard if touched anywhere else on the screen
    if ([self.donationAmountTextField isFirstResponder] && [touch view] != self.donationAmountTextField) {
        [self.donationAmountTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark UIITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.donationAmountTextField) {
       [UIView animateWithDuration:0.1 animations:^{
        self.donateView.center = CGPointMake(160, 190);
       }];

    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self resignFirstResponder];
    if (textField == self.donationAmountTextField) {
        [UIView animateWithDuration:0.1 animations:^{
           self.donateView.center = CGPointMake(self.orignalCentre.x, self.orignalCentre.y);
        }];
    }
    return YES;
}

-(void) addShadows:(CALayer *)layer{
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 4;
    layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    
}

@end
