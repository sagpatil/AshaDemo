//
//  webViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/27/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "webViewController.h"
#import "MBProgressHUD.h"
#import "UIColor+fromHex.h"

@interface webViewController ()
@property (nonatomic,assign)int webViewLoads_;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)onBackButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *navBar;

@end

@implementation webViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor* color = [UIColor colorwithHexString:self.color alpha:1];
    self.navBar.backgroundColor = color;
    self.webView.delegate=self;
    NSLog(@"URL %@",self.url);
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:requestObj];
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

//#TOdo figure out when paeg laod completes


- (void)webViewDidFinishLoad:(UIWebView *)webView{

       [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        NSLog(@"COmpleted loading");
     
    }
    
    
    //    NSString *javaScript = @"function myFunction(){return 1+1;}";
    //    [webView stringByEvaluatingJavaScriptFromString:javaScript];
    
    //    NSLog(@"Current URL = %@",webView.);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackButton:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


@end