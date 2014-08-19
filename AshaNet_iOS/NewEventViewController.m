//
//  NewEventViewController.m
//  AshaNet_iOS
//
//  Created by Patil, Sagar on 7/10/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "NewEventViewController.h"
#import <Parse/Parse.h>
#import "UIColor+fromHex.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

static NSString *KPlaceHolderText = @"DETAILS";
static NSString *kSaveCkicked = @"NewProjectorEventAdded";

@interface NewEventViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *dateTimeButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *chooseDateLabel;
@property (assign, nonatomic) CGPoint orignalCentre;
@property  (nonatomic,strong) NSDate *eventDate;
@property (weak, nonatomic) IBOutlet UILabel *addNewEventLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;

@property (weak, nonatomic) IBOutlet UIButton *colorRedButton;
@property (weak, nonatomic) IBOutlet UIButton *colorPinkButton;
@property (weak, nonatomic) IBOutlet UIButton *colorPurpleButton;
@property (weak, nonatomic) IBOutlet UIButton *colorBlueButton;
@property (weak, nonatomic) IBOutlet UIButton *colorCyanButton;
- (IBAction)onColorTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *locView;
@property (weak, nonatomic) IBOutlet UIView *urlView;
@property (weak, nonatomic) IBOutlet UIScrollView *colorScrollView;
@property (weak, nonatomic) IBOutlet UIView *dateView;


- (IBAction)onSavetap:(id)sender;
- (IBAction)onCanceltap:(id)sender;
- (IBAction)onSelectPhotoTap:(id)sender;
- (IBAction)onDatePickerButtonTap:(id)sender;
- (IBAction)onScrollViewTap:(UITapGestureRecognizer *)sender;
@end

@implementation NewEventViewController


