//
//  JBWebImageManager.m
//  异步加载图片2
//
//  Created by 王军波 on 16/9/20.
//  Copyright © 2016年 王军波. All rights reserved.
//

#import "JBWebImageManager.h"

@interface JBWebImageManager()

@property (nonatomic, strong) NSMutableDictionary *imageCache;

@property (nonatomic, strong) NSMutableDictionary *opCache;
// 下载队列
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation JBWebImageManager

// 单例管理器
+ (instancetype)sharedWebImageManager {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

// 构造函数
- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageCache = [NSMutableDictionary dictionary];
        _opCache = [NSMutableDictionary dictionary];
        _downloadQueue = [[NSOperationQueue alloc]init];
    }
    return self;
}

// 接口方法
-  (void)downloadImageWithURLString:(NSString *)URLString completion:(void(^)(UIImage *))compltion {
    
    // 模拟异步
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 模拟延时
        [NSThread sleepForTimeInterval:1.0];
        
        UIImage *image = [UIImage imageNamed:@"user_default"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            compltion(image);
        });
    });
}
@end


