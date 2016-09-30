//
//  JLAVPlayerView.m
//  NewMedia
//
//  Created by eall_linger on 16/9/27.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import "JLAVPlayerView.h"
#import "UIImage+GIF.h"

@interface JLAVPlayerView()
{
    id _playTimeObserver; // 观察者
    UIImageView *_imageView;//动画
    BOOL _isPlaying;
}
@property (nonatomic,strong)UIViewController *supviewVC;
@property (nonatomic,assign)CGFloat offY;


@property (nonatomic,strong) UIView *playerView;
@property (nonatomic,strong) UIView *LoadingView;

@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *playerBtn;
@property (nonatomic,strong) UISlider *playProgress;
@property (nonatomic,strong) UIProgressView *loadedProgress;
@property (nonatomic,strong) UILabel *beginLabel;
@property (nonatomic,strong) UILabel *endLabel;
@property (nonatomic,strong) UIButton *playerFullScreenButton;

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@end

@implementation JLAVPlayerView

- (void)dealloc{
    [self releaseView];
}

- (void)releaseView {
    [self removeObserveAndNotification];
    [self endAnimation];
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;

}

- (void)removeObserveAndNotification {
    
    [self removeKVC];
    [self removeNotification];
    [self removeMonitoringPlayback];
    
}

- (instancetype)initWithFrame:(CGRect)frame withVC:(UIViewController *)vc offY:(CGFloat)offY{
    self  = [super initWithFrame:frame];
    if (self) {
        self.supviewVC = vc;
        self.offY = offY;
        [self createViews];
    }
    return  self;
}

- (void)createViews{
    
    //添加player主视图
    self.playerView = [[UIView alloc]init];
    self.playerView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    //添加loading动画
    self.LoadingView = [[UIView alloc]init];
    [self addSubview:self.LoadingView];
    [self.LoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UIImage *image = [UIImage sd_animatedGIFNamed:@"dog"];
    _imageView = [[UIImageView alloc]init];
    _imageView.image = image;
    [self.LoadingView addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(image.size.width);
        make.height.mas_equalTo(image.size.height);
        make.centerX.mas_equalTo(self.LoadingView.mas_centerX);
        make.centerY.mas_equalTo(self.LoadingView.mas_centerY);
    }];
    
    //添加上下tools
    [self createTopView];
    [self createBottomView];
    [self show:YES];

    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    tap2.numberOfTapsRequired = 2;
    [self.playerView addGestureRecognizer:tap];
    [self.playerView addGestureRecognizer:tap2];
    [tap requireGestureRecognizerToFail:tap2];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestures:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.playerView addGestureRecognizer:panGestureRecognizer];
    
    //添加菊花
    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:testActivityIndicator];
    testActivityIndicator.tag = 5;
    [testActivityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    //添加通知

}

- (void)starActivity{
    UIActivityIndicatorView *testActivityIndicator = [self viewWithTag:5];
    [testActivityIndicator startAnimating]; // 开始旋转
}
- (void)endActivity{
    UIActivityIndicatorView *testActivityIndicator = [self viewWithTag:5];
    [testActivityIndicator stopAnimating]; // 结束旋转

}

- (void)startAnimation{
    NSLog(@"动画开始");
    self.LoadingView.alpha = 1;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"dog"];
    _imageView.image = image;
    self.LoadingView.backgroundColor = [UIColor colorWithRed:94/255.0 green:71/255.0 blue:115/255.0 alpha:1];

//    [UIView animateWithDuration:1.5 animations:^{
//        CABasicAnimation *fullRotation;
//        fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//        fullRotation.fromValue = [NSNumber numberWithFloat:0];
//        fullRotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
//        fullRotation.duration =1.0f;
//        fullRotation.repeatCount = MAXFLOAT;
//        [_imageView.layer addAnimation:fullRotation forKey:@"3601"];
//    }];
}
- (void)faildAnimation{
    self.LoadingView.alpha = 1;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"failed"];
    _imageView.image = image;
    self.LoadingView.backgroundColor = [UIColor blackColor];


}

