//
//  UITextField+PassWord.h
//  SIPassWordKeyBoard
//
//  Created by Silence on 2019/1/22.
//  Copyright © 2019年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SITextFieldPasswordType) {
    SITextFieldPasswordTypeNone,  // 不使用
    SITextFieldPasswordTypeDefault, // 默认,包含符号和字母
    SITextFieldPasswordTypeRandomDefault, // 默认并且随机,包含符号和字母
    SITextFieldPasswordTypeOnlyNum,  // 只包含数字
    SITextFieldPasswordTypeRandomOnlyNum  // 只包含数字并随机
};

@interface UITextField (PassWord)

@property (nonatomic, assign) SITextFieldPasswordType passWordKeyBoardType;

@end

NS_ASSUME_NONNULL_END
