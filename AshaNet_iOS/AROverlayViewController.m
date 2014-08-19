#import "AROverlayViewController.h"

@interface AROverlayViewController ()
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@property (retain, nonatomic) IBOutlet UIView *cameraView;
@property (retain, nonatomic) IBOutlet UIView *childView;

@property (retain, nonatomic) IBOutlet UIImageView *kidsImg;
@property (retain, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;

@property (retain, nonatomic) IBOutlet UIImageView *previewImg;
@property (weak, nonatomic) IBOutlet UIButton *donateBtn;
@property (weak, nonatomic) IBOutlet UILabel *captionLbl;
@property (weak, nonatomic) UIButton *overlayButton;
@property (weak, nonatomic) IBOutlet UIButton *snapBtn;

- (IBAction)onDonate:(id)sender;

@end

@implementation AROverlayViewController

@synthesize captureManager;
@synthesize scanningLabel;

- (void)viewDidLoad {
    
    NSLog(@"view load se");
	[self setCaptureManager:[[CaptureSessionManager alloc] init] ];
    
	[[self captureManager] addVideoInputFrontCamera:YES]; // set to YES for Front Camera, No for Back camera
    
    [[self captureManager] addStillImageOutput];
    
    self.captionLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:22];
    self.donateBtn.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:24];
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self childView] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[[[self childView] layer] addSublayer:[[self captureManager] previewLayer]];
    
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"boy3.jpg"]];
    [overlayImageView setFrame:CGRectMake(0, 0, 150, 350)];
    // [[self childView] addSubview:overlayImageView];
    [self.view bringSubviewToFront:self.captionLbl];
    [self.view bringSubviewToFront:self.retakeButton];
    [self.view bringSubviewToFront:self.snapBtn];
    [self.view bringSubviewToFront:self.donateBtn];
    [self.view sendSubviewToBack: self.childView];
  //  [overlayImageView release];
    
//    self.overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.overlayButton setImage:[UIImage imageNamed:@"capture.png"] forState:UIControlStateNormal];
//    [self.overlayButton setFrame:CGRectMake(120, 400, 97, 97)];
//    [self.overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//    [[self cameraView] addSubview:self.overlayButton];
    self.snapBtn.hidden = NO;
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 120, 30)];
    [self setScanningLabel:tempLabel];
  //  [tempLabel release];
	[scanningLabel setBackgroundColor:[UIColor clearColor]];
	[scanningLabel setFont:[UIFont fontWithName:@"Courier" size: 18.0]];
	[scanningLabel setTextColor:[UIColor redColor]];
	[scanningLabel setText:@"Saving..."];
    [scanningLabel setHidden:YES];
	[[self childView] addSubview:scanningLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum:) name:kImageCapturedSuccessfully object:nil];
    
	[[captureManager captureSession] startRunning];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        self.captionLbl.hidden = YES;
    });
}
- (void)viewWillAppear:(BOOL)animated{
    self.retakeButton.hidden = YES;
    self.donateBtn.hidden = YES;
    self.snapBtn.hidden = NO;
    self.captionLbl.hidden = NO;
    self.captionLbl.text = @"SPONSER KID WITH SELFIE";
    self.previewView.hidden = YES;
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        self.captionLbl.hidden = YES;
    });
}

- (IBAction)retakeClick:(id)sender {
    self.retakeButton.hidden = YES;
    self.donateBtn.hidden = YES;
    self.snapBtn.hidden = NO;
    self.captionLbl.hidden = NO;
    self.captionLbl.text = @"SPONSER KID WITH SELFIE";
    self.previewView.hidden = YES;
    [[captureManager captureSession] startRunning];
}

- (void)scanButtonPressed {
	//[[self scanningLabel] setHidden:NO];
    // [[self captureManager] captureStillImage];
    [[self captureManager] captureStillImageWithOverlay:self.kidsImg.image];
}

- (void)saveImageToPhotoAlbum:(NSNotification *) notification
{   UIImage *finalImage;
    if ([notification.name isEqualToString:@"imageCapturedSuccessfully"])
    {
        NSLog(@"clicked for testing!");
        
        self.retakeButton.hidden = NO;
        self.donateBtn.hidden = NO;
        self.snapBtn.hidden = YES;
        self.captionLbl.hidden = NO;
        self.captionLbl.text = @"DONATE TO SHARE";
        finalImage = [notification object];
        self.previewView.hidden = NO;
        self.previewImg.hidden = NO;
        self.previewImg.image = finalImage;
    }
  //  UIImageWriteToSavedPhotosAlbum(finalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (IBAction)snapTa:(id)sender {
    [[self captureManager] captureStillImageWithOverlay:self.kidsImg.image];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
     //   [alert release];
    }
    else {
        [[self scanningLabel] setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
//    [captureManager release], captureManager = nil;
//    [scanningLabel release], scanningLabel = nil;
//    [_cameraView release];
//    [_childView release];
//    [_kidsImg release];
//    [_kidsImg release];
//    [_previewView release];
//    [_previewImg release];
 //   [super dealloc];
}


- (void)viewDidUnload {
    [self setCameraView:nil];
    [self setChildView:nil];
    [self setKidsImg:nil];
    [self setKidsImg:nil];
    [self setPreviewView:nil];
    [self setPreviewImg:nil];
    [super viewDidUnload];
}
- (IBAction)onDonate:(id)sender {
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"Donate2Share"       object:nil];
}
@end