- (void)endAnimation{
    self.LoadingView.alpha = 0;
    _imageView.image = nil;

//    [_imageView.layer removeAnimationForKey:@"3601"];
    NSLog(@"动画停止");
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame =  self.playerView.bounds;
}

- (void)tap:(UITapGestureRecognizer*)tgr{
    if (tgr.numberOfTapsRequired == 1) {
        if (self.bottomView.alpha) {
            [self hidden];
        }else{
            [self show:YES];
        }
    }else if (tgr.numberOfTapsRequired == 2){
        if (_isPlaying) {
            [self pause];
        }else{
            [self play];
        }
    }
}

- (void) handlePanGestures:(UIPanGestureRecognizer*)paramSender{
    
    if (paramSender.state != UIGestureRecognizerStateFailed) {
        if (paramSender.state == UIGestureRecognizerStateBegan) {
            [self pause];
            [self show:NO];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidden) object:nil];
        }else if(paramSender.state == UIGestureRecognizerStateEnded){
            [self play];
            [self show:YES];
        }else{
            CGPoint translation = [paramSender velocityInView:self.playerView];
            CGFloat beishu = 100;
            if([self isOrientationLandscape]){
                beishu = 200;
            }else{
                beishu = 100;
            }
            self.playProgress.value+= translation.x/beishu;
            [self playerSliderValueChanged:nil];
        }
    }
   
}

- (void)createTopView{
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.playerView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.playerView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.text = @"这是标题";
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(self.topView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(self.topView.mas_height);
    }];
}

- (void)createBottomView{
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.playerView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.playerView);
        make.bottom.mas_equalTo(self.playerView.mas_bottom);
        make.height.mas_equalTo(40);
    }];
    self.playerBtn = [[UIButton alloc]init];
    [self.playerBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    [self.playerBtn setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateSelected];
    [self.playerBtn addTarget:self action:@selector(playerBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.playerBtn];
    [self.playerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.height.mas_equalTo(40);
        make.centerY.mas_equalTo(self.bottomView.frame.size.width/2);
    }];
    
    self.beginLabel = [[UILabel alloc]init];
    self.beginLabel.textColor = [UIColor whiteColor];
    self.beginLabel.textAlignment = NSTextAlignmentRight;
    self.beginLabel.font = [UIFont systemFontOfSize:12];
    self.beginLabel.text = @"00:00:00";
    [self.bottomView addSubview:self.beginLabel];
    [self.beginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playerBtn.mas_right);
        make.top.bottom.mas_equalTo(self.bottomView);
        make.width.mas_equalTo(60);
    }];
    
    self.playerFullScreenButton = [[UIButton alloc]init];
    [self.playerFullScreenButton setImage:[UIImage imageNamed:@"player_fullScreen_iphone"] forState:UIControlStateNormal];
    [self.playerFullScreenButton setImage:[UIImage imageNamed:@"player_window_iphone"] forState:UIControlStateSelected];
    [self.playerFullScreenButton addTarget:self action:@selector(rotationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.playerFullScreenButton];
    [self.playerFullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomView.mas_right).offset(-10);
        make.width.height.mas_equalTo(40);
        make.centerY.mas_equalTo(self.bottomView.frame.size.width/2);

    }];
    
    self.endLabel = [[UILabel alloc]init];
    self.endLabel.textColor = [UIColor whiteColor];
    self.endLabel.textAlignment = NSTextAlignmentLeft;
    self.endLabel.font = [UIFont systemFontOfSize:12];
    self.endLabel.text = @"00:00:00";
    [self.bottomView addSubview:self.endLabel];
    [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.playerFullScreenButton.mas_left);
        make.top.bottom.mas_equalTo(self.bottomView);
        make.width.mas_equalTo(60);
    }];
    
    self.loadedProgress = [[UIProgressView alloc]init];
    self.loadedProgress.progress = 0;
    self.loadedProgress.tintColor = [UIColor greenColor];
    [self.bottomView addSubview:self.loadedProgress];
    [self.loadedProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.beginLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.endLabel.mas_left).offset(-10);
        make.height.mas_equalTo(2.0);
        make.centerY.mas_equalTo(self.bottomView);
    }];
    
    self.playProgress = [[UISlider alloc]init];
    self.playProgress.value = 0.0;
    self.playProgress.minimumTrackTintColor = [UIColor clearColor];
    self.playProgress.maximumTrackTintColor = [UIColor clearColor];
    [self.playProgress addTarget:self action:@selector(playerSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.playProgress addTarget:self action:@selector(playerSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.playProgress addTarget:self action:@selector(playerSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.playProgress setThumbImage:[UIImage imageNamed:@"icmpv_thumb_light"] forState:(UIControlStateNormal)];
    [self.bottomView addSubview:self.playProgress];
    [self.playProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.loadedProgress);
        make.top.bottom.mas_equalTo(self.bottomView);
    }];
    
    
    
}
#pragma mark 显示隐藏toolbar
- (void)show:(BOOL)hidden{
    [UIView animateWithDuration:0.5 animations:^{
        self.topView.alpha    = 1;
        self.bottomView.alpha = 1;
    } completion:^(BOOL finished) {
        if (hidden) {
            [self performSelector:@selector(hidden) withObject:nil afterDelay:5];
        }
    }];
}

