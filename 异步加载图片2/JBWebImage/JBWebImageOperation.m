//
//  JBWebImageOperation.m
//  异步加载图片2
//
//  Created by 王军波 on 16/9/20.
//  Copyright © 2016年 王军波. All rights reserved.
//

#import "JBWebImageOperation.h"

@interface JBWebImageOperation()
// 图像下载 URL
@property (nonatomic, copy) NSString *URLString;
// 沙盒路径
@property (nonatomic, copy) NSString *cachePath;

@end

@implementation JBWebImageOperation

+ (instancetype)downloadOperationWithURLString:(NSString *)URLString cachePath:(NSString *)cachePath {
    
    JBWebImageOperation *op = [[self alloc]init];
    
    op.URLString = URLString;
    op.cachePath = cachePath;
    
    return op;
}

@end
