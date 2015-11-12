//
//  MainViewController.m
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import "MainViewController.h"
#import "HelpViewController.h"
#import "CustomPhotoListViewController.h"
#import "AVCamViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize helpBtn,cameraBtn,simulationBtn,imageScroll;

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
    CGRect targetRect = self.imageScroll.frame;
    //self.pictureScrollView.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
    self.imageScroll.contentSize = CGSizeMake(self.view.frame.size.width*3, targetRect.size.height);
    
    UIImageView *pictureView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"small_one.png"]];
    pictureView1.contentMode = UIViewContentModeScaleAspectFit;
    pictureView1.backgroundColor = [UIColor blackColor];
    pictureView1.frame = CGRectMake(0, 0, self.view.frame.size.width, targetRect.size.height);
    UIImageView *pictureView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"small_two.png"]];
    pictureView2.contentMode = UIViewContentModeScaleAspectFit;
    pictureView2.backgroundColor = [UIColor blackColor];
    pictureView2.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, targetRect.size.height);
    UIImageView *pictureView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"small_three.png"]];
    pictureView3.contentMode = UIViewContentModeScaleAspectFit;
    pictureView3.backgroundColor = [UIColor blackColor];
    pictureView3.frame = CGRectMake(self.view.frame.size.width*2, 0, self.view.frame.size.width, targetRect.size.height);
    
    [self.imageScroll addSubview:pictureView1];
    [self.imageScroll addSubview:pictureView2];
    [self.imageScroll addSubview:pictureView3];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)tapCameraBtn:(id)sender{
    AVCamViewController *viewCtrl = [[AVCamViewController alloc]initWithNibName:@"AVCamViewController" bundle:nil];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:viewCtrl animated:YES];

}
-(IBAction)tapSimulationBtn:(id)sender
{
    // Given by default your orientation is in landscaperight already
    
    CustomPhotoListViewController *viewCtrl = [[CustomPhotoListViewController alloc]initWithNibName:@"CustomPhotoListViewController" bundle:nil];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:viewCtrl animated:YES];


}
-(IBAction)tapHelpBtn:(id)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"help_content" ofType:@"plist"];
    HelpViewController *viewCtrl = [[HelpViewController alloc]initWithNibName:@"HelpViewController" bundle:nil];
    viewCtrl.contentList = [NSArray arrayWithContentsOfFile:path];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:viewCtrl animated:YES];
    
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}
@end
