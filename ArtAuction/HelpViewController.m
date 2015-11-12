//
//  HelpViewController.m
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpContentViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
@synthesize cancelBtn,contentScrollView,pageCtrl,contentList,viewControllers;

static NSString *kNameKey = @"nameKey";
static NSString *kImageKey = @"imageKey";

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
    NSUInteger numberPages = self.contentList.count;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.contentScrollView.frame) * numberPages, CGRectGetHeight(self.contentScrollView.frame));
    NSLog(@"HelpScrollView height = %f", CGRectGetHeight(self.contentScrollView.frame));
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.scrollsToTop = NO;
    self.contentScrollView.delegate = self;
    self.contentScrollView.bounces = NO;
    
    self.pageCtrl.numberOfPages = numberPages;
    self.pageCtrl.currentPage = 0;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)tapCancelBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.contentScrollView.frame);
    NSUInteger page = floor((self.contentScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageCtrl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];

    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.contentList.count)
        return;
    
    // replace the placeholder if necessary
    HelpContentViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[HelpContentViewController alloc] initWithPageNumber:page];
        NSLog(@"HelpContentViewController height = %f", CGRectGetHeight(controller.view.frame));
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.contentScrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.contentScrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
        NSDictionary *numberItem = [self.contentList objectAtIndex:page];
        controller.numberImage.image = [UIImage imageNamed:[numberItem valueForKey:kImageKey]];
        controller.numberTitle.text = [numberItem valueForKey:kNameKey];
    }
}

@end
