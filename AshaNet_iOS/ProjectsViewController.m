//
//  ProjectsViewController.m
//  AshaNet_iOS
//
//  Created by Savla, Sumit on 7/5/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "ProjectsViewController.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "UIColor+fromHex.h"
#import "CoinView.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Capture2SessionManager.h"

static NSString * KbuttonClick = @"OnDonateClicked";
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

@interface ProjectsViewController ()

@property (nonatomic, strong) NSMutableArray *projects;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *toRotateView;
@property (weak, nonatomic) IBOutlet UIView *donateView;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIImageView *slotImgView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
- (IBAction)onClickDonate:(id)sender;
- (IBAction)onMoreClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)onDollarClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *nameUIView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *stateLbl;
@property (weak, nonatomic) IBOutlet UIImageView *previewImg;
@property (weak, nonatomic) IBOutlet UIView *camView;
@property (weak, nonatomic) IBOutlet UIButton *snapBtn;
@property (weak, nonatomic) IBOutlet UILabel *typeLbl;

@property (weak, nonatomic) IBOutlet UIImageView *shareImgView;
@property (weak, nonatomic) IBOutlet UIButton *usdBtn;
@property (weak, nonatomic) IBOutlet UIImageView *idonatedImg;

@property (nonatomic, strong) NSNumber *donationAmount;
@property (weak, nonatomic) IBOutlet UIView *successView;
@property (assign, nonatomic) CGPoint orignalCentre;
@property (assign, nonatomic) CGPoint orignalCoinCentre;
@property (nonatomic, assign) CGPoint NameViewCentre;
@property (nonatomic, assign) CGPoint donateViewCentre;
@property (nonatomic, assign) CGPoint detailsViewCentre;

@property (weak, nonatomic) IBOutlet UIView *selfieView;

@property (nonatomic, strong) MPMoviePlayerController *player;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIImageView *shareViewCircle1;
@property (weak, nonatomic) IBOutlet UIImageView *shareViewCircle2;

- (IBAction)onTwitterTap:(id)sender;
- (IBAction)onFBTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *retakeBtn;
@property (weak, nonatomic) IBOutlet UILabel *selfieLbl;
@property (weak, nonatomic) IBOutlet UIButton *fbSelfieBtn;
@property (weak, nonatomic) IBOutlet UIView *shareSelfieView;
@property (weak, nonatomic) IBOutlet UIImageView *retakeCirView;
@property (weak, nonatomic) IBOutlet UIImageView *twitCirVIew;
@property (weak, nonatomic) IBOutlet UIImageView *fbCirView;
@property (weak, nonatomic) IBOutlet UIImageView *instaCirVIew;
- (IBAction)ontwitterSelfie:(id)sender;
- (IBAction)onInstagramSelfie:(id)sender;

@end

CGFloat degreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

@interface UIImage (Rotate)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end

@implementation UIImage (Rotate)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    CGContextRotateCTM(bitmap, degreesToRadians(degrees));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

@implementation ProjectsViewController
@synthesize captureManager;
BOOL donateViewUp;
BOOL detailsViewUp;
CoinView *coinView;
CGPoint orignalUsdCentre;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.projects = [[NSMutableArray alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackFinished)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.player];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(donateClicked:)
                                                     name:KbuttonClick
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:@"OnKeyBoardUpFromCoin"
                                                   object:nil];
        self.player = [[MPMoviePlayerController alloc] init];
        
    }
    return self;
    
}
-(void) playbackFinished{
    //   NSLog(@"      Stopped        ");
    [self.player play];
}

- (void)viewWillAppear:(BOOL)animated{
    //  NSLog(@"Will  appear %ld",(long)self.index);
    
    if(self.index == 4 || self.index == 6)
    {
        
        [self.player play];
    }
    
    self.nameUIView.center = CGPointMake(self.NameViewCentre.x - self.nameUIView.frame.size.width,self.NameViewCentre.y );
    self.donateView.alpha = 0;
    self.detailsView.alpha = 0;
    self.toRotateView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.donateView.alpha = 1;
        self.detailsView.alpha = 1;
        self.toRotateView.alpha = 1;
        self.nameUIView.center = CGPointMake(self.NameViewCentre.x,self.NameViewCentre.y );
    } completion:^(BOOL finished){
        
      
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    //#TODO if index = 3 or 5 then remove video
    
    self.donateView.alpha =1;
    self.detailsView.alpha = 1;
    self.toRotateView.alpha = 1;
    self.nameUIView.center = CGPointMake(self.NameViewCentre.x,self.NameViewCentre.y );
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.nameUIView.center = CGPointMake(self.NameViewCentre.x -self.nameUIView.frame.size.width,self.NameViewCentre.y );
        self.donateView.alpha = 0;
        self.detailsView.alpha = 0;
        self.toRotateView.alpha = 0;
    } completion:^(BOOL finished) {
        
        
    }];
}

