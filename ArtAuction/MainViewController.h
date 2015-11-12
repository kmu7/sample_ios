//
//  MainViewController.h
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIImagePickerControllerDelegate>
{
    IBOutlet UIButton *cameraBtn;
    IBOutlet UIButton *simulationBtn;
    IBOutlet UIButton *helpBtn;
    IBOutlet UIScrollView *imageScroll;
    
}

@property(nonatomic, strong) IBOutlet UIButton *cameraBtn;
@property(nonatomic, strong) IBOutlet UIButton *simulationBtn;
@property(nonatomic, strong) IBOutlet UIButton *helpBtn;
@property(nonatomic, strong) IBOutlet UIScrollView *imageScroll;

-(IBAction)tapCameraBtn:(id)sender;
-(IBAction)tapSimulationBtn:(id)sender;
-(IBAction)tapHelpBtn:(id)sender;

@end