- (void)hidden{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidden) object:nil];
    [UIView animateWithDuration:0.5 animations:^{
        self.topView.alpha    = 0;
        self.bottomView.alpha = 0;
    }];
}

- (void)playerBtnOnClick:(UIButton *)btn{
    if (btn.selected == YES) {
        [self pause];
    }else{
        [self play];
    }
}

- (void)play{
    [self.player play];
    self.playerBtn.selected = YES;
    _isPlaying = YES;
}

- (void)pause{
    [self.player pause];
    self.playerBtn.selected = NO;
    _isPlaying = NO;
}

#pragma mark slier事件
- (void)playerSliderTouchDown:(id)sender {
    [self pause];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidden) object:nil];
}

- (void)playerSliderTouchUpInside:(id)sender {
    [self play];
    [self show:YES];
}

// 不要拖拽的时候改变， 手指抬起来后缓冲完成再改变
- (void)playerSliderValueChanged:(id)sender {
    CMTime changedTime = CMTimeMakeWithSeconds(self.playProgress.value, 1000000000);
    [self.player.currentItem seekToTime:changedTime completionHandler:^(BOOL finished) {
        // 跳转完成后做某事
    }];
}

#pragma mark 手动旋转屏幕
- (void)rotationAction {
    if ([self isOrientationLandscape]) { // 如果是横屏，
        self.playerFullScreenButton.selected = NO;
        [self forceOrientation:(UIInterfaceOrientationPortrait)]; // 切换为竖屏
    } else {
        self.playerFullScreenButton.selected = YES;
        [self forceOrientation:(UIInterfaceOrientationLandscapeRight)]; // 否则，切换为横屏
    }
}

#pragma mark 监听屏幕旋转
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // 横竖屏判断
    if (self.traitCollection.verticalSizeClass != UIUserInterfaceSizeClassCompact) { // 竖屏
        self.supviewVC.navigationController.navigationBar.hidden = NO;
        self.supviewVC.navigationController.interactivePopGestureRecognizer.enabled = YES;

        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.offY);
            make.left.and.right.mas_equalTo(self.supviewVC.view);
            make.height.mas_equalTo(212);
        }];
        self.playerFullScreenButton.selected = NO;
    } else { // 横屏
        self.supviewVC.navigationController.navigationBar.hidden = YES;
        self.supviewVC.navigationController.interactivePopGestureRecognizer.enabled = NO;
 
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.and.right.mas_equalTo(self.supviewVC.view);
            make.height.mas_equalTo(self.supviewVC.view.mas_height);
        }];
        self.playerFullScreenButton.selected = YES;
    }

}

