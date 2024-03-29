//
//  ViewController.m
//  FZZShareKit
//
//  Created by Administrator on 2016/02/29.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import "ViewController.h"
#import "FZZShareKit.h"

@interface ViewController ()
<FZZShareKitDelegate>
@property (nonatomic, strong) FZZShareKit *shareKit;
@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = self.view.bounds;
    [self.view addSubview:_button];
    
    self.shareKit = [FZZShareKit new];
    
    [self.shareKit shareImage:[UIImage imageNamed:@"AppBankOff.jpeg"]
                         text:@"#hushtag"
                     delegate:self
                 actionButton:_button
               viewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)FZZShareKit:(FZZShareKit *)sharekit didSharedWithStatus:(FZZShareStatus)status{
}

@end