- (void)viewDidDisappear:(BOOL)animated{
    if(self.index == 3 || self.index == 5)
    {
        // [self.player.view removeFromSuperview];
        // NSLog(@"    Video  Player removed        ");
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.index == 4 || self.index == 6){
        NSURL *portraitUrl;
        
        if (self.index == 4)
            portraitUrl = [[NSBundle mainBundle] URLForResource:@"boat" withExtension:@"mp4"];
        else 
            portraitUrl = [[NSBundle mainBundle] URLForResource:@"girls" withExtension:@"mp4"];
        
        [self.player setContentURL:portraitUrl];
        [self.player.view setFrame: CGRectMake(0, 0, 320, 568)];
        [self.imageView addSubview:self.player.view];
        self.player.controlStyle = MPMovieControlStyleNone;
    }
    
    donateViewUp = NO;
    detailsViewUp = NO;
    self.shareView.hidden = YES;
    
    self.snapBtn.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:32];
    self.snapBtn.backgroundColor = [UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1];
    
    self.nameLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:18];
    self.typeLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:15];
    self.selfieLbl.font = [UIFont fontWithName:@"COCOGOOSE" size:16];
    self.selfieLbl.textColor = [UIColor colorwithHexString:self.selectedProject.colorShadow alpha:1];
    self.descriptionLabel.font = [UIFont fontWithName:@"Gotham-Light" size:14];
    self.moreButton.titleLabel.font = [UIFont fontWithName:@"COCOGOOSE" size:15];
    
    self.imageView.image = self.selectedProject.projectImage;
    self.descriptionLabel.text = self.selectedProject.description;
    [self resizeName];
    self.nameLbl.text = [self.selectedProject.name uppercaseString];
    self.typeLbl.text = [self.selectedProject.area uppercaseString];
    self.shareImgView.hidden = YES; // hide the old share image #TODO delete this from nib and file once we get other in
    
    self.donateView.center = CGPointMake(395, 760);
    self.orignalCentre = self.donateView.center;
    self.detailsView.center = CGPointMake(160, 575);
    [self.scrollView setScrollEnabled:NO];
    self.scrollView.center = CGPointMake(160, 80);
    
    UIImageView *gradientImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -140, 320, 741)];
    gradientImageView.image = [[UIImage imageNamed:@"gradient"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    gradientImageView.tintColor = [UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1];
    
    [self.detailsView addSubview:gradientImageView];
    [self.detailsView sendSubviewToBack:gradientImageView];
    
    CGRect newFrame = self.descriptionLabel.frame;
    newFrame.size.width = 280;
    newFrame.size.height = 110;
    [self.descriptionLabel setFrame:newFrame];
    
    self.nameUIView.backgroundColor = [UIColor colorwithHexString:self.selectedProject.color alpha:1];
    [self addShadows:self.nameUIView.layer];
    self.donateView.backgroundColor = [UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1];
    self.toRotateView.backgroundColor = [UIColor colorwithHexString:self.selectedProject.color alpha:1];
    self.detailsView.backgroundColor = [UIColor clearColor];
    self.donateView.backgroundColor = [UIColor clearColor];
    self.shareImgView.center = CGPointMake(30, 200);
    self.moreButton.center = CGPointMake(160, 170);
    
    self.toRotateView.center = CGPointMake(498,708);
    self.toRotateView.transform = CGAffineTransformMakeRotation(M_PI/4);
    orignalUsdCentre = self.usdBtn.center;
    
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
    
    coinView = [[CoinView alloc] initWithFrame:CGRectMake(0, 50, 320, 320)];
    coinView.color = self.selectedProject.color;
    coinView.colorHighlight = self.selectedProject.colorHighlight;
    coinView.colorShadow = self.selectedProject.colorShadow;
    [coinView setBackgroundColor:[UIColor clearColor]];
    [self.donateView addSubview:coinView];
    self.orignalCoinCentre = coinView.center;
    [self.donateView sendSubviewToBack:coinView];
    [self.donateView addSubview:self.successView];
    self.successView.center = CGPointMake(160, 165);
    self.successView.hidden = YES;
    [self.donateView sendSubviewToBack:self.successView];
    [self.view sendSubviewToBack:self.baseView];
    [self.view bringSubviewToFront:self.detailsView];
    [self.shareView setBackgroundColor:[UIColor clearColor]];
    self.shareViewCircle1.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.shareViewCircle1.tintColor = [UIColor colorwithHexString:self.selectedProject.color alpha:1];
    self.shareViewCircle2.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.shareViewCircle2.tintColor = [UIColor colorwithHexString:self.selectedProject.color alpha:1];
    [self.view bringSubviewToFront:self.shareView];
    
    self.previewImg.hidden = NO;
   /* self.selfieView.clipsToBounds = YES;
    [self setRoundedView:self.selfieView toDiameter:170];
    self.camView.clipsToBounds = YES;
    [self setRoundedView:self.camView toDiameter:170];
    self.previewImg.clipsToBounds = YES;
    [self setRoundedView:self.previewImg toDiameter:170];*/
    
    //C1
        [self setCaptureManager:[[Capture2SessionManager alloc] init] ];
        
        [[self captureManager] addVideoInputFrontCamera:YES]; // set to YES for Front Camera, No for Back camera
        
        [[self captureManager] addStillImageOutput];
        
        [[self captureManager] addVideoPreviewLayer];
        CGRect layerRect = [[[self camView] layer] bounds];
        [[self captureManager] previewLayer].cornerRadius = (170/ 2);
        [[[self captureManager] previewLayer] setBounds:layerRect];
        [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
        [[[self camView] layer] addSublayer:[[self captureManager] previewLayer]];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum:) name:kImageCapturedSuccessfully object:nil];
    
    [self.selfieView sendSubviewToBack: self.camView];
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}
- (IBAction)smileTap:(id)sender {
    [[self captureManager] captureStillImage];
  //  [[self captureManager] captureStillImageWithOverlay:self.kidsImg.image];
}

