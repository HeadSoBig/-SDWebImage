//
//  JBWebImageManager.m
//  异步加载图片2
//
//  Created by 王军波 on 16/9/20.
//  Copyright © 2016年 王军波. All rights reserved.
//

#import "JBWebImageManager.h"
#import "CZAdditions.h"
#import "JBWebImageOperation.h"

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
    
    // 判断缓存中图片是否已经存在
    UIImage *cacheImage = _imageCache[URLString];
    if (cacheImage != nil) {
        NSLog(@"缓存");
        compltion(cacheImage);
    }
    // 判断沙盒中图片是否已经存在
    NSString *cachePath = [self cachePathWithURLString:URLString];
    cacheImage = [UIImage imageWithContentsOfFile:cachePath];
    if (cacheImage != nil) {
        NSLog(@"沙盒");
        compltion(cacheImage);
        // 还得设置一下缓存图片
        [_imageCache setObject:cacheImage forKey:URLString];
    }
    
    // 先设置占位图片
    UIImage *placeholder = [UIImage imageNamed:@"user_default"];
    compltion(placeholder);
    
    // 下载图片
    NSURL *url = [NSURL URLWithString:URLString];
    
    // 判断操作是否已经存在
    if (_opCache[URLString] != nil) {
        NSLog(@"正在下载 %@",URLString);
    }
    
    // 创建操作
    JBWebImageOperation *op = [JBWebImageOperation downloadOperationWithURLString:URLString cachePath:cachePath];
    // 添加到操作缓冲池
    [_opCache setObject:op forKey:URLString];
    // 队列添加操作
    [_downloadQueue addOperation:op];

}
#pragma mark - 返回图片保存到沙盒的全路径
- (NSString *)cachePathWithURLString:(NSString *)urlString {
    
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString *fileName = [urlString cz_md5String];
    
    return [cacheDir stringByAppendingPathComponent:fileName];
}
@end


