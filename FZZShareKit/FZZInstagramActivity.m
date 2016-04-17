//
//  FZZInstagramActivity.m
//  FZZShareKit
//
//  Created by Administrator on 2016/03/03.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import "FZZInstagramActivity.h"

@interface FZZInstagramActivity()
<
UIDocumentInteractionControllerDelegate
>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) UIImage *shareImage;

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
            }
            
            [self performActivity];
            break;
        }
    }
    
    
}

- (void)performActivity {
    NSData *imageData = UIImageJPEGRepresentation(self.shareImage, 1.0);
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
    
    if (![imageData writeToFile:writePath atomically:YES]) {
        // 保存エラー
        [self activityDidFinish:NO];
        return;
    }
    
    // インスタグラムへ送る
    NSURL *fileURL = [NSURL fileURLWithPath:writePath];
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentController.delegate = self;
    self.documentController.UTI = @"com.instagram.exclusivegram";
    
    if(![self.documentController presentOpenInMenuFromRect:self.presentFromButton.frame
                                                    inView:self.presentFromButton
                                                  animated:YES]){
        [self activityDidFinish:NO];
    }

}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    [self activityDidFinish:YES];
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller{
    [self activityDidFinish:NO];
}

-(BOOL)imageIsLargeEnough:(UIImage *)image {
    CGSize imageSize = [image size];
    return ((imageSize.height * image.scale) >= 612 && (imageSize.width * image.scale) >= 612);
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
