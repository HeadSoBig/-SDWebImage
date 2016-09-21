//
//  JBWebImageOperation.h
//  异步加载图片2
//
//  Created by 王军波 on 16/9/20.
//  Copyright © 2016年 王军波. All rights reserved.
//

#import <Foundation/Foundation.h>
// 下载单张图片的操作
@interface JBWebImageOperation : NSOperation

// 下载单张图片  下载成功写入沙盒
+ (instancetype)downloadOperationWithURLString:(NSString *)URLString cachePath:(NSString *)cachePath;

@end