-(UIImagePickerController *)imagePicker{
    if(!_imagePicker){

        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.delegate= self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    return _imagePicker;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-
(void)viewDidLoad
{
    [super viewDidLoad];
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    [[UITextView appearance] setTintColor:[UIColor whiteColor]];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 10, 80)];
    self.nameTextField.leftView = paddingView;
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
    UIEdgeInsets padding = UIEdgeInsetsMake(5, 100, 100, 40);
    float paddingf = 5.0;
    
    NSMutableParagraphStyle *editorParagraphStyle = [NSMutableParagraphStyle new];
    [editorParagraphStyle setHeadIndent:paddingf];
    [editorParagraphStyle setFirstLineHeadIndent:paddingf];
    [editorParagraphStyle setTailIndent:-paddingf];
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"COCOGOOSE" size:17],
                                     NSParagraphStyleAttributeName: editorParagraphStyle
                                     };
    
    [self.descriptionTextView setAttributedText:[[NSAttributedString alloc] initWithString:self.descriptionTextView.text
                                                                     attributes:textAttributes]];
    
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
    
    
    self.datePicker.hidden = YES;
    self.scrollView.contentSize =CGSizeMake(320, 600);
        self.colorScrollView.contentSize =CGSizeMake(400, 52);
    self.orignalCentre = self.scrollView.center;
    self.urlTextField.delegate = self;
    self.urlTextField.textColor = [UIColor whiteColor];
    self.urlTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"URL" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.addressTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"LOCATION" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EVENT NAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.addressTextField.delegate=self;
    self.nameTextField.delegate = self;

    [self.datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    [[self.descriptionTextView layer] setBorderWidth:0];
    [[self.descriptionTextView layer] setCornerRadius:0];
    
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.text = KPlaceHolderText;
    self.descriptionTextView.textColor = [UIColor whiteColor];
    
   

    self.colorRedButton.tintColor = [UIColor colorwithHexString:@"E51C23" alpha:1];
    UIImage *imageRed = [self.colorRedButton.currentBackgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.colorRedButton setBackgroundImage:imageRed forState:UIControlStateNormal];
    [self.colorRedButton setBackgroundImage:imageRed forState:UIControlStateSelected];
    
    self.colorPinkButton.tintColor = [UIColor colorwithHexString:@"E91E63" alpha:1];
    UIImage *imagePink = [self.colorPinkButton.currentBackgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.colorPinkButton setBackgroundImage:imagePink forState:UIControlStateNormal];
    [self.colorPinkButton setBackgroundImage:imagePink forState:UIControlStateSelected];
    
    self.colorPurpleButton.tintColor = [UIColor colorwithHexString:@"9C27B0" alpha:1];
    UIImage *imagePurple = [self.colorPurpleButton.currentBackgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.colorPurpleButton setBackgroundImage:imagePurple forState:UIControlStateNormal];
    [self.colorPurpleButton setBackgroundImage:imagePurple forState:UIControlStateSelected];
    
    self.colorBlueButton.tintColor = [UIColor colorwithHexString:@"5677FC" alpha:1];
    UIImage *imageBlue = [self.colorBlueButton.currentBackgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.colorBlueButton setBackgroundImage:imageBlue forState:UIControlStateNormal];
    [self.colorBlueButton setBackgroundImage:imageBlue forState:UIControlStateSelected];
    
    self.colorCyanButton.tintColor = [UIColor colorwithHexString:@"03A9F4" alpha:1];
    UIImage *imageCyan = [self.colorCyanButton.currentBackgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.colorCyanButton setBackgroundImage:imageCyan forState:UIControlStateNormal];
    [self.colorCyanButton setBackgroundImage:imageCyan forState:UIControlStateSelected];

    
    self.addNewEventLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:18];
    self.nameTextField.font = [UIFont fontWithName:@"COCOGOOSE" size:17];
    self.descriptionTextView.font = [UIFont fontWithName:@"COCOGOOSE" size:17];
    self.addressTextField.font = [UIFont fontWithName:@"COCOGOOSE" size:17];
    self.urlTextField.font = [UIFont fontWithName:@"COCOGOOSE" size:17];
    self.chooseDateLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:17];
    self.saveButton.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:24];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker)];
    singleTap.numberOfTapsRequired = 1;
    
    [self.chooseDateLabel addGestureRecognizer:singleTap];
    [self.backgroundImage setImage:[self blurImage:self.backgroundImage.image]];

    [self setFieldColors:@"9E9E9E"]; // set backGround gray
    
    
 
   
}

- (UIImage *) blurImage: (UIImage *)orignalImage{
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:[orignalImage CGImage]] forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@5 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    CGRect rect          = [outputImage extent];
    
    // these three lines ensure that the final image is the same size
    
    rect.origin.x        += (rect.size.width  - orignalImage.size.width ) / 2;
    rect.origin.y        += (rect.size.height - orignalImage.size.height) / 2;
    rect.size            = orignalImage.size;
    
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:rect];
    UIImage *blurredImage       = [UIImage imageWithCGImage:cgimg];
    return blurredImage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)datePickerChanged:(UIDatePicker *)datePicker
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yy hh:mma"];
    self.eventDate = datePicker.date;
    NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
    self.dateTimeButton.titleLabel.text = [NSString stringWithFormat:@"        %@",strDate];
    self.chooseDateLabel.text = strDate;
     NSLog(@"    date   %@       ",self.dateTimeButton.titleLabel.text);
}

#pragma mark Button Methods

- (IBAction)onColorTap:(id)sender {
    
    self.colorRedButton.selected = NO;
    self.colorPurpleButton.selected = NO;
    self.colorPinkButton.selected = NO;
    self.colorCyanButton.selected = NO;
    self.colorBlueButton.selected = NO;
    
    UIButton *button = sender;
    button.selected = YES;
    
    if (sender == self.colorRedButton) {
        [self setFieldColors:@"E51C23"];
    }
    else if (sender == self.colorPinkButton){
        [self setFieldColors:@"E91E63"];
    }

    else if (sender == self.colorPurpleButton)
    {
        [self setFieldColors:@"9C27B0"];
    }
    
    else if (sender == self.colorBlueButton){
        [self setFieldColors:@"5677FC"];
    }
    
    else if (sender == self.colorCyanButton){
        [self setFieldColors:@"03A9F4"];
    }

}

