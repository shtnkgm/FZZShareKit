//
//  FZZShareKit.h
//  FZZShareKit
//
//  Created by Administrator on 2016/03/02.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  FZZShareKitDelegate;

typedef enum : NSInteger{
    FZZShareStatusSuccess,
    FZZShareStatusFail,
    FZZShareStatusCancel
}FZZShareStatus;

@interface FZZShareKit : NSObject

@property (nonatomic, weak) id<FZZShareKitDelegate>delegate;

- (void)shareImage:(UIImage *)image
              text:(NSString *)text
          delegate:(id)delegate
      actionButton:(UIButton *)actionButton
    viewController:(UIViewController *)viewController;

- (void)shareImage:(UIImage *)image
              text:(NSString *)text
          delegate:(id)delegate
    actionBarButton:(UIBarButtonItem *)actionBarButton
    viewController:(UIViewController *)viewController;

@end

@protocol FZZShareKitDelegate

- (void)FZZShareKit:(FZZShareKit *)sharekit didSharedWithStatus:(FZZShareStatus)status;

@end