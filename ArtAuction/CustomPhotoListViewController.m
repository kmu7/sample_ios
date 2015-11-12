//
//  CustomPhotoListViewController.m
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import "CustomPhotoListViewController.h"
#import "PhotoList.h"
#import "PhotoGroup.h"
#import "CustomPhotoPickerViewController.h"

@interface CustomPhotoListViewController ()

@end

@implementation CustomPhotoListViewController
@synthesize myListView,cancelBtn,titleLabel,assetDict,groupDict;

static NSString *kCellID = @"PhotoList";

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
    self.assetDict = [[NSMutableArray alloc]init];
    self.groupDict = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
    
    assetsLibrary = [CustomPhotoListViewController defaultAssetsLibrary];
    // 2
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group)
        {
            __block NSMutableArray *tmpAssets = [@[] mutableCopy];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result)
                {
                    // 3
                    [tmpAssets addObject:result];
                }
            }];
            [self.assetDict addObject:tmpAssets];
            PhotoGroup *pGrp = [[PhotoGroup alloc]init];
            pGrp.name =[[group valueForProperty: ALAssetsGroupPropertyName] copy];
            pGrp.image = [UIImage imageWithCGImage:[group posterImage]];
            [self.groupDict addObject:pGrp];
        }
        
        // 4
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
        // self.assets = tmpAssets;
        
        // 5
        [self.myListView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
    
    
    
    
    [self.myListView registerClass:[PhotoList class] forCellReuseIdentifier:kCellID];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomPhotoPickerViewController *viewCtrl = [[CustomPhotoPickerViewController alloc]initWithNibName:@"CustomPhotoPickerViewController" bundle:nil];
    viewCtrl.assets = [[self.assetDict objectAtIndex:indexPath.row] copy];
    [viewCtrl.titleLabel setText:((PhotoGroup*)[self.groupDict objectAtIndex:indexPath.row]).name];
    viewCtrl.backTitle = [@"<" stringByAppendingString:[((PhotoGroup*)[self.groupDict objectAtIndex:indexPath.row]).name copy]];
    self.navigationController.navigationBarHidden = YES;
    
    [self.navigationController pushViewController:viewCtrl animated:YES];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoList *cell = (PhotoList*)[tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
            cell = [[PhotoList alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    }
 
            PhotoGroup *group = [self.groupDict objectAtIndex:indexPath.row];
    [cell.titleLabel setText:group.name];
    [cell.imageView setImage:group.image];
    NSString *num =[NSString stringWithFormat:@"%d", [((NSMutableArray*)[self.assetDict objectAtIndex:indexPath.row]) count]];
    [cell.numberLabel setText:num];
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groupDict count];
}

-(IBAction)tapCancelBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
