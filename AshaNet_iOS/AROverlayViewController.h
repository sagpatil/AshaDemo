#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"

@interface AROverlayViewController : UIViewController {
    
}

@property (retain) CaptureSessionManager *captureManager;
@property (nonatomic, retain) UILabel *scanningLabel;
@property (assign, nonatomic) NSInteger index;

@end
