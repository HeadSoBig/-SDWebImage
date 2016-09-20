//
//  AppInfoModel.h
//  异步加载图片2
//
//  Created by 王军波 on 16/9/14.
//  Copyright © 2016年 王军波. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "Foundation/Foundation.h"

@interface AppInfoModel : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *download;
@property (nonatomic,copy) NSString *icon;

// 内存缓存 保存图像  有弊端 内存警告不好清除
//@property (nonatomic,strong) UIImage *image;

@end