- (void) setFieldColors:(NSString *)colorString{
    [UIView animateWithDuration:0.2 animations:^{
        
        self.nameTextField.backgroundColor          = [UIColor colorwithHexString:colorString alpha:1];
        self.dateView.backgroundColor        = [UIColor colorwithHexString:colorString alpha:1];
        self.locView.backgroundColor       = [UIColor colorwithHexString:colorString alpha:1];
        self.descriptionTextView.backgroundColor    = [UIColor colorwithHexString:colorString alpha:1];
        self.urlView.backgroundColor           = [UIColor colorwithHexString:colorString alpha:1];
        self.selectPhotoButton.backgroundColor      = [UIColor colorwithHexString:colorString alpha:1];
        self.datePicker.backgroundColor             = [UIColor colorwithHexString:colorString alpha:1];
        
    }];
}

- (IBAction)onSavetap:(id)sender {
      NSLog(@"Save Tapped");
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFObject *event = [PFObject objectWithClassName:@"Event"];
    event[@"Name"]= self.nameTextField.text;
    event[@"Description"]= self.descriptionTextView.text;
    
    NSString *url = self.urlTextField.text;
    if ( [[url lowercaseString] hasPrefix:@"http://"] == NO)
        url =  [NSString stringWithFormat:@"http://%@", url];
    
    event[@"Ticket_site_url"] = url;
    event[@"Address"] = self.addressTextField.text;
    event[@"Event_time"] = self.eventDate;
    
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    event[@"Image"] = imageFile;
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Save Complete");
        [[NSNotificationCenter defaultCenter] postNotificationName:kSaveCkicked       object:event];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        
    }];
}

- (IBAction)onCanceltap:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onSelectPhotoTap:(id)sender {
     self.datePicker.hidden = YES;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take New",@"Choose Existing.." , nil];
    
    [actionSheet showInView:self.scrollView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Take a photo
        
        [self presentViewController:self.imagePicker animated:YES completion:nil];


    }
    else if (buttonIndex == 1) {
        
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:self.imagePicker animated:YES completion:^{
           NSLog(@"Changeme");
        }];

    }
       self.scrollView.center = self.orignalCentre ;
}


- (IBAction)onDatePickerButtonTap:(id)sender {
    
    self.scrollView.center = CGPointMake(160,150);
    // add the bwlow line for every textField
    [self.urlTextField resignFirstResponder];
    [self.addressTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    self.datePicker.hidden = NO;
    
}

- (IBAction)onScrollViewTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    self.datePicker.hidden = YES;
    self.saveButton.hidden = NO;
}

#pragma mark UIITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"Change me");
    self.datePicker.hidden = YES;
            self.saveButton.hidden = NO;
    if (textField == self.urlTextField) {
        //self.scrollView.center = CGPointMake(160, 180);
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self resignFirstResponder];
    //self.scrollView.center = CGPointMake(self.orignalCentre.x, self.orignalCentre.y);
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"Editing");
    // enter closes the keyboard
    if ([string isEqualToString:@"\n"])
    {
        NSLog(@"Editing ended");
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    UIImage *reducedImage = [self imageWithImage:chosenImage scaledToSize:CGSizeMake(320, 568)];
    self.imageView.image = reducedImage;
    [self.backgroundImage setImage:[self blurImage:reducedImage]];

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark UItextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:KPlaceHolderText]) {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = KPlaceHolderText;
        textView.textColor = [UIColor whiteColor]; //optional
    }
    [textView resignFirstResponder];
        self.saveButton.hidden = NO;
}

-(void) showDatePicker{
    NSLog(@"label tapped");
    self.saveButton.hidden = YES;
    [self onDatePickerButtonTap:nil];
    
}


- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
