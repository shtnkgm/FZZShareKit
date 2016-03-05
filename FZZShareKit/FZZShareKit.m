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
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePrint];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                            BOOL completed,
                                                            NSArray *returnedItems,
                                                            NSError *error){
        if(error){
            [_delegate sharekit:self didSharedWithStatus:FZZShareStatusFail];
            [SVProgressHUD showErrorWithStatus:nil];
            return;
        }
        
        if(completed){
            if(![activityType isEqualToString:@"UIActivityTypePostToOtherApp"]){
                [SVProgressHUD showSuccessWithStatus:nil];
            }
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
