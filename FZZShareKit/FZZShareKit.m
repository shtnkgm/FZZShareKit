//
//  FZZShareKit.m
//  FZZShareKit
//
//  Created by Administrator on 2016/03/02.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import "FZZShareKit.h"
#import "FZZInstagramActivity.h"
#import "FZZOtherAppActivity.h"
#import "SVProgressHUD.h"
#import "NSString+FZZShareKitLocalized.h"

@interface FZZShareKit()

@property (nonatomic, strong) FZZInstagramActivity *instagramActivity;
@property (nonatomic, strong) FZZOtherAppActivity *otherAppActivity;

@property (nonatomic, weak) UIButton *actionButton;
@property (nonatomic, weak) UIBarButtonItem *actionBarButton;

@end

@implementation FZZShareKit

- (void)shareImage:(UIImage *)image
              text:(NSString *)text
          delegate:(id)delegate
      actionButton:(UIButton *)actionButton
    viewController:(UIViewController *)viewController{
    
    self.delegate = delegate;
    self.actionButton = actionButton;
    
    [self shareImage:image
                text:text
      viewController:viewController];
}

- (void)shareImage:(UIImage *)image
              text:(NSString *)text
          delegate:(id)delegate
   actionBarButton:(UIBarButtonItem *)actionBarButton
    viewController:(UIViewController *)viewController{
    
    self.delegate = delegate;
    self.actionBarButton = actionBarButton;
    
}

- (void)shareImage:(UIImage *)image
              text:(NSString *)text
    viewController:(UIViewController *)viewController{
    NSLog(@"%s",__func__);
    if([NSThread isMainThread]){
        [SVProgressHUD show];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
        });
    }
    
    if(!image){
        [_delegate FZZShareKit:self didSharedWithStatus:FZZShareStatusFail];
        return;
    }
    
    self.instagramActivity = [FZZInstagramActivity new];
    
    if(self.actionBarButton){
        self.otherAppActivity = [[FZZOtherAppActivity alloc] initWithView:((UIViewController *)_delegate).view
                                                         andBarButtonItem:_actionBarButton];
    }else{
        self.otherAppActivity = [[FZZOtherAppActivity alloc] initWithView:((UIViewController *)_delegate).view
                                                                  andRect:_actionButton.frame];
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[image,text]
                                                        applicationActivities:@[_instagramActivity,_otherAppActivity]];
    
    self.otherAppActivity.superViewController = activityViewController;
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePrint];
    
    if(_actionButton){
        activityViewController.popoverPresentationController.sourceView = _actionButton;
        activityViewController.popoverPresentationController.sourceRect = _actionButton.bounds;
    }else if(_actionBarButton){
        activityViewController.popoverPresentationController.barButtonItem = _actionBarButton;
    }
    
    __weak typeof(self) weakSelf = self;
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                            BOOL completed,
                                                            NSArray *returnedItems,
                                                            NSError *error){
        NSLog(@"%@(%d)",activityType,completed);
        
        if(error){
            [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusFail];
            NSString *errorMessage = [NSString stringWithFormat:@"%@(%@)",[@"Failed!" localized],error.description];
            if(errorMessage){
                if([NSThread isMainThread]){
                    [SVProgressHUD showErrorWithStatus:errorMessage];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:errorMessage];
                    });
                }
            }else{
                if([NSThread isMainThread]){
                    [SVProgressHUD showErrorWithStatus:[@"Failed!" localized]];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:[@"Failed!" localized]];
                    });
                }
            }
            return;
        }
        
        if(completed){
            //完了メッセージを表示
            if([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
                if([NSThread isMainThread]){
                    [SVProgressHUD showSuccessWithStatus:[@"Saved!" localized]];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:[@"Saved!" localized]];
                    });
                }
                [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            if([activityType isEqualToString:UIActivityTypeCopyToPasteboard]){
                if([NSThread isMainThread]){
                    [SVProgressHUD showSuccessWithStatus:[@"Copied!" localized]];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:[@"Copied!" localized]];
                    });
                }
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
                if([NSThread isMainThread]){
                    [SVProgressHUD showSuccessWithStatus:[@"Shared!" localized]];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:[@"Shared!" localized]];
                    });
                }
                [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            if([activityType isEqualToString:@"UIActivityTypePostToOtherApp"] ||
               [activityType isEqualToString:@"UIActivityTypePostToInstagram"]){
                if([NSThread isMainThread]){
                    [SVProgressHUD showSuccessWithStatus:[@"Done!" localized]];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:[@"Done!" localized]];
                    });
                }
                [weakSelf.delegate FZZShareKit:weakSelf didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            //それ以外の場合
            if([NSThread isMainThread]){
                [SVProgressHUD showSuccessWithStatus:[@"Done!" localized]];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:[@"Done!" localized]];
                });
            }

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


@end
