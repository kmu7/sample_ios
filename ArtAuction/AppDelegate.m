//
//  AppDelegate.m
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

@synthesize indicator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    MainViewController *controller = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBarHidden=YES;
    self.window.rootViewController = navController;

    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)showIndicator:(Boolean)_show
{
    if(_show){
        if(!self.indicator){
            self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.indicator.color = [UIColor whiteColor];
            self.indicator.center = self.window.center;
            [self.window addSubview:self.indicator];
        }
        [indicator setNeedsDisplay];
        [self.indicator startAnimating];
        
    }else{
        if(self.indicator){
            [self.indicator stopAnimating];
            [self.indicator removeFromSuperview];
            self.indicator = nil;
        }
    }
}


-(void)showNotice:(NSString*)alertMsg
{
    if(notice){
        [notice removeFromSuperview];
        notice = nil;
    }
    
    notice = [[UILabel alloc]initWithFrame:CGRectMake(100,200,320,40)];
        notice.text = alertMsg;
    
    notice.textColor = [UIColor whiteColor];
    notice.textAlignment = NSTextAlignmentCenter;
    notice.backgroundColor = [UIColor clearColor];
    
    [self.window addSubview:notice];
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

@end
