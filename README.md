# SIPassWordKeyBoard

![Language](https://img.shields.io/badge/language-objc-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)  
将JSON快速转换模型

使用说明
====
### 安装
将项目目录下的`Classes`导入项目中

### 使用
1. 导入头文件

	```objective-c
	#import "UITextField+PassWord.h"
	```
	
2. 设置密码键盘类型:

	```objective-c
	textField.passWordKeyBoardType = SITextFieldPasswordTypeRandomDefault;
	```
3. 类型包括

	```objective-c
	typedef NS_ENUM(NSUInteger, SITextFieldPasswordType) {
    SITextFieldPasswordTypeNone,  // 不使用
    SITextFieldPasswordTypeDefault, // 默认,包含符号和字母
    SITextFieldPasswordTypeRandomDefault, // 默认并且随机,包含符号和字母
    SITextFieldPasswordTypeOnlyNum,  // 只包含数字
    SITextFieldPasswordTypeRandomOnlyNum  // 只包含数字并随机
	};
	```
	
		
4. 更多请查看项目Demo

## SIPassWordKeyBoard
SIPassWordKeyBoard is available under the MIT license. See the LICENSE file for more info.