//
//  CoinView.m
//  animation
//
//  Created by Matt Mitchell on 7/19/14.
//  Copyright (c) 2014 Matt Mitchell. All rights reserved.
//

#import "CoinView.h"
#import "LoginViewController.h"
#import "UIColor+fromHex.h"

@implementation CoinView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* orange =  [UIColor colorwithHexString:self.color alpha:1]; //[
    //UIColor* orange =  [UIColor colorWithRed: 0.937 green: 0.424 blue: 0 alpha: 1];
    UIColor* orangeshadow = [UIColor colorwithHexString:self.colorShadow alpha:1];
    UIColor* orangehighlight = [UIColor colorwithHexString:self.colorHighlight alpha:1];
    
    //// Rectangle 3 Drawing
    //    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 320, 320)];
    //    [orange setFill];
    //    [rectangle3Path fill];
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(40, 15, 240, 240)];
    [orangeshadow setFill];
    [oval2Path fill];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(40, 194, 240, 15)];
    [orangeshadow setFill];
    [rectanglePath fill];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(40, 8, 240, 240)];
    [orangehighlight setFill];
    [ovalPath fill];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(40, 208, 240, 44)];
    [orange setFill];
    [rectangle2Path fill];
    
    // $ label
    UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(70, 80, 45, 80)];
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentLeft];
    label.font = [UIFont fontWithName:@"COCOGOOSE" size:72];
    label.textColor=[UIColor whiteColor];
    label.text = @"$";
    [self addSubview:label];
    
    // textField
    self.amountField = [[UITextField alloc] initWithFrame:CGRectMake(130, 80, 125, 80)];
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    self.amountField.textColor = [UIColor whiteColor];
    self.amountField.font = [UIFont fontWithName:@"COCOGOOSE" size:78];
    self.amountField.backgroundColor=[UIColor clearColor];
    [self.amountField setTextAlignment:NSTextAlignmentLeft];
    self.amountField.placeholder=@"20";
    self.amountField.adjustsFontSizeToFitWidth = YES;
    [ self.amountField setKeyboardType:UIKeyboardTypeNumberPad];
    [self addSubview:self.amountField];
    
    
    self.donateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.donateButton addTarget:self action:@selector(onClickDonate:) forControlEvents:UIControlEventTouchUpInside];
    self.donateButton.frame = CGRectMake(40.0, 250.0, 240.0, 60.0);
    [self.donateButton setTitle:@"DONATE" forState:UIControlStateNormal];
    self.donateButton.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:32];

    [self.donateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.donateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.donateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.donateButton setBackgroundColor:[UIColor colorwithHexString:self.colorHighlight alpha:1]];
    [self addSubview: self.donateButton];
    
    self.amountField.delegate = self;
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    NSLog(@"textFieldDidBeginEditing");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OnKeyBoardUpFromCoin"
     object:self];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Coin keyboard up");
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self resignFirstResponder];
 //   self.donateView.center = CGPointMake(self.orignalCentre.x, self.orignalCentre.y);
    return YES;
}

- (IBAction)onClickDonate:(id)sender {
    NSLog(@"Click Donate in coin");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OnDonateClicked"
     object:self];
    
}
@end
