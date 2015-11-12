//
//  CustomPhotoListViewController.h
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CustomPhotoListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *myListView;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UILabel *titleLabel;
    ALAssetsLibrary *assetsLibrary;
}

@property(nonatomic, strong) IBOutlet UILabel *titleLabel;
@property(nonatomic, strong) IBOutlet UIButton *cancelBtn;
@property(nonatomic, strong) IBOutlet UITableView *myListView;
@property(nonatomic, strong) NSMutableArray *assetDict;
@property(nonatomic, strong) NSMutableArray *groupDict;


-(IBAction)tapCancelBtn:(id)sender;

@end
