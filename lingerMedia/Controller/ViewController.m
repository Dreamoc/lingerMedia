//
//  ViewController.m
//  lingerMedia
//
//  Created by eall_linger on 16/9/29.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import "ViewController.h"
#import "JLAVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "JLController.h"
#import "JLMediaTableViewCell.h"
#import "JLDirectoryTableViewCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *myTableview;
@end

@implementation ViewController
{
    NSArray *_data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createBar];
    [self createView];

}
- (void)createBar
{
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    self.navigationController.navigationBar.tintColor = MainColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:MainColor,NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getAllfilesIn];
}
- (void)createView{
    
    
    
    self.myTableview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.myTableview.estimatedRowHeight = 20;//预估行高可以提高性能
    self.myTableview.delegate = self;
    self.myTableview.dataSource = self;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.myTableview.tableHeaderView = view;
    [self.view addSubview:self.myTableview];
    [self.myTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];

}

- (void)getAllfilesIn{
    
    NSString *string = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (self.directoryPath) {
        string = self.directoryPath;
    }

    NSArray *Tarry = [NSArray arrayWithObjects:[self getDataArrayWithIsDirectory:YES path:string],[self getDataArrayWithIsDirectory:NO path:string], nil];
    _data = Tarry;
    [self.myTableview reloadData];
    
}

- (NSArray *)getDataArrayWithIsDirectory:(BOOL)isDirectory path:(NSString *)pathStr{
 
    
    NSArray *array =  [self getFileArrayWithisDirectory:isDirectory path:pathStr];
    NSMutableArray *fileDataArray = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0; i <array.count; i++) {
        NSString *fileName = array[i];
        NSString *path = [pathStr stringByAppendingPathComponent:fileName];
        NSDictionary * dict = nil;
        if (isDirectory) {
            NSArray * subDirArray = [self getFileArrayWithisDirectory:YES path:path];
            NSArray * subfileArray = [self getFileArrayWithisDirectory:NO path:path];
            NSString *subTitle = [NSString stringWithFormat:@"文件夹：%ld，视频：%ld",subDirArray.count,subfileArray.count];
            dict = @{@"fileName":fileName,@"path":path,@"subTitle":subTitle};
        }else{
            dict = @{@"fileName":fileName,@"path":path};
        }
        [fileDataArray addObject:dict];
    }
    return [fileDataArray copy];
    
}

- (NSArray *)getFileArrayWithisDirectory:(BOOL)isDirectory path:(NSString *)pathStr{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:pathStr error:nil]];
    NSMutableArray *directoryArray = [[NSMutableArray alloc] init];
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    BOOL isDir = NO;
    for (NSInteger i = 0 ;i < tempFileList.count ; i++) {
        NSString *file = tempFileList[i];
        NSString *path = [pathStr stringByAppendingPathComponent:file];
        [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
        
        if (isDir) {
            [directoryArray addObject:file];
        }else{
            [fileArray addObject:file];
        }
        
        isDir = NO;
    }
    
    if (isDirectory) {
        return [directoryArray copy];
    }else{
        return [fileArray copy];
    }
}

- (void)removeWithPath:(NSString *)path{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for (NSString *fileName in enumerator) {
        [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
    }
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _data.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_data[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = _data[indexPath.section][indexPath.row];

    if (indexPath.section == 0) {

        JLDirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DirectoryTableViewCell"];
        if (!cell) {
            cell = [[JLDirectoryTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DirectoryTableViewCell"];
            cell.iconImageView.image = [UIImage imageNamed:@"directory"];
        }
        cell.nameLabel.text   = dict[@"fileName"];
        cell.numberLabel.text = dict[@"subTitle"];
        return cell;
    }else {
        JLMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaTableViewCell"];
        if (!cell) {
            cell = [[JLMediaTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MediaTableViewCell"];
        }
        cell.nameLabel.text = dict[@"fileName"];
        if ([dict[@"path"] hasSuffix:@".mp3"]) {
            cell.iconImageView.image = [JLController musicImageWithMusicURL:[NSURL fileURLWithPath:dict[@"path"]]];
        }else{
            cell.iconImageView.image = [JLController imageWithMediaURL:[NSURL fileURLWithPath:dict[@"path"]]];
        }
        return cell;

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 从数据源中删除
    NSDictionary *dict  = _data[indexPath.section][indexPath.row];
    [self removeWithPath:dict[@"path"]];
    
    [self getAllfilesIn];

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JLMediaTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    NSDictionary *dict = _data[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        ViewController *vc = [[ViewController alloc]init];
        vc.directoryPath = dict[@"path"];
        vc.title = dict[@"fileName"];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NSString *path = dict[@"path"];
        JLAVPlayerViewController *vc = [[JLAVPlayerViewController alloc]init];
        vc.vedioUrl = [NSURL fileURLWithPath:path];
        vc.title = dict[@"fileName"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