- (void)saveImageToPhotoAlbum:(NSNotification *) notification
{   UIImage *finalImage;
    if ([notification.name isEqualToString:@"imageCapturedSuccessfully"])
    {
        finalImage = [notification object];
        mTakenPhoto = finalImage;
        CGRect newFrame = self.selfieLbl.frame;
        newFrame.origin.y = self.selfieLbl.frame.origin.y - 50;
        [self.selfieLbl setFrame:newFrame];
        
        newFrame = self.shareSelfieView.frame;
        newFrame.origin.y = self.shareSelfieView.frame.origin.y - 50;
        [self.shareSelfieView setFrame:newFrame];
        
        self.snapBtn.hidden =YES;
        self.selfieLbl.text = @"(SHARE YOUR SELFLESS SELFIE)";
        self.shareSelfieView.hidden = NO;
        [self.selfieView sendSubviewToBack:self.camView];
        self.previewImg.image = finalImage;
        self.previewImg.hidden = NO;
    }
  //  UIImageWriteToSavedPhotosAlbum(finalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        self.snapBtn.hidden = YES;
    }
}

-(void)shareTapDetected {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    NSArray *lines = @[@"Asha Project information:\n", [NSString stringWithFormat:@"Name: %@\n", self.selectedProject.name],[NSString stringWithFormat:@"Description: %@", self.selectedProject.description]];
    NSString *linesString = [lines componentsJoinedByString:@"\n"];
    
    [sharingItems addObject: linesString];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void) resizeName{
    CGRect r = [[self.selectedProject.name uppercaseString]boundingRectWithSize:CGSizeMake(300, 0)
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
    NSLog(@" Centre %f %f",self.NameViewCentre.x,self.NameViewCentre.y);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleSwipeUpFrom:(UIGestureRecognizer*)recognizer {
    self.donateView.backgroundColor = [UIColor colorwithHexString:self.selectedProject.color alpha:1];
    [self.donateView setBackgroundColor:[UIColor clearColor]];
    [self.toRotateView bringSubviewToFront:coinView];
    self.nameUIView.backgroundColor = [UIColor colorwithHexString:self.selectedProject.colorShadow alpha:1];

    
    [UIView animateWithDuration:0.3 animations:^{
        self.shareView.hidden = YES;
        self.usdBtn.hidden = YES;
        self.slotImgView.hidden = YES;
        self.successView.hidden = YES;
     
        //c1
        [[captureManager captureSession] startRunning];
        
        coinView.hidden= NO;
        self.donateView.center = CGPointMake(160, 300);
        
        self.toRotateView.center = CGPointMake(310, 310);
       // [self.toRotateView bringSubviewToFront:coinView];
        [self.toRotateView bringSubviewToFront:self.successView];
        [coinView bringSubviewToFront:coinView.amountField];
        self.usdBtn.alpha = 0;
        donateViewUp = YES;
            [self.view bringSubviewToFront:self.nameUIView];
    }];
    
    // Disable PageViewController scroll when RotatedView is up
    for (UIScrollView *view in self.parentViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = NO;
        }
    }
}

- (void) handleSwipeDownFrom:(UIGestureRecognizer*)recognizer {
    self.donateView.backgroundColor = [UIColor clearColor];
    [coinView.amountField endEditing:YES];
    [self.toRotateView sendSubviewToBack:coinView];
    [self.toRotateView bringSubviewToFront:coinView];
    self.nameUIView.backgroundColor = [UIColor colorwithHexString:self.selectedProject.color alpha:1];
    
    //c1
    if (self.selectedProject.name.length %2 != 0) {
        [[captureManager captureSession] stopRunning];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.toRotateView.center = CGPointMake(460, 700);
        self.donateView.center = self.orignalCentre;
        coinView.center = self.orignalCoinCentre;
        self.usdBtn.alpha = 1;
        donateViewUp = NO;
        NSLog(@"Slide down");
    } completion:^(BOOL finished){
        NSLog(@"completion");
        self.usdBtn.hidden = NO;
        self.slotImgView.hidden = NO;
        self.successView.hidden = YES;
        self.toRotateView.center = CGPointMake(499,709);
    }];
    // Enabble PageViewController scroll when RotatedView is down
    for (UIScrollView *view in self.parentViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = YES;
        }
        
    }
}


