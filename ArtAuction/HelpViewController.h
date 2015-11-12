//
//  HelpViewController.h
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController  <UIScrollViewDelegate>
{
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIScrollView *contentScrollView;
    IBOutlet UIPageControl *pageCtrl;
    

}

@property(nonatomic, strong) IBOutlet UIButton *cancelBtn;
@property(nonatomic, strong) IBOutlet UIScrollView *contentScrollView;
@property(nonatomic, strong) IBOutlet UIPageControl *pageCtrl;
@property (nonatomic, strong) NSArray *contentList;
@property (nonatomic, strong) NSMutableArray *viewControllers;

-(IBAction)tapCancelBtn:(id)sender;

@end
