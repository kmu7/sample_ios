//
//  PhotoGroup.h
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoGroup : NSObject
{
    NSString *name;
    UIImage *image;
}

@property(nonatomic,strong)NSString *name;
@property(nonatomic, strong)UIImage *image;

@end
