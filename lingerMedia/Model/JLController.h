//
//  JLController.h
//  lingerMedia
//
//  Created by eall_linger on 16/9/30.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface JLController : NSObject
+ (BOOL)isMediaWithPath:(NSString *)path;
+ (UIImage *)musicImageWithMusicURL:(NSURL *)url;
+ (UIImage *)imageWithMediaURL:(NSURL *)url;
@end