#pragma mark 播放URL
- (void)updatePlayerWithURL:(NSURL *)url  withTite:(NSString *)title{
    
    self.titleLabel.text = title;
    
    [self removeObserveAndNotification];
    
    [self startAnimation];
    _isPlaying = NO;
 
    self.player = nil;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    

    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.playerView.layer insertSublayer:self.playerLayer atIndex:0];
    [self layoutSubviews];

    [self addKVC];
    [self addNotification];
    [self monitoringPlayback];

}
- (void)addKVC{
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil]; // 观察status属性， 一共有三种属性
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil]; // 观察缓冲进度
    [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeKVC{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)addNotification{
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark  观察播放进度
- (void)monitoringPlayback{
    __weak typeof(self)WeakSelf = self;
    _playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float currentPlayTime = (double)WeakSelf.player.currentItem.currentTime.value/ WeakSelf.player.currentItem.currentTime.timescale;
        [WeakSelf updateVideoSlider:currentPlayTime];
    }];
}
- (void)removeMonitoringPlayback{
    [self.player removeTimeObserver:_playTimeObserver];
}

#pragma mark 播放结束
- (void)playbackFinished:(NSNotification *)notification{
    CMTime changedTime = CMTimeMakeWithSeconds(0, 1000000000);
    [self.player.currentItem seekToTime:changedTime completionHandler:^(BOOL finished) {
        [self pause];
    }];
}
#pragma mark 切换前后台
- (void)enterForegroundNotification:(NSNotification *)notification{
    [self pause];
}

- (void)enterBackgroundNotification:(NSNotification *)notification{
    NSLog(@"enterBackgroundNotification");
}

#pragma mark  更新滑动条
- (void)updateVideoSlider:(float)currentTime {
    self.playProgress.value = currentTime;
    self.beginLabel.text = [self convertTime:currentTime];
    [self endActivity];
}

#pragma mark 监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        if (status == AVPlayerStatusReadyToPlay) {
            NSLog(@"准备播放");
            [self endAnimation];
            CMTime duration = item.duration;

            [self setMaxDuration:CMTimeGetSeconds(duration)];
            [self play];
            
        } else if (status == AVPlayerStatusFailed || status == AVPlayerStatusUnknown) {
            [self faildAnimation];
            [self pause];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDurationRanges]; // 缓冲时间
        CGFloat totalDuration = CMTimeGetSeconds(self.player.currentItem.duration); // 总时间
        [self.loadedProgress setProgress:timeInterval / totalDuration animated:NO];
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSLog(@"缓冲不足暂停了");
        [self starActivity];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
         NSLog(@"缓冲达到可播放程度了");
    }
}

#pragma mark  设置最大时间
- (void)setMaxDuration:(CGFloat)duration {
    self.playProgress.maximumValue = duration;
    self.endLabel.text = [self convertTime:duration];
}

#pragma mark 获取缓存区域
- (NSTimeInterval)availableDurationRanges {
    NSArray *loadedTimeRanges = [self.player.currentItem loadedTimeRanges]; // 获取item的缓冲数组
    // CMTimeRange 结构体 start duration 表示起始位置 和 持续时间
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算总缓冲时间 = start + duration
    return result;
}


#pragma mark 转换时间格式
- (NSString *)convertTime:(CGFloat)second {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showTimeNew = [formatter stringFromDate:date];
    return showTimeNew;
}

#pragma mark 强制转换 私有
- (void)forceOrientation:(UIInterfaceOrientation)orientation {

    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark 判断方向
- (BOOL)isOrientationLandscape {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

@end
