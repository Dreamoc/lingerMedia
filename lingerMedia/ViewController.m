//
//  ViewController.m
//  lingerMedia
//
//  Created by eall_linger on 16/9/29.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import "ViewController.h"
#import "JLAVPlayerViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 100, 100)];
    [btn addTarget:self action:@selector(on:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor orangeColor];

    // Do any additional setup after loading the view, typically from a nib.
}
- (void)on:(UIButton *)btn
{
    
    JLAVPlayerViewController *vc = [[JLAVPlayerViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
