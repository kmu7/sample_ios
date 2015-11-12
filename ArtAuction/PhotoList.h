//
//  PhotoList.h
//  ArtAuction
//
//  Created by KEN_XXX on 2013/11/11.
//  Copyright (c) 2013年 KEN_XXX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoList : UITableViewCell
{
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *numberLabel;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;


@end
