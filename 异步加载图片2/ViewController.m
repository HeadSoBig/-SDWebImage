//
//  ViewController.m
//  异步加载图片2
//
//  Created by 王军波 on 16/9/14.
//  Copyright © 2016年 王军波. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AppInfoModel.h"
//#import "UIImageView+WebCache.h"  不使用SDW
#import "loadImageCellTableViewCell.h"
#import "CZAdditions.h"

static NSString *cellId = @"cellId";

@interface ViewController ()<UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray <AppInfoModel *> *appList;
// 操作队列
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
// 图片缓冲池
@property (nonatomic, strong) NSMutableDictionary *imageCache;
// 操作缓冲池
@property (nonatomic,strong) NSMutableDictionary *opCache;

@end

@implementation ViewController

#pragma mark - 加载视图
- (void)loadView {
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    self.view = _tableView;
    
    _tableView.rowHeight = 100;
    
    _tableView.dataSource = self;
    
    [_tableView registerNib:[UINib nibWithNibName:@"loadImageCellTableViewCell" bundle:nil] forCellReuseIdentifier:cellId];
}

#pragma mark - 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 实例化队列
    _downloadQueue = [NSOperationQueue new];
    
    _imageCache = [NSMutableDictionary dictionary];
    _opCache = [NSMutableDictionary dictionary];
    
    [self loadData];
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // 清楚缓冲池
    [_imageCache removeAllObjects];
    // 操作队列 取消所有没有完成的操作任务
    [_downloadQueue cancelAllOperations];
    // 操作缓冲池清空
    [_opCache removeAllObjects];
}

#pragma mark - 加载数据
- (void)loadData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"https://raw.githubusercontent.com/HeadSoBig/KJTT/master/apps.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *responseObject) {
        
        NSLog(@"%@,%@",responseObject,[responseObject class]);
        
        NSMutableArray *arrayM = [[NSMutableArray alloc]init];
        for (NSDictionary *dict in responseObject) {
            
            AppInfoModel *model = [AppInfoModel new];
            
            [model setValuesForKeysWithDictionary:dict];
            
            [arrayM addObject:model];
        }
        self.appList = arrayM;
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
    }];
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _appList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    loadImageCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    AppInfoModel *model = _appList[indexPath.row];
    
    cell.nameLabel.text = model.name;
    cell.downloadLabel.text = model.download;
    // 判断缓存中图片是否已经存在
    UIImage *cacheImage = _imageCache[model.icon];
    if (cacheImage != nil) {
        NSLog(@"缓存");
        cell.iconView.image = cacheImage;
        return cell;
    }
    // 判断沙盒中图片是否已经存在
    cacheImage = [UIImage imageWithContentsOfFile:[self cachePathWithURLString:model.icon]];
    if (cacheImage != nil) {
        NSLog(@"沙盒");
        cell.iconView.image = cacheImage;
        // 还得设置一下缓存图片
        [_imageCache setObject:cacheImage forKey:model.icon];
        return cell;
    }
    
    // 先设置占位图片
    UIImage *placeholder = [UIImage imageNamed:@"user_default"];
    cell.iconView.image = placeholder;
    
    // 下载图片
    NSURL *url = [NSURL URLWithString:model.icon];
    
    // 判断操作是否已经存在
    if (_opCache[model.icon] != nil) {
        NSLog(@"正在下载 %@",model.name);
        return cell;
    }
    
    // 创建操作任务
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"下载%@  下载操作数%zd  操作缓冲池%@",model.name,_downloadQueue.operationCount,_opCache);
        // 模拟延时
        //[NSThread sleepForTimeInterval:1];
        // 第一张特别慢  重复下载问题
        if (indexPath.row == 0) {
            [NSThread sleepForTimeInterval:10];
        }
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        UIImage *image = [UIImage imageWithData:data];
        
        if (image != nil) {
            // 图片缓冲池记录
            [_imageCache setObject:image forKey:model.icon];
            // 将二进制写入沙盒
            [data writeToFile:[self cachePathWithURLString:model.icon] atomically:YES];
        }
        // 清空操作缓冲池
        [_opCache removeObjectForKey:model.icon];
        
        // 主线程更新
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSLog(@"队列中下载操作数 %zd",_downloadQueue.operationCount);
            cell.iconView.image = image;
        }];
    }];
    // 添加到操作缓冲池
    [_opCache setObject:op forKey:model.icon];
    
    [_downloadQueue addOperation:op];
    
    // [cell.iconView sd_setImageWithURL:url]; 不使用SDW
    
    return cell;
}
#pragma mark - 返回图片保存到沙盒的全路径
- (NSString *)cachePathWithURLString:(NSString *)urlString {
    
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString *fileName = [urlString cz_md5String];
    
    return [cacheDir stringByAppendingPathComponent:fileName];
}

@end
