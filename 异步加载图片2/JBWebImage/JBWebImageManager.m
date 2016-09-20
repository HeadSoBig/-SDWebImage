//
//  JBWebImageManager.m
//  异步加载图片2
//
//  Created by 王军波 on 16/9/20.
//  Copyright © 2016年 王军波. All rights reserved.
//

#import "JBWebImageManager.h"

@implementation JBWebImageManager

+ (instancetype)sharedWebImageManager {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end