- (IBAction)onMoreClick:(id)sender {
    if (detailsViewUp) {
      
        CGRect newFrame = self.scrollView.frame;
        newFrame.size.width = 320;
        newFrame.size.height = 170;
        [self.scrollView setFrame:newFrame];
        [self.scrollView setScrollEnabled:NO];
        self.scrollView.contentSize = CGSizeMake(280, 200);
   //     self.scrollView.center = CGPointMake(160, 70);
        [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        
        [self.moreButton setTitle:@"MORE…" forState:UIControlStateNormal];
        self.shareImgView.center = CGPointMake(30, 200);
        self.moreButton.center = CGPointMake(160, 170);
        self.descriptionLabel.numberOfLines = 10;
        newFrame = self.descriptionLabel.frame;
        newFrame.size.width = 280;
        newFrame.size.height = 100;
        [self.descriptionLabel setFrame:newFrame];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        newFrame = self.detailsView.bounds;
        newFrame.size = CGSizeMake(320, 205);
        gradient.frame = newFrame;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1].CGColor, nil];
        gradient.startPoint = CGPointMake(1.0f, 0.0f);
        gradient.endPoint = CGPointMake(1.0f, 1.0f);
        [self.detailsView.layer insertSublayer:gradient atIndex:0];
                self.shareView.alpha = 1;
        
        self.detailsView.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:0.3 animations:^{
                    self.shareView.alpha = 0;
            self.detailsView.center = CGPointMake(160, 570);
            self.detailsView.backgroundColor = [UIColor clearColor];
        }completion:^(BOOL finished) {
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
        CGRect newFrame = self.scrollView.frame;
        newFrame.size.width = 320;
        newFrame.size.height = 280;
        [self.scrollView setFrame:newFrame];
        
        [self.scrollView setScrollEnabled:YES];
        
        CGRect frm = self.descriptionLabel.frame;
        frm.origin.y = self.typeLbl.frame.size.height + 10;
        self.descriptionLabel.frame = frm;
        self.descriptionLabel.numberOfLines = 0;
        [self.descriptionLabel sizeToFit];
        [self.scrollView setContentSize: CGSizeMake(280, self.descriptionLabel.frame.size.height + 60)];
        
        [self.moreButton setTitle:@"LESS…" forState:UIControlStateNormal];
        self.shareImgView.center = CGPointMake(30, 345);
        self.moreButton.center = CGPointMake(160, 310);
       
        self.shareView.hidden = NO;
        self.shareView.alpha = 0;
        
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.detailsView.center = CGPointMake(160, 400);
            self.shareView.alpha = 1;
            //     self.detailsView.backgroundColor = [UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1];
        } completion:^(BOOL finished) {

        }];
        detailsViewUp = YES;
        
        // Disable PageViewController scroll when RotatedView is up
        for (UIScrollView *view in self.parentViewController.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                view.scrollEnabled = NO;
            }
        }
    }
    
}

