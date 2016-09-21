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
#import "JBWebImageManager.h"

static NSString *cellId = @"cellId";

@interface ViewController ()<UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
// 模型数组
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
    [[JBWebImageManager sharedWebImageManager] downloadImageWithURLString:model.icon completion:^(UIImage *image) {
        
        cell.iconView.image = image;
    }];
    
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
