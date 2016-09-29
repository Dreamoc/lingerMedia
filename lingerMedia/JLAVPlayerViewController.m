//
//  JLAVPlayerViewController.m
//  lingerMedia
//
//  Created by eall_linger on 16/9/29.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import "JLAVPlayerViewController.h"
#import "JLAVPlayerView.h"
#define  URLStr1 @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"
#define  URLStr2  @"http://play.68mtv.com:8080/play13/60468.mp4"

@interface JLAVPlayerViewController ()

@end

@implementation JLAVPlayerViewController
{
    JLAVPlayerView *view;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    view = [[JLAVPlayerView alloc]initWithFrame:CGRectZero withVC:self offY:64];
    [self.view addSubview:view];
    [view updatePlayerWithURL:URLStr1];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 400, 100, 100)];
    [btn addTarget:self action:@selector(on:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor orangeColor];

    
    // Do any additional setup after loading the view.
}
- (void)on:(UIButton *)btn
{
    
    if (btn.selected == YES) {
        btn.selected = NO;
        [view updatePlayerWithURL:URLStr1];
        
    }else{
        btn.selected = YES;
        [view updatePlayerWithURL:URLStr2];
        
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [view releaseView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
