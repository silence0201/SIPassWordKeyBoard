//
//  ViewController.m
//  SIPassWordKeyBoard
//
//  Created by Silence on 2019/1/21.
//  Copyright © 2019年 Silence. All rights reserved.
//

#import "ViewController.h"
#import "SIPassWordKeyBoard.h"

#define iPhoneX ([UIApplication sharedApplication].statusBarFrame.size.height == 44.f)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *text = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    text.borderStyle = UITextBorderStyleRoundedRect;
    text.center = self.view.center;
    
    SIPassWordKeyBoard *keyBoard = [[SIPassWordKeyBoard alloc]initWithKeyBoardType:SIPassWordKeyBoardNumPadDefault];
    
    text.inputView = keyBoard;
    [self.view addSubview:text];
    
}


@end
