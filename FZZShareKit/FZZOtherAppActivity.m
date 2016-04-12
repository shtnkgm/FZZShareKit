//
//  OtherAppActivity.m
//  FZZShareKit
//
//  Created by Administrator on 2016/03/03.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import "FZZOtherAppActivity.h"
#import "NSString+FZZShareKitLocalized.h"

@interface FZZOtherAppActivity ()

@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, copy) NSString *shareString;
@property (nonatomic, strong) NSArray *fileURLs;

@end

@implementation FZZOtherAppActivity

- (NSString *)activityType {
    return @"UIActivityTypePostToOtherApp";
}

- (NSString *)activityTitle {
    return [@"Open Other App" FZZShareKitLocalized];
}

- (UIImage *)activityImage {
    return [self imageNamedWithoutCache:@"Menu.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    NSLog(@"%s",__func__);
    for (UIActivityItemProvider *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"%s",__func__);
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]){
            //アイテムの中から画像を取得
            self.shareImage = item;
        }else if ([item isKindOfClass:[NSString class]]) {
            //アイテムの中からテキストを取得
            self.shareString = item;
        }else{
            //不明なクラスのアイテム
            NSLog(@"Unknown item type %@", item);
            [self activityDidFinish:NO];
        }
    }
    
    NSData *imageData = UIImageJPEGRepresentation(self.shareImage, 1.0);
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"photo.jpeg"];
    
    if (![imageData writeToFile:writePath atomically:YES]) {
        // 保存エラー
        NSLog(@"image save failed to path %@", writePath);
        [self activityDidFinish:NO];
        return;
    }
    
    // インスタグラムへ送る
    NSURL *fileURL = [NSURL fileURLWithPath:writePath];
    self.fileURLs = @[fileURL];

    [super performActivity];
}

- (UIImage *)imageNamedWithoutCache:(NSString *)name{
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *imagePath = [bundlePath stringByAppendingPathComponent:name];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

- (void) documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    // iÍnform delegate
    if([self.delegate respondsToSelector:@selector(openInAppActivityWillPresentDocumentInteractionController:)]) {
        [self.delegate openInAppActivityWillPresentDocumentInteractionController:self];
    }
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller
{
    NSLog(@"%s",__func__);
    
    // Inform delegate
    if([self.delegate respondsToSelector:@selector(openInAppActivityDidDismissDocumentInteractionController:)]) {
        [self.delegate openInAppActivityDidDismissDocumentInteractionController:self];
    }
    
    // Inform app that the activity has finished
    [self activityDidFinish:NO];
}

@end
