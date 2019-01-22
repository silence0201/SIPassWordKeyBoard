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
    SITextFieldPasswordTypeNone,
    SITextFieldPasswordTypeDefault,
    SITextFieldPasswordTypeRandomDefault,
    SITextFieldPasswordTypeOnlyNum,
    SITextFieldPasswordTypeRandomOnlyNum
};

@interface UITextField (PassWord)

@property (nonatomic, assign) SITextFieldPasswordType passWordKeyBoardType;

@end

NS_ASSUME_NONNULL_END
