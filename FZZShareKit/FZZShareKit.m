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
        [_delegate FZZShareKit:self didSharedWithStatus:FZZShareStatusFail];
        return;
    }
    
    self.instagramActivity = [FZZInstagramActivity new];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[image,text]
                                                        applicationActivities:@[_instagramActivity]];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePrint];
    
    if(actionButton){
        _instagramActivity.presentFromButton = actionButton;
        activityViewController.popoverPresentationController.sourceView = actionButton;
        activityViewController.popoverPresentationController.sourceRect = actionButton.bounds;
    }
    
    __weak typeof(self) weakSelf = self;
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                            BOOL completed,
                                                            NSArray *returnedItems,
                                                            NSError *error){
        if(error){
            [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusFail];
            NSString *errorMessage = [NSString stringWithFormat:@"%@(%@)",[@"Failed!" FZZShareKitLocalized],error.description];
            if(errorMessage){
                [self HUDShowErrorWithStatus:errorMessage];
            }else{
                [self HUDShowErrorWithStatus:[@"Failed!" FZZShareKitLocalized]];
            }
            return;
        }
        
        if(completed){
            //完了メッセージを表示
            if([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
                [self HUDShowSuccessWithStatus:[@"Saved!" FZZShareKitLocalized]];
                [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            if([activityType isEqualToString:UIActivityTypeCopyToPasteboard]){
                [self HUDShowSuccessWithStatus:[@"Copied!" FZZShareKitLocalized]];
                [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            if([activityType isEqualToString:UIActivityTypeMail] ||
               [activityType isEqualToString:UIActivityTypeMessage] ||
               [activityType isEqualToString:UIActivityTypeAirDrop] ||
               [activityType isEqualToString:UIActivityTypePostToFacebook] ||
               [activityType isEqualToString:UIActivityTypePostToTencentWeibo] ||
               [activityType isEqualToString:UIActivityTypePostToTwitter] ||
               [activityType isEqualToString:UIActivityTypePostToVimeo] ||
               [activityType isEqualToString:UIActivityTypePostToWeibo] ||
               [activityType isEqualToString:UIActivityTypePostToFlickr]){
                [self HUDShowSuccessWithStatus:[@"Shared!" FZZShareKitLocalized]];
                [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            if([activityType isEqualToString:@"UIActivityTypePostToInstagram"]){
                //メッセージは表示しない
                [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            //それ以外の場合
            [self HUDShowSuccessWithStatus:[@"Done!" FZZShareKitLocalized]];

            [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusSuccess];
            return;
        }else{
            [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusCancel];;
            return;
        }
    }];
    
    [viewController presentViewController:activityViewController animated:YES completion:^{
        if([NSThread isMainThread]){
            [SVProgressHUD dismiss];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    }];
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
