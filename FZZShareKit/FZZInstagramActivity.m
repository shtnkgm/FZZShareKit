//
//  FZZInstagramActivity.m
//  FZZShareKit
//
//  Created by Administrator on 2016/03/03.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import "FZZInstagramActivity.h"
#import "TOCropViewController.h"

@interface FZZInstagramActivity()
<
TOCropViewControllerDelegate,
UIDocumentInteractionControllerDelegate
>

@property (nonatomic, strong) UIButton *presentFromButton;
@property (nonatomic, strong) TOCropViewController *cropViewController;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, copy) NSString *shareString;

@end

@implementation FZZInstagramActivity


- (NSString *)activityType {
    return @"UIActivityTypePostToInstagram";
}

- (NSString *)activityTitle {
    return @"Instagram";
}

- (UIImage *)activityImage {
    return [self imageNamedWithoutCache:@"Instagram.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) return NO; // no instagram.
    
    for (UIActivityItemProvider *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]){
            //アイテムの中から画像を取得
            self.shareImage = item;
            
            if(MIN((int)_shareImage.size.width,(int)_shareImage.size.height) < 612){
                //画像が612*612pxより小さい場合は拡大
                float ratio = 612.0f/MIN((int)_shareImage.size.width,(int)_shareImage.size.height);
                self.shareImage = [self resizeImage:_shareImage withRatio:ratio];
                NSLog(@"%f %f",_shareImage.size.width,_shareImage.size.height);
            }
        }else if ([item isKindOfClass:[NSString class]]) {
            //アイテムの中からテキストを取得
            self.shareString = item;
        }else{
            //不明なクラスのアイテム
            NSLog(@"Unknown item type %@", item);
        }
    }
}

- (UIViewController *)activityViewController {
    self.cropViewController = [[TOCropViewController alloc] initWithImage:self.shareImage];
    self.cropViewController.delegate = self;
    self.cropViewController.defaultAspectRatio = TOCropViewControllerAspectRatioSquare;
    self.cropViewController.aspectRatioLocked = YES;

    return self.cropViewController;
}

- (void)cropViewController:(TOCropViewController *)cropViewController
            didCropToImage:(UIImage *)image
                  withRect:(CGRect)cropRect
                     angle:(NSInteger)angle{
    if(!image){
        if (self.documentController) {
            [self.documentController dismissMenuAnimated:YES];
        }
        [self activityDidFinish:NO];
        return;
    }else{
        self.presentFromButton = cropViewController.toolbar.doneIconButton;
        self.shareImage = image;
        [self performActivity];
    }
}

- (void)performActivity {
    NSData *imageData = UIImageJPEGRepresentation(self.shareImage, 1.0);
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
    
    if (![imageData writeToFile:writePath atomically:YES]) {
        // 保存エラー
        NSLog(@"image save failed to path %@", writePath);
        [self activityDidFinish:NO];
        return;
    }
    
    // インスタグラムへ送る
    NSURL *fileURL = [NSURL fileURLWithPath:writePath];
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentController.delegate = self;
    self.documentController.UTI = @"com.instagram.exclusivegram";
    
    if (self.shareString){
        self.documentController.annotation = @{@"InstagramCaption" : self.shareString};
    }
    
    if(![self.documentController presentOpenInMenuFromRect:self.presentFromButton.frame
                                                    inView:self.presentFromButton
                                                  animated:YES]){
        NSLog(@"couldn't present document interaction controller");
        [self activityDidFinish:NO];
    }

}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    [self activityDidFinish:YES];
}

-(BOOL)imageIsLargeEnough:(UIImage *)image {
    CGSize imageSize = [image size];
    return ((imageSize.height * image.scale) >= 612 && (imageSize.width * image.scale) >= 612);
}

-(BOOL)imageIsSquare:(UIImage *)image {
    CGSize imageSize = image.size;
    return (imageSize.height == imageSize.width);
}

- (UIImage *)imageNamedWithoutCache:(NSString *)name{
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *imagePath = [bundlePath stringByAppendingPathComponent:name];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

- (UIImage*)resizeImage:(UIImage*)image withRatio:(float)ratio{
    CGRect rect = CGRectMake(0, 0,image.size.width*ratio,image.size.height*ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
