/*
 File: AVCamViewController.m
 Abstract: A view controller that coordinates the transfer of information between the user interface and the capture manager.
 Version: 2.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoCreateViewController.h"

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface AVCamViewController () <UIGestureRecognizerDelegate>
@end

@interface AVCamViewController (InternalMethods)
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
@end

@interface AVCamViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@implementation AVCamViewController

@synthesize captureManager;
@synthesize stillButton;
@synthesize focusModeLabel;
@synthesize videoPreviewView;
@synthesize captureVideoPreviewLayer;
@synthesize cancelBtn,flashBtn,stillImageView;

static NSString *FLASH_AUTO = @"自動";
static NSString *FLASH_ON = @"オン";
static NSString *FLASH_OFF = @"オフ";
static int SAVE_ALERT_DIALOG = 1;


- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	
	return focusString;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode"];
	//[captureManager release];
    //[videoPreviewView release];
	//[captureVideoPreviewLayer release];
    //[cameraToggleButton release];
    //  [recordButton release];
    //  [stillButton release];
    //	[focusModeLabel release];
	
    // [super dealloc];
}

- (void)viewDidLoad
{
    [[self stillButton] setTitle:NSLocalizedString(@"Photo", @"Capture still image button title")];
    
	if ([self captureManager] == nil) {
        manager = [[AVCamCaptureManager alloc] init];
        [manager setDeviceOrientation];
		[self setCaptureManager:manager];
		
		[[self captureManager] setDelegate:self];
        
		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
            newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			CALayer *viewLayer = self.videoPreviewView.layer;
			[viewLayer setMasksToBounds:YES];
			[self getPreviewBounds];
            newCaptureVideoPreviewLayer.frame = CGRectMake(0, 0, previewBounds.size.width, previewBounds.size.height);
            [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        	[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
        
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
			
            [self updateButtonStates];
		
            
			[self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateLayer) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
		}
	}
    
    [super viewDidLoad];
    [self rotateLayer];
    newCaptureVideoPreviewLayer.frame = CGRectMake(0, 0, previewBounds.size.width, previewBounds.size.height);
    flashModeArray = [[manager getFlashMode] copy];
    if(flashModeArray.count>0){
        NSNumber *mode = [flashModeArray objectAtIndex:0];
        switch (mode.intValue) {
            case AVCaptureFlashModeAuto:
                [self.flashBtn setTitle:FLASH_AUTO forState:UIControlStateNormal];
                curentFlashMode = AVCaptureFlashModeAuto;
                break;
            case AVCaptureFlashModeOn:
                [self.flashBtn setTitle:FLASH_ON forState:UIControlStateNormal];
                curentFlashMode = AVCaptureFlashModeOn;
                break;
            case AVCaptureFlashModeOff:
                [self.flashBtn setTitle:FLASH_OFF forState:UIControlStateNormal];
                curentFlashMode = AVCaptureFlashModeOff;
                break;
            default:
                break;
        }
    }else{
        [self.flashBtn setEnabled:NO];
        [self.flashBtn setTitle:FLASH_OFF forState:UIControlStateNormal];
        curentFlashMode = AVCaptureFlashModeOff;
        
    }
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



- (IBAction)captureStillImage:(id)sender
{
    // Capture a still image
    [[self stillButton] setEnabled:NO];
    [[self captureManager] getStillImage:stillImageView];
    
    
    self.stillImageView.frame = CGRectMake(0, 0, previewBounds.size.width, previewBounds.size.height);
    
    // Flash the screen white and fade it out to give UI feedback that a still image was taken
    UIView *flashView = [[UIView alloc] initWithFrame:self.view.frame];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
     ];
    
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@""
                                                       message:@"Use photo for simulating? (Save photo to album also.)"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:@"Cancel" , nil];
    theAlert.tag = SAVE_ALERT_DIALOG;
    [theAlert show];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(CGRect)getPreviewBounds{
    previewBounds =CGRectMake(0, 0, 1, 1);
    
    int xInt=0;
    int yInt=0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        //its iphone
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // iPhone Classic
            xInt = 320;
            yInt = 480;
            
        }
        else if(result.height == 568)
        {
            // iPhone 5
            xInt = 320;
            yInt = 568;
        }
    }
    else
    {
        //its ipad
        xInt = 768;
        yInt = 1024;
    }
    
    previewBounds=CGRectMake(0, 0, yInt, xInt);
    return previewBounds;
}

-(void)rotateLayer
{
    UIDeviceOrientation orientation =[[UIDevice currentDevice]orientation];
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            newCaptureVideoPreviewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI+ M_PI_2); // 270 degress
            newCaptureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
            break;
        case UIDeviceOrientationLandscapeRight:
            newCaptureVideoPreviewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2); // 90 degrees
            newCaptureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
            break;
         default:
            break;
    }
    
}

- (IBAction)tapCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapFlash:(id)sender
{
    
    //BOOL isOK = [manager changeFlashMode:AVCaptureFlashModeOff];
    int _pos = [flashModeArray indexOfObject:[NSNumber numberWithInt:curentFlashMode]];
    _pos++;
    NSNumber *mode = [flashModeArray objectAtIndex:(_pos%flashModeArray.count)];
    switch (mode.intValue) {
        case AVCaptureFlashModeAuto:
            [self.flashBtn setTitle:FLASH_AUTO forState:UIControlStateNormal];
            curentFlashMode = AVCaptureFlashModeAuto;
            [manager changeFlashMode:AVCaptureFlashModeAuto];
            break;
        case AVCaptureFlashModeOn:
            [self.flashBtn setTitle:FLASH_ON forState:UIControlStateNormal];
            curentFlashMode = AVCaptureFlashModeOn;
            [manager changeFlashMode:AVCaptureFlashModeOn];
            break;
        case AVCaptureFlashModeOff:
            [self.flashBtn setTitle:FLASH_OFF forState:UIControlStateNormal];
            curentFlashMode = AVCaptureFlashModeOff;
            [manager changeFlashMode:AVCaptureFlashModeOff];
            break;
        default:
            break;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==SAVE_ALERT_DIALOG){
        switch ((buttonIndex)) {
            case 0:
                //SAVE TO CAMERA ROLL
                [self showIndicator:YES];
                [self saveToCameraRoll:self.stillImageView.image album:ALBUM_NAME];
                
                break;
            case 1:
                //CANCEL
                [self.stillImageView setHidden:YES];
                break;
            default:
                break;
        }
    }
}

-(void)saveToCameraRoll:(UIImage*)saveImage album:(NSString*)albumName
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library writeImageToSavedPhotosAlbum:saveImage.CGImage orientation:(ALAssetOrientation)saveImage.imageOrientation
                          completionBlock:^(NSURL* assetURL, NSError* error) {
                              
                              //error handling
                              if (error!=nil) {
                                  // completionBlock(error);
                                  [self showIndicator:NO];
                                   [self.stillImageView setHidden:YES];
                                  return;
                              }
                              
                              //add the asset to the custom photo album
                              [self addAssetURL: assetURL
                                        toAlbum:albumName];
                              
                          }];
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName
{
    __block BOOL albumWasFound = NO;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    
    //search all photo albums in the library
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               
                               //compare the names of the albums
                               if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                   
                                   //target album is found
                                   albumWasFound = YES;
                                   
                                   //get a hold of the photo's asset instance
                                   [library assetForURL: assetURL
                                            resultBlock:^(ALAsset *asset) {
                                                
                                                //add photo to the target album
                                                [group addAsset: asset];
                                                [self showIndicator:NO];
                                                [self showNotice:SAVED_MSG];
                                                 [self.stillImageView setHidden:YES];
                                                 [self gotoPhotoCreate:self.stillImageView.image];
                                            } failureBlock:(nil)];
                                   
                                   //album was found, bail out of the method
                                   return;
                               }
                               
                               if (group==nil && albumWasFound==NO) {
                                   //photo albums are over, target album does not exist, thus create it
                                   
                                   //create new assets album
                                   [library addAssetsGroupAlbumWithName:albumName
                                                            resultBlock:^(ALAssetsGroup *group) {
                                                                
                                                                //get the photo's instance
                                                                [library assetForURL: assetURL
                                                                         resultBlock:^(ALAsset *asset) {
                                                                             
                                                                             //add photo to the newly created album
                                                                             [group addAsset: asset];
                                                                             [self showIndicator:NO];
                                                                             [self showNotice:SAVED_MSG];
                                                                              [self.stillImageView setHidden:YES];
                                                                             [self gotoPhotoCreate:self.stillImageView.image];
                                                                         } failureBlock:(nil)];
                                                                
                                                            } failureBlock:(nil)];
                                   
                                   //should be the last iteration anyway, but just in case
                                   return;
                               }
                               
                           } failureBlock:(nil)];
    
}

-(void)gotoPhotoCreate:(UIImage*)imagedata
{
    PhotoCreateViewController *viewCtrl = [[PhotoCreateViewController alloc]initWithNibName:@"PhotoCreateViewController" bundle:nil];
    viewCtrl.backImage = [imagedata copy];
    self.navigationController.navigationBarHidden = YES;
    
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

-(void)showNotice:(NSString*)alertMsg
{
    if(notice){
        [notice removeFromSuperview];
        notice = nil;
    }
    
    notice = [[UILabel alloc]initWithFrame:CGRectMake(100,200,320,40)];
    notice.center = self.view.center;
    notice.text = alertMsg;
    
    notice.textColor = [UIColor blackColor];
    notice.textAlignment = NSTextAlignmentCenter;
    notice.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:notice];
    [notice setNeedsDisplay];
    
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(dismissNotice:) userInfo:nil repeats:NO];
}

-(void)dismissNotice:(id)sender
{
    if(notice){
        [notice removeFromSuperview];
        notice = nil;
    }
}


-(void)showIndicator:(Boolean)_show
{
    if(_show){
        if(!indicator){
            indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            indicator.color = [UIColor blackColor];
            indicator.center = self.view.center;
            [self.view addSubview:indicator];
        }
        [indicator setNeedsDisplay];
        [indicator startAnimating];
    }else{
        if(indicator){
            [indicator stopAnimating];
            [indicator removeFromSuperview];
            indicator = nil;
        }
    }
}

@end

@implementation AVCamViewController (InternalMethods)

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[self videoPreviewView]];
		CGPoint convertedFocusPoint = [captureVideoPreviewLayer captureDevicePointOfInterestForPoint:tapPoint];
        [captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will focus as needed at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported])
        [captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{
	NSUInteger cameraCount = [[self captureManager] cameraCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            if (cameraCount < 1) {
                [[self stillButton] setEnabled:NO];
                
            } else {
                [[self stillButton] setEnabled:YES];
            }
        } else {
            [[self stillButton] setEnabled:YES];
        }
    });
}


@end

@implementation AVCamViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}


- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self stillButton] setEnabled:YES];
    });
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}



@end
