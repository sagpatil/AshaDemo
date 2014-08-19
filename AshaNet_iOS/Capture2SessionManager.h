#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@interface Capture2SessionManager : NSObject{

}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) CIContext *ciContext;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void)captureStillImageWithOverlay:(UIImage*)overlay;
- (void)addVideoInputFrontCamera:(BOOL)front;

@end