- (IBAction)onDollarClick:(id)sender {
    
    if (donateViewUp) {
        [self handleSwipeDownFrom:nil];
    }
    else{
        [self handleSwipeUpFrom:nil];
    }
}

- (void) keyboardWillShow:(NSNotification *) notification{
    
    if ([[notification name] isEqualToString:@"OnKeyBoardUpFromCoin"]){
        
        NSLog(@"Keyboard UP");
        
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.donateView.center = CGPointMake(160, 200);
            self.toRotateView.center = CGPointMake(310, 210);
        } completion:nil];
        
    }
}


- (void) donateClicked:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:KbuttonClick]){
        NSLog (@"Successfully received the test notification!");
        [self onClickDonate:nil];
    }
}

- (IBAction)onClickDonate:(id)sender {
    NSLog(@"click donate");
    
    [self.view bringSubviewToFront:self.donateView];
    PayPalConfig *PPconfig  = [PayPalConfig sharedConfig];
    [PPconfig setupForTakingPayments];
    
    [self resignFirstResponder];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Invalid amount"
                                                      message:@"Please enter a valid value greater than 0"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    
    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:coinView.amountField.text];
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
    payment.shortDescription = [NSString stringWithFormat:@"Donation to %@ Project of Ashanet",self.selectedProject.name];
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
    
    coinView.hidden = YES;
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
    donation[@"project"] = self.selectedProject.name;
    donation[@"paypal_confirmation_id"] = response[@"response"][@"id"];
    [donation saveInBackground];
}

#pragma mark - Helpers

