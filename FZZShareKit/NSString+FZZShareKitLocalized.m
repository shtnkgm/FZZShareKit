//
//  NSString+Localized.m
//  FZZInfoKit
//
//  Created by Administrator on 2016/02/21.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import "NSString+FZZShareKitLocalized.h"

@implementation NSString (FZZShareKitLocalized)

- (instancetype)FZZShareKitLocalized{
    NSLog(@"%@:%s",self,__func__);
    NSString *localizedFileName = @"FZZShareKitLocalizable";
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"FZZShareKit" withExtension:@"bundle"];
    NSBundle *bundle;
    
    if (bundleURL) {
        bundle = [NSBundle bundleWithURL:bundleURL];
    } else {
        bundle = [NSBundle mainBundle];
    }
    
    NSString *localizedString = NSLocalizedStringFromTableInBundle(self,localizedFileName,bundle, nil);
    return localizedString;
}

@end
