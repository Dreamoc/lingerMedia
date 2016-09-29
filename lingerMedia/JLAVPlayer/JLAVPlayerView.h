//
//  JLAVPlayerView.h
//  NewMedia
//
//  Created by eall_linger on 16/9/27.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"

@interface JLAVPlayerView : UIView
- (instancetype)initWithFrame:(CGRect)frame withVC:(UIViewController *)vc offY:(CGFloat)offY;

- (void)releaseView;
- (void)updatePlayerWithURL:(NSString *)urlStr;
@end
