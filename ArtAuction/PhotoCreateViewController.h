//
//  PhotoCreateViewController.h
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCreateViewController : UIViewController
{
    IBOutlet UIView *imageContainerView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIImageView *backImageView;
    IBOutlet UIImageView *pictuerImageView;
    IBOutlet UIButton *backBtn;
    IBOutlet UIButton *saveBtn;
    IBOutlet UIButton *goBtn;
    IBOutlet UIButton *searchBtn;
    UIImage *backImage;
    UIImage *picImage;
    UIPanGestureRecognizer *panRecognizer;
    UIPinchGestureRecognizer *pinchRecognizer;
    UILabel *notice;
    UIActivityIndicatorView *indicator;
    
}

@property(nonatomic, strong)IBOutlet UIView *imageContainerView;
@property(nonatomic, strong)IBOutlet UILabel *titleLabel;
@property(nonatomic, strong)IBOutlet UIImageView *backImageView;
@property(nonatomic, strong)IBOutlet UIImageView *pictuerImageView;
@property(nonatomic, strong)IBOutlet UIButton *backBtn;
@property(nonatomic, strong)IBOutlet UIButton *saveBtn;
@property(nonatomic, strong)IBOutlet UIButton *goBtn;
@property(nonatomic, strong)IBOutlet UIButton *searchBtn;
@property(nonatomic, strong) UIImage *backImage;
@property(nonatomic, strong) UIImage *picImage;
@property(nonatomic, strong)IBOutlet UIPinchGestureRecognizer *pinchRecognizer;
@property(nonatomic, strong)IBOutlet UIPanGestureRecognizer *panRecognizer;


-(IBAction)tapBackBtn:(id)sender;
-(IBAction)tapSaveBtn:(id)sender;
-(IBAction)tapGoBtn:(id)sender;
-(IBAction)tapSearchBtn:(id)sender;
-(IBAction)pinchGesture:(id)sender;
-(IBAction)panGesture:(id)sender;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName;

@end
