//
//  CustomPhotoPickerViewController.m
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import "CustomPhotoPickerViewController.h"
#import "MyPhotoCell.h"
#import "PhotoCreateViewController.h"

@interface CustomPhotoPickerViewController ()

@end

@implementation CustomPhotoPickerViewController
@synthesize titleLabel,cancelBtn,backBtn,myCollectionView,assets,backTitle;

static NSString *kCellID = @"cellID";

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
    [self.backBtn setTitle:self.backTitle forState:UIControlStateNormal];
    [self.myCollectionView registerClass:[MyPhotoCell class] forCellWithReuseIdentifier:kCellID];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyPhotoCell *cell = (MyPhotoCell*)(UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    cell.asset = asset;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = self.assets[indexPath.row];
    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
    // Do something with the image
    PhotoCreateViewController *viewCtrl = [[PhotoCreateViewController alloc]initWithNibName:@"PhotoCreateViewController" bundle:nil];
    viewCtrl.backImage = [image copy];
    self.navigationController.navigationBarHidden = YES;
    
    [self.navigationController pushViewController:viewCtrl animated:YES];

    
}

-(IBAction)tapCancelBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)tapBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}


@end
