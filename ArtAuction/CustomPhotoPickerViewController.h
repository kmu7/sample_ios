//
//  CustomPhotoPickerViewController.h
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CustomPhotoPickerViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    IBOutlet UICollectionView *myCollectionView;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *backBtn;
    IBOutlet UILabel *titleLabel;
    ALAssetsLibrary *assetsLibrary;
    NSString *backTitle;
}

@property(nonatomic, strong) IBOutlet UILabel *titleLabel;
@property(nonatomic, strong) IBOutlet UIButton *cancelBtn;
@property(nonatomic, strong) IBOutlet UIButton *backBtn;
@property(nonatomic, strong) IBOutlet UICollectionView *myCollectionView;
@property(nonatomic, strong) NSArray *assets;
@property(nonatomic, strong) NSString *backTitle;

-(IBAction)tapCancelBtn:(id)sender;
-(IBAction)tapBackBtn:(id)sender;


@end
