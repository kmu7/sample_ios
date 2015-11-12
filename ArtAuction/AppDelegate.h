//
//  AppDelegate.h
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIActivityIndicatorView *indicator;
     UILabel *notice;
}

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain)UIActivityIndicatorView *indicator;

-(void)showIndicator:(Boolean)_show;
-(void)showNotice:(NSString*)alertMsg;

@end
