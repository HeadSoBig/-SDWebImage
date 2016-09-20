//
//  loadImageCellTableViewCell.h
//  异步加载图片2
//
//  Created by 王军波 on 16/9/14.
//  Copyright © 2016年 王军波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loadImageCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;

@end
