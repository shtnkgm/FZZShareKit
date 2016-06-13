//
//  FZZShareKit.m
//  FZZShareKit
//
//  Created by Administrator on 2016/03/02.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import "FZZShareKit.h"
#import "FZZInstagramActivity.h"
#import "SVProgressHUD.h"
#import "NSString+FZZShareKitLocalized.h"

@interface FZZShareKit()

@property (nonatomic, strong) FZZInstagramActivity *instagramActivity;

@end

@implementation FZZShareKit

- (void)shareImage:(UIImage *)image
              text:(NSString *)text
          delegate:(id)delegate
      actionButton:(UIButton *)actionButton
    viewController:(UIViewController *)viewController{
    
    self.delegate = delegate;

    [self HUDShow];
    
    if(!image){
        [self.delegate FZZShareKit:self didSharedWithStatus:FZZShareStatusFail];
        return;
    }
    
    self.instagramActivity = [FZZInstagramActivity new];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[image,text]
                                                        applicationActivities:@[self.instagramActivity]];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePrint];
    
    if(actionButton){
        self.instagramActivity.presentFromButton = actionButton;
        activityViewController.popoverPresentationController.sourceView = actionButton;
        activityViewController.popoverPresentationController.sourceRect = actionButton.bounds;
    }
    
    __weak typeof(self) weakSelf = self;
    
    //activityControllerを表示（メインスレッドで実行）
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:activityViewController animated:YES completion:^{
            [weakSelf HUDDismiss];
        }];
    }];
    
    
    //完了後の処理
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                            BOOL completed,
                                                            NSArray *returnedItems,
                                                            NSError *error){
        //エラーの場合
        if(error){
            [weakSelf handleError:error];
            return;
        }
        
        //キャンセルの場合
        if(!completed){
            [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusCancel];;
            return;
        }
        
        //成功した場合
        [weakSelf handleSuccessWithActivityType:activityType];
    }];
}

- (void)handleError:(NSError *)error{
    NSString *errorMessage = [NSString stringWithFormat:@"%@(%@)",[@"Failed!" FZZShareKitLocalized],error.description];
    if(errorMessage){
        [self HUDShowErrorWithStatus:errorMessage];
    }else{
        [self HUDShowErrorWithStatus:[@"Failed!" FZZShareKitLocalized]];
    }
    
    [self.delegate FZZShareKit:self didSharedWithStatus:FZZShareStatusFail];
}

- (void)handleSuccessWithActivityType:(NSString *)activityType{
    NSString *message;
    
    //完了メッセージを表示
    if([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
        message = [@"Saved!" FZZShareKitLocalized];
    }else if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]){
        message = [@"Copied!" FZZShareKitLocalized];
    }else if ([activityType isEqualToString:UIActivityTypeMail] ||
              [activityType isEqualToString:UIActivityTypeMessage] ||
              [activityType isEqualToString:UIActivityTypeAirDrop] ||
              [activityType isEqualToString:UIActivityTypePostToFacebook] ||
              [activityType isEqualToString:UIActivityTypePostToTencentWeibo] ||
              [activityType isEqualToString:UIActivityTypePostToTwitter] ||
              [activityType isEqualToString:UIActivityTypePostToVimeo] ||
              [activityType isEqualToString:UIActivityTypePostToWeibo] ||
              [activityType isEqualToString:UIActivityTypePostToFlickr]){
        message = [@"Shared!" FZZShareKitLocalized];
    }else if([activityType isEqualToString:@"UIActivityTypePostToInstagram"]){
        //メッセージは表示しない
        [self.delegate FZZShareKit:self didSharedWithStatus:FZZShareStatusSuccess];
        return;
    }else{
        message = [@"Done!" FZZShareKitLocalized];
    }
    [self HUDShowSuccessWithStatus:message];
    [self.delegate FZZShareKit:self didSharedWithStatus:FZZShareStatusSuccess];
}

- (void)HUDDismiss{
    if([NSThread isMainThread]){
        [SVProgressHUD dismiss];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }
}

- (void)HUDShow{
    if([NSThread isMainThread]){
        [SVProgressHUD show];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
        });
    }
}

- (void)HUDShowSuccessWithStatus:(NSString *)status{
    if([NSThread isMainThread]){
        [SVProgressHUD showSuccessWithStatus:status];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:status];
        });
    }
}

- (void)HUDShowErrorWithStatus:(NSString *)status{
    if([NSThread isMainThread]){
        [SVProgressHUD showErrorWithStatus:status];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:status];
        });
    }
}

@end
