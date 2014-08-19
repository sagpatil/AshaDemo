//
//  NewProjectViewController.m
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/10/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "NewProjectViewController.h"
#import "Project.h"
#import <Parse/Parse.h>

#define kTYPEPICKERTAG 20
#define kFOCUSPICKERTAG 21
#define kAREAPICKERTAG 22

@interface NewProjectViewController ()
{
	UIPickerView *typePicker;
	UIPickerView *focusPicker;
    UIPickerView *areaPicker;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (assign, nonatomic) CGPoint originalCentre;
@property (weak, nonatomic) IBOutlet UITextView *purposeTxtView;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIButton *typeSelect;
@property (weak, nonatomic) IBOutlet UIButton *focusSelect;
@property (weak, nonatomic) IBOutlet UIButton *chapterSelect;
@property (weak, nonatomic) IBOutlet UIButton *areaSelect;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *areaField;

@property ( nonatomic) NSInteger focusId;
@property ( nonatomic) NSInteger typeId;


@end

@implementation NewProjectViewController

- (IBAction)onTapScreen:(id)sender {
    [self.view endEditing:(YES)];
    if ( !areaPicker.hidden) {
		areaPicker.hidden = YES;
	}
	if ( !typePicker.hidden) {
		typePicker.hidden = YES;
	}
    if ( !focusPicker.hidden) {
		focusPicker.hidden = YES;
	}
}

- (IBAction)onTapCancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onTapSave:(id)sender {
    PFObject *project = [PFObject objectWithClassName:@"Project"];
    project[@"Name"]= self.nameField.text;
    project[@"Description"]= self.descTextView.text;
    project[@"Purpose"] = self.purposeTxtView.text;
    project[@"Focus"] = [NSNumber numberWithInteger:_focusId];
    project[@"Project_type"] = [NSNumber numberWithInteger:_focusId];
    project[@"Area"] = self.areaField.titleLabel.text;
    project[@"Chapter"] = @"San Francisco";
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Project Save Complete");
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.contentSize =CGSizeMake(320, 800);
    self.originalCentre = self.scrollView.center;
    
    [[self.descTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.descTextView layer] setBorderWidth:0.5];
    [[self.descTextView layer] setCornerRadius:5];
    
    self.descTextView.delegate = self;
    self.descTextView.textColor = [UIColor lightGrayColor];
    
    [[self.purposeTxtView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.purposeTxtView layer] setBorderWidth:0.5];
    [[self.purposeTxtView layer] setCornerRadius:5];
    
    self.purposeTxtView.delegate = self;
    self.purposeTxtView.textColor = [UIColor lightGrayColor];
    
    typePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(20,350,280,160)];
	typePicker.tag = kTYPEPICKERTAG;
	typePicker.showsSelectionIndicator = TRUE;
	typePicker.dataSource = self;
	typePicker.delegate = self;
	typePicker.hidden = YES;
	areaPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(20,350,280,160)];
//	areaPicker.backgroundColor = [UIColor blueColor];
	areaPicker.tag = kAREAPICKERTAG;
	areaPicker.showsSelectionIndicator = TRUE;
	areaPicker.hidden = YES;
	areaPicker.dataSource = self;
	areaPicker.delegate = self;
    focusPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(20,350,280,160)];
	focusPicker.tag = kFOCUSPICKERTAG;
	focusPicker.showsSelectionIndicator = TRUE;
	focusPicker.dataSource = self;
	focusPicker.delegate = self;
	focusPicker.hidden = YES;
}

#pragma mark picker methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (pickerView.tag == kTYPEPICKERTAG)
		return [Project.TYPES count];
	else if (pickerView.tag == kFOCUSPICKERTAG)
		return [Project.PRIMARY_FOCUSES  count];
    else
        return [Project.AREAS count];
	
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == kTYPEPICKERTAG)
		return [Project.TYPES objectAtIndex:row];
	else if (pickerView.tag == kFOCUSPICKERTAG)
		return [Project.PRIMARY_FOCUSES  objectAtIndex:row];
    else
        return [Project.AREAS objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView.tag == kTYPEPICKERTAG) {
		NSString *type  = [Project.TYPES objectAtIndex:[pickerView selectedRowInComponent:0]];
        _typeId = row;
		[self.typeSelect setTitle:type forState:UIControlStateNormal];
		
	} else if (pickerView.tag == kFOCUSPICKERTAG){
		NSString *focus  = [Project.PRIMARY_FOCUSES objectAtIndex:[pickerView selectedRowInComponent:0]];
		[self.focusSelect setTitle:focus forState:UIControlStateNormal];
        _focusId = row;
		
	} else {
        NSString *area  = [Project.AREAS objectAtIndex:[pickerView selectedRowInComponent:0]];
		[self.areaSelect setTitle:area forState:UIControlStateNormal];
    }
	
}

- (IBAction)showTypePicker:(id)sender {
    if ( typePicker.hidden) {
		typePicker.hidden = NO;
        areaPicker.hidden = YES;
        focusPicker.hidden = YES;
		[self.view addSubview:typePicker];
	}
	else {
		typePicker.hidden = YES;
		[typePicker removeFromSuperview];
	}
}
- (IBAction)showAreaPicker:(id)sender {
    if ( areaPicker.hidden) {
		areaPicker.hidden = NO;
        typePicker.hidden = YES;
        focusPicker.hidden = YES;
		[self.view addSubview:areaPicker];
	}
	else {
		areaPicker.hidden = YES;
		[areaPicker removeFromSuperview];
	}
}
- (IBAction)showFocusPicker:(id)sender {
    if ( focusPicker.hidden) {
		focusPicker.hidden = NO;
        areaPicker.hidden = YES;
        typePicker.hidden = YES;
		[self.view addSubview:focusPicker];
	}
	else {
		focusPicker.hidden = YES;
		[focusPicker removeFromSuperview];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