// Animation effect where the success message can be shown on our View controller which disappears after 2 seconds
- (void)showSuccess {
   
    [self.view bringSubviewToFront:self.successView];
    self.donateView.center = CGPointMake(160, 340);
    self.successView.hidden = NO;
    self.retakeCirView.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.retakeCirView.tintColor = [UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1];
    self.fbCirView.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.fbCirView.tintColor = [UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1];
    self.twitCirVIew.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.twitCirVIew.tintColor = [UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1];
    self.instaCirVIew.image = [[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.instaCirVIew.tintColor = [UIColor colorwithHexString:self.selectedProject.colorHighlight alpha:1];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    //    [UIView setAnimationDelay:4.0];
    self.successView.center = CGPointMake(160, 300);
    CGRect newFrame = self.selfieView.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = 0;
    [self.selfieView setFrame:newFrame];
    [UIView commitAnimations];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:touch.view];
    if (donateViewUp){
        if([self didClickOnTriangleImage:location]){
            NSLog(@"Inside traiangle click ");
            [self handleSwipeDownFrom:nil];
        }
        
    }
    
    if(touch.view == self.baseView){
        NSLog(@" Touched on Base");
        
    }
    else  if(touch.view == self.donateView){
        NSLog(@" Touched on DonateView");
    }
    else  if(touch.view == self.toRotateView)
        NSLog(@" Touched on RoateView");
    else if(touch.view == self.imageView)
        NSLog(@" Touched on IMage");
    else if(touch.view == self.detailsView)
        NSLog(@" Touched on details");
    else if(touch.view == coinView)
        NSLog(@" Touched on Coin");
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
        NSLog(@"touchMoved");
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchEnded");
}
-(BOOL)didClickOnTriangleImage:(CGPoint) location{
    
    CGPoint a = CGPointMake(170, 24);
    CGPoint b = CGPointMake(90, 53);
    
    float ar =  ((b.x - a.x)*(location.y - a.y) - (b.y - a.y)*(location.x - a.x));
    if(ar > 0)
        return YES;
    
    return NO;
}
- (IBAction)onThankYouTap:(id)sender {
    [self handleSwipeDownFrom:nil];
}
- (IBAction)onTwitterTap:(id)sender {
    NSLog(@"    twitte          ");
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSArray *lines = @[@"Check out the Asha Project:\n", [NSString stringWithFormat:@"Name: %@\n", self.selectedProject.name],[NSString stringWithFormat:@"Site: www.ashanet.org"]];
    NSString *linesString = [lines componentsJoinedByString:@"\n"];
    [controller setInitialText:linesString];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onFBTap:(id)sender {
    NSLog(@" FB ");
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSArray *lines = @[@"Check out the Asha Project:\n", [NSString stringWithFormat:@"Name: %@\n", self.selectedProject.name],[NSString stringWithFormat:@"Site: www.ashanet.org"]];
    NSString *linesString = [lines componentsJoinedByString:@"\n"];
    [controller setInitialText:linesString];
    [self presentViewController:controller animated:YES completion:nil];

}

- (UIImage *)cropImage:(UIImage *)image toSize:(CGSize)size circular:(BOOL)circular
{
    CGFloat minimumSize = MIN(image.size.width, image.size.height);
    CGRect imageViewFrame = CGRectMake(0, 0, minimumSize, (image.size.width * (size.height / size.width)));
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = image;
    imageView.transform = CGAffineTransformMakeRotation(M_PI);
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = (circular) ? (minimumSize / 2) : 0;
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.opaque, [[UIScreen mainScreen] scale]);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

- (IBAction)facebookShare:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:@"Share smiles :) Just donated to Asha for Education!"];
        [mySLComposerSheet addImage:mTakenPhoto];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Facebook is not available"
                                  message:@"Make sure your device has an internet connection and you have at least one Facebook account added"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (IBAction)shareTwitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:@"Your text here"];

        [mySLComposerSheet addImage:mTakenPhoto];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Facebook is not available"
                                  message:@"Make sure your device has an internet connection and you have at least one Twitter account added"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (IBAction)shareInstagram:(id)sender {
//    UIImage *image = [self resizeImage:mTakenPhoto scaledToSize:CGSizeMake(640, 480)];
//    image = [image imageRotatedByDegrees:90.0];
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/originalImage.ig"];
    [UIImagePNGRepresentation(mTakenPhoto) writeToFile:savePath atomically:YES];
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
        _documentController.UTI = @"com.instagram.exclusivegram";
        _documentController.delegate = self;
        _documentController.annotation = [NSDictionary dictionaryWithObject:@"Your Caption here" forKey:@"InstagramCaption"];
        [_documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}

- (UIImage *)resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) addShadows:(CALayer *)layer{
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 4;
    layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
}
- (IBAction)onClickCapture:(id)sender {
    NSLog(@"Click capture");
    [[self captureManager] captureStillImageWithOverlay:self.idonatedImg.image];
    
}
- (IBAction)sharefb:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:@"Share smiles :) Just donated to Asha for Education!"];
        [mySLComposerSheet addImage:mTakenPhoto];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}
- (IBAction)snapTap:(id)sender {
    NSLog(@"Click capture");
    [[self captureManager] captureStillImageWithOverlay:self.idonatedImg.image];
}

- (IBAction)retakeTap:(id)sender {
    self.snapBtn.hidden = NO;
    self.selfieLbl.text = @"(SHARE YOUR SELFLESS SELFIE)";
    CGRect newFrame = self.selfieLbl.frame;
    newFrame.origin.y = self.selfieLbl.frame.origin.y + 50;
    
    [self.selfieLbl setFrame:newFrame];
    newFrame = self.shareSelfieView.frame;
    newFrame.origin.y = self.shareSelfieView.frame.origin.y + 50;
    [self.shareSelfieView setFrame:newFrame];
    self.shareSelfieView.hidden = YES;
    self.previewImg.hidden = YES;
    [[captureManager captureSession] startRunning];
}
- (IBAction)ontwitterSelfie:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:@"Share smiles :) Just donated to Asha for Education!"];
        [mySLComposerSheet addImage:mTakenPhoto];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}

- (IBAction)onInstagramSelfie:(id)sender {
    
}
@end
