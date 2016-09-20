//
//  JBWebImageManager.h
//  异步加载图片2
//
//  Created by 王军波 on 16/9/20.
//  Copyright © 2016年 王军波. All rights reserved.
//

#import <Foundation/Foundation.h>
// 管理网络图片下载和缓存的单例
@interface JBWebImageManager : NSObject

+ (instancetype)sharedWebImageManager;

@end
