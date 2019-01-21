//
//  SIPassWordKeyBoard.h
//  SIPassWordKeyBoard
//
//  Created by Silence on 2019/1/21.
//  Copyright © 2019年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SIPassWordKeyBoardNumPadType) {
    SIPassWordKeyBoardNumPadDefault,
    SIPassWordKeyBoardNumPadOnly,
};

@interface SIPassWordKeyBoard : UIView

- (instancetype)initWithKeyBoardType:(SIPassWordKeyBoardNumPadType)keyBoardType;

/// 随机排序,默认为NO
@property (nonatomic, assign) BOOL random;

@end

NS_ASSUME_NONNULL_END
