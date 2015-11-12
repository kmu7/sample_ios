//
//  PhotoCreateViewController.m
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import "PhotoCreateViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"

@interface PhotoCreateViewController ()

@end

@implementation PhotoCreateViewController
@synthesize goBtn,backBtn,backImageView,pictuerImageView,imageContainerView,saveBtn,searchBtn,titleLabel,backImage,picImage,pinchRecognizer,panRecognizer;

CGPoint dragStartPoint;



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
    // Do any additional setup after loading the view from its nib.
    if(backImage!=nil){
        [self.backImageView setImage:self.backImage];
    }
    
    //TEST CODE
    [self setPIcImage:[UIImage imageNamed:@"small_six"] ];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)tapBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)tapSaveBtn:(id)sender
{
    [self showIndicator:YES];
    UIImage *saveImg = [self makeWallpaperImage];
    [self saveToCameraRoll:saveImg album:ALBUM_NAME];
    [self showIndicator:NO];
}
-(IBAction)tapGoBtn:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://google.com"]];
}
-(IBAction)tapSearchBtn:(id)sender{
    
}

-(void)setPIcImage:(UIImage*)picImage
{
    [self.pictuerImageView setImage:picImage];
}

-(IBAction)pinchGesture:(id)sender
{
    
    UIPinchGestureRecognizer *regognizer = (UIPinchGestureRecognizer*)sender;
    if ((regognizer.state == UIGestureRecognizerStateBegan) ||
        (regognizer.state == UIGestureRecognizerStateChanged) ||
        (regognizer.state == UIGestureRecognizerStateEnded)) {
        float scale = (regognizer.scale-1.0)*0.6+1.0;
        CGRect nowRect = self.pictuerImageView.frame;
        nowRect.size.width *= scale;
        nowRect.size.height *= scale;
        CGRect frameRect = self.imageContainerView.frame;
        if(nowRect.origin.x <0 || nowRect.origin.y<0 || nowRect.origin.x+nowRect.size.width > frameRect.size.width || nowRect.origin.y+nowRect.size.height>frameRect.size.height){
            regognizer.scale = 1.0;
            return;
        }
        self.pictuerImageView.frame = nowRect;
        regognizer.scale = 1.0;
    }
    
}



-(IBAction)panGesture:(id)sender
{
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer*)sender;
    UIGestureRecognizerState state = recognizer.state;
    if (state != UIGestureRecognizerStateChanged && state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGRect picRect = self.pictuerImageView.frame;
    picRect.origin.x += translation.x;
    picRect.origin.y += translation.y;
    CGRect containerRect = self.imageContainerView.frame;
    if (picRect.origin.x<0 || picRect.origin.y<=0 || picRect.origin.x >= (containerRect.size.width-picRect.size.width) || picRect.origin.y>=(containerRect.size.height-picRect.size.height)) {
        return;
    }
    self.pictuerImageView.frame =picRect;
    [recognizer setTranslation:CGPointZero inView:self.imageContainerView];
}


-(UIImage*)makeWallpaperImage
{
    float scaleFactor = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.imageContainerView.frame.size.width, self.imageContainerView.frame.size.height),NO,scaleFactor);

    [self.imageContainerView.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  image;
}

-(void)saveToCameraRoll:(UIImage*)saveImage album:(NSString*)albumName
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library writeImageToSavedPhotosAlbum:saveImage.CGImage orientation:(ALAssetOrientation)saveImage.imageOrientation
                          completionBlock:^(NSURL* assetURL, NSError* error) {
                              
                              //error handling
                              if (error!=nil) {
                                  // completionBlock(error);
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
                                                [self showNotice:SAVED_MSG];

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
                                                                             [self showNotice:SAVED_MSG];
                                                                             
                                                                         } failureBlock:(nil)];
                                                                
                                                            } failureBlock:(nil)];
                                   
                                   //should be the last iteration anyway, but just in case
                                   return;
                               }
                               
                           } failureBlock:(nil)];
    
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
            // [self.indicator release];
            indicator = nil;
        }
    }
}

@end
