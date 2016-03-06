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

@end

@implementation FZZShareKit

- (void)shareImage:(UIImage *)shareImage withText:(NSString *)shareText{
    [self useActivityViewControllerWith:shareImage withText:shareText];
}

- (void)useActivityViewControllerWith:(UIImage *)shareImage withText:(NSString *)shareText{
    if(!shareImage){
        [_delegate sharekit:self didSharedWithStatus:FZZShareStatusFail];
        return;
    }
    
    //イメージをコピー
    UIImage *image = [UIImage imageWithCGImage:shareImage.CGImage];
        
    self.instagramActivity = [FZZInstagramActivity new];
    
    if(self.actionBarButton){
        self.otherAppActivity = [[FZZOtherAppActivity alloc] initWithView:((UIViewController *)_delegate).view
                                                         andBarButtonItem:_actionBarButton];
    }else{
        self.otherAppActivity = [[FZZOtherAppActivity alloc] initWithView:((UIViewController *)_delegate).view
                                                                  andRect:_actionButton.frame];
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[image,shareText]
                                                        applicationActivities:@[_instagramActivity,_otherAppActivity]];
    
    self.otherAppActivity.superViewController = activityViewController;
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePrint];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                            BOOL completed,
                                                            NSArray *returnedItems,
                                                            NSError *error){
        NSLog(@"%@,%d,%@",activityType,completed,error.description);
        
        if(error){
            [_delegate sharekit:self didSharedWithStatus:FZZShareStatusFail];
            NSString *errorMessage = [NSString stringWithFormat:@"%@(%@)",[@"Failed!" localized],error.description];
            if(errorMessage){
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }else{
                [SVProgressHUD showErrorWithStatus:[@"Failed!" localized]];
            }
            return;
        }
        
        if(completed){
            //完了メッセージを表示
            if([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
                [SVProgressHUD showSuccessWithStatus:[@"Saved!" localized]];
                [_delegate sharekit:self didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            if([activityType isEqualToString:UIActivityTypeCopyToPasteboard]){
                [SVProgressHUD showSuccessWithStatus:[@"Copied!" localized]];
                [_delegate sharekit:self didSharedWithStatus:FZZShareStatusSuccess];
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
                [SVProgressHUD showSuccessWithStatus:[@"Shared!" localized]];
                [_delegate sharekit:self didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            if([activityType isEqualToString:@"UIActivityTypePostToOtherApp"] ||
               [activityType isEqualToString:@"UIActivityTypePostToInstagram"]){
                [SVProgressHUD showSuccessWithStatus:[@"Done!" localized]];
                [_delegate sharekit:self didSharedWithStatus:FZZShareStatusSuccess];
                return;
            }
            
            //それ以外の場合
            [SVProgressHUD showSuccessWithStatus:[@"Done!" localized]];
            [_delegate sharekit:self didSharedWithStatus:FZZShareStatusSuccess];
            return;
        }else{
            [_delegate sharekit:self didSharedWithStatus:FZZShareStatusCancel];;
            return;
        }
    }];
    
    if(_actionButton){
        activityViewController.popoverPresentationController.sourceView = _actionButton;
        activityViewController.popoverPresentationController.sourceRect = _actionButton.bounds;
    }else if(_actionBarButton){
        activityViewController.popoverPresentationController.barButtonItem = _actionBarButton;
    }
    
    [(UIViewController *)_delegate presentViewController:activityViewController animated:YES completion:^{
        //何かする？
    }];
}


@end
