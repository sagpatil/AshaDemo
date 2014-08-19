//
//  CoinView.h
//  animation
//
//  Created by Matt Mitchell on 7/19/14.
//  Copyright (c) 2014 Matt Mitchell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoinView : UIView <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *amountField;
@property (nonatomic, strong) UIButton *donateButton;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *colorHighlight;
@property (nonatomic, strong) NSString *colorShadow;

@end
