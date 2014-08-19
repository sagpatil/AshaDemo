#import "Capture2SessionManager.h"
#import <ImageIO/ImageIO.h>

@implementation Capture2SessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

- (void)addVideoInputFrontCamera:(BOOL)front {
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (front) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
                [[self captureSession] addInput:backFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}

- (void)addStillImageOutput
{
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [[self captureSession] addOutput:output];
    // What different things can we register to recognise?
    // NSLog(@"%@", [output availableMetadataObjectTypes]);
    // We're only interested in faces
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    // This VC is the delegate. Please call us on the main queue
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init] ];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            NSLog(@"mirror");
            [videoConnection setVideoMirrored:NO];
            break;
        }
    }
    
    [[self captureSession] addOutput:[self stillImageOutput]];
}


- (void)captureStillImage
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            NSLog(@"mirror2");
            [videoConnection setVideoMirrored:YES];
            break;
        }
	}
    
	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                             if (exifAttachments) {
                                                                 //   NSLog(@"attachements: %@", exifAttachments);
                                                             } else {
                                                                 NSLog(@"no attachments");
                                                             }
                                                             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                             
                                                             CGFloat size = MIN(170, 170);
                                                             UIImage *img = [UIImage imageWithData:imageData];
                                                          CGSize previewSize = CGSizeMake(size, size);
                                                           UIImage *image = [self cropImage:img toSize:previewSize circular:YES];
                                                              
                                                           //  UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                             [self setStillImage:image];
                                                             //[image release];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:image];
                                                         }];
                                            
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

- (void)captureStillImageWithOverlay:(UIImage*)overlay
{
	AVCaptureConnection *videoConnection = nil;
    
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            NSLog(@"mirror");
            [videoConnection setVideoMirrored:YES];
            break;
        }
	}
    
	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                             if (exifAttachments) {
                                                                 NSLog(@"attachements: %@", exifAttachments);
                                                             } else {
                                                                 NSLog(@"no attachments");
                                                             }
                                                             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                             
                                                             UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                             UIGraphicsBeginImageContext(CGSizeMake(320, 320));
                                                             
                                                             UIImage *processedImage = [self cropImage:image toSize:CGSizeMake(320, 320) circular:NO];
                                                             [processedImage drawInRect:CGRectMake(0, 0,320, 320)];
                                                             [overlay drawInRect:CGRectMake(0, 0,320, 320)];
                                                             
                                                             UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
                                                             
                                                             [self setStillImage:combinedImage];
                                                             
                                                             UIGraphicsEndImageContext();
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:combinedImage];
                                                         }];
    [[self captureSession] stopRunning];
}

- (void)dealloc {
    
	[[self captureSession] stopRunning];
//    
//	[previewLayer release], previewLayer = nil;
//	[captureSession release], captureSession = nil;
//    [stillImageOutput release], stillImageOutput = nil;
//    [stillImage release], stillImage = nil;
//    
//	[super dealloc];
}


@end
