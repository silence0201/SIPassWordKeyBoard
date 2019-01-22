//
//  UITextField+PassWord.m
//  SIPassWordKeyBoard
//
//  Created by Silence on 2019/1/22.
//  Copyright © 2019年 Silence. All rights reserved.
//

#import "UITextField+PassWord.h"
#import "SIPassWordKeyBoard.h"
#import <objc/runtime.h>

#define IS_IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define BOTTOM_MARGIN         (IS_IPHONE_X ? 34.f : 0.f)

@implementation UITextField (PassWord)

- (SITextFieldPasswordType)passWordKeyBoardType {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setPassWordKeyBoardType:(SITextFieldPasswordType)passWordKeyBoardType {
    objc_setAssociatedObject(self, @selector(passWordKeyBoardType), @(passWordKeyBoardType), OBJC_ASSOCIATION_ASSIGN);
    
    if (passWordKeyBoardType == SITextFieldPasswordTypeNone) {
        self.inputView = nil;
        return;
    }
    
    SIPassWordKeyBoard *keyboard;
    if (passWordKeyBoardType == SITextFieldPasswordTypeDefault || passWordKeyBoardType == SITextFieldPasswordTypeRandomDefault) {
        keyboard = [[SIPassWordKeyBoard alloc]initWithKeyBoardType:SIPassWordKeyBoardNumPadDefault];
    }else if (passWordKeyBoardType == SITextFieldPasswordTypeOnlyNum ||passWordKeyBoardType == SITextFieldPasswordTypeRandomOnlyNum) {
        keyboard = [[SIPassWordKeyBoard alloc]initWithKeyBoardType:SIPassWordKeyBoardNumPadOnly];
    }
    
    if (passWordKeyBoardType == SITextFieldPasswordTypeRandomDefault || passWordKeyBoardType == SITextFieldPasswordTypeRandomOnlyNum) {
        keyboard.random = YES;
    }
    
    keyboard.frame = CGRectMake(0, 0, 320, 216);
    UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 216 + BOTTOM_MARGIN)];
    inputView.backgroundColor = keyboard.backgroundColor;
    [inputView addSubview:keyboard];
    self.inputView = inputView;
}

@end
