//
//  JLController.m
//  lingerMedia
//
//  Created by eall_linger on 16/9/30.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import "JLController.h"

@implementation JLController
+ (BOOL)isMediaWithPath:(NSString *)path{
    for (NSString *type in [JLController getMediaArray]) {
        if ([path hasSuffix:type]) {
            return YES;
        }
    }
    return NO;
}
+ (NSArray *)getMediaArray{
    return @[
             @".mp4",
             @".avi",
             @".rmvb",
             @".3gp",
             @".mov",
             @".flv",
             @".m3u8",
             @".rm",
             @".mp3"
             ];
}


/**
 *  通过音乐地址，读取音乐数据，获得图片
 *
 *  @param url 音乐地址
 *
 *  @return音乐图片
 */
+ (UIImage *)musicImageWithMusicURL:(NSURL *)url {

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    NSArray * formatArray =  [asset availableMetadataFormats];
    
    NSString *format = formatArray.firstObject;
    
    //3.根据格式做文件解析(解析音乐文件的信息)
    NSArray *metaDataArray = [asset metadataForFormat:format];
    
    //4.遍历数组拿到所有信息
    for (AVMutableMetadataItem *item in metaDataArray) {
        
        //歌手
        if ([item.commonKey isEqualToString:@"artist"]) {
            
            NSLog(@"1：%@",item.value);
        }
        //
        if ([item.commonKey isEqualToString:@"albumName"]) {
            NSLog(@"%@",item.value);
        }
        //歌名
        if ([item.commonKey isEqualToString:@"title"]) {
            NSLog(@"%@",item.value);
        }
        //专辑
        if ([item.commonKey isEqualToString:@"artwork"]) {
            
            NSData *data = (NSData *)item.value;
            
            return [UIImage imageWithData:data];
        }
    }
    
    return nil;
}

/**
 *  通过视频的URL，获得视频缩略图
 *
 *  @param url 视频URL
 *
 *  @return首帧缩略图
 */
+ (UIImage *)imageWithMediaURL:(NSURL *)url {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    // 初始化媒体文件
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    // 根据asset构造一张图
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    // 设定缩略图的方向
    // 如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的（自己的理解）
    generator.appliesPreferredTrackTransform = YES;
    // 设置图片的最大size(分辨率)
    generator.maximumSize = CGSizeMake(600, 450);
    // 初始化error
    NSError *error = nil;
    // 根据时间，获得第N帧的图片
    // CMTimeMake(a, b)可以理解为获得第a/b秒的frame
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(3, 1) actualTime:NULL error:&error];
    // 构造图片
    UIImage *image = [UIImage imageWithCGImage: img];
    return image;
}

@end
