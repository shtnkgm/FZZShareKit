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

@property (nonatomic, weak) UIButton *actionButton;
@property (nonatomic, weak) UIBarButtonItem *actionBarButton;
@property (nonatomic, weak) id<FZZShareKitDelegate>delegate;

- (void)shareImage:(UIImage *)shareImage withText:(NSString *)shareText;

@end

@protocol FZZShareKitDelegate

- (void)sharekit:(FZZShareKit *)sharekit didSharedWithStatus:(FZZShareStatus)status;

@end