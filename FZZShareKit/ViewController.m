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
    self.shareKit.delegate = self;
    self.shareKit.actionButton = _button;
    [self.shareKit shareImage:[UIImage imageNamed:@"AppBankOff.jpeg"]
                     withText:@"#hushtag"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sharekit:(FZZShareKit *)sharekit didSharedWithStatus:(FZZShareStatus)status{
    if(status == FZZShareStatusSuccess){
        NSLog(@"Success");
    }
    
    if(status == FZZShareStatusFail){
        NSLog(@"Fail");
    }
    
    if(status == FZZShareStatusCancel){
        NSLog(@"Cancel");
    }
    
    [self.shareKit shareImage:[UIImage imageNamed:@"AppBankOff.jpeg"]
                     withText:@"#test"];
}

@end
