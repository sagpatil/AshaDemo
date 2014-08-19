//
//  ProjectDonateViewController.m
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/6/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "ProjectDonateViewController.h"
#import "PayPalMobile.h"

@interface ProjectDonateViewController ()
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
@property (weak, nonatomic) IBOutlet UITextField *donationAmountTextField;

@property (nonatomic, strong) NSNumber *donationAmount;
@property (weak, nonatomic) IBOutlet UIView *successView;
- (IBAction)onBackButton:(id)sender;

- (IBAction)onDonateTap:(id)sender;
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@end

@implementation ProjectDonateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        PayPalConfig *PPconfig  = [PayPalConfig sharedConfig];
        [PPconfig setupForTakingPayments];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // self.navigationItem.title = @"Donate to Project";
    self.projectLabel.text = self.projectName;
    [self.donationAmountTextField becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDonateTap:(id)sender {
    PayPalConfig *PPconfig  = [PayPalConfig sharedConfig];
    [PPconfig setupForTakingPayments];
    
    [self resignFirstResponder];
  
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Invalid amount"
                                                      message:@"Please enter a valid value greater than 0"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    
    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:self.donationAmountTextField.text];
    if ([[NSDecimalNumber notANumber] isEqualToNumber:total]){
        NSLog(@"Not a valid nuber entered");
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
    payment.shortDescription = [NSString stringWithFormat:@"Donation to %@ Project of Ashanet",self.projectName];
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
    donation[@"project"] = self.projectName;
    donation[@"paypal_confirmation_id"] = response[@"response"][@"id"];
    [donation saveInBackground];
}


#pragma mark - Helpers

// Animation effect where the success message can be shown on our View controller which disappears after 2 seconds
- (void)showSuccess {
    self.successView.hidden = NO;
    self.successView.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:4.0];
    self.successView.alpha = 0.0f;
    [UIView commitAnimations];
}

- (IBAction)onBackButton:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
