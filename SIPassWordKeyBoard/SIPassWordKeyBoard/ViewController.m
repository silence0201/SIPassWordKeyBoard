//
//  ViewController.m
//  SIPassWordKeyBoard
//
//  Created by Silence on 2019/1/21.
//  Copyright © 2019年 Silence. All rights reserved.
//

#import "ViewController.h"
#import "SIPassWordKeyBoard.h"
#import "UITextField+PassWord.h"

#define iPhoneX ([UIApplication sharedApplication].statusBarFrame.size.height == 44.f)

@interface ViewController ()<UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.center = self.view.center;
    textField.passWordKeyBoardType = SITextFieldPasswordTypeRandomDefault;
    textField.delegate = self;
    [self.view addSubview:textField];
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"%s", __func__);
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%s", __func__);
    return YES;
}


@end
