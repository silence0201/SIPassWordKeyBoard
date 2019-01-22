//
//  SIPassWordKeyBoard.m
//  SIPassWordKeyBoard
//
//  Created by Silence on 2019/1/21.
//  Copyright © 2019年 Silence. All rights reserved.
//

#import "SIPassWordKeyBoard.h"

#define margin 5

@interface SIPassWordKeyBoardBasePad:UIView

@property (nonatomic, weak  ) UITextField *responder;
@property (nonatomic, weak  ) UIButton    *deleteBtn;
@property (nonatomic, weak  ) UIButton    *okBtn;
@property (nonatomic, strong) NSMutableArray *btnArray;

- (void)deleteBtnClick;
- (void)okBtnClick;

@end

@interface SIPassWordKeyBoardTool : NSObject

+ (NSRange)rangeFromTextRange:(UITextRange *)textRange inTextField:(UITextField *)textField;
+ (UITextRange *)textRangeFromRange:(NSRange)range inTextField:(UITextField *)textField;
+ (void)setSelectedRange:(NSRange)range ofTextField:(UITextField *)textField;
+ (void)appendString:(NSString *)newString forResponder:(UITextField *)textField;
+ (void)deleteStringForResponder:(UITextField *)textField;

@end

@class SIPassWordKeyBoardBtn;
@protocol SIPassWordKeyBoardBtnDelegate <NSObject>

@required
- (void)keyboardBtnDidClick:(SIPassWordKeyBoardBtn *)btn;

@end

@interface SIPassWordKeyBoardBtn : UIButton

@property (nonatomic, assign) id <SIPassWordKeyBoardBtnDelegate> delegate;

+ (SIPassWordKeyBoardBtn *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag  delegate:(id)delegate;

@end

@protocol SIPassWordKeyBoardNumPadDelegate  <NSObject>

@required
- (void)keyboardNumPadDidClickSwitchBtn:(UIButton *)btn;

@end



@interface SIPassWordKeyBoardNumPad : SIPassWordKeyBoardBasePad <SIPassWordKeyBoardBtnDelegate>

@property (nonatomic, assign) BOOL random;
@property (nonatomic, assign) id <SIPassWordKeyBoardNumPadDelegate> delegate;
@property (nonatomic, strong) NSArray *numArray;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, assign) SIPassWordKeyBoardNumPadType padType;

@end

@protocol SIPassWordKeyBoardSymbolPadDelegate  <NSObject>

@required
- (void)keyboardSymbolPadDidClickSwitchBtn:(UIButton *)btn;

@end

@interface SIPassWordKeyBoardSymbolPad : SIPassWordKeyBoardBasePad <SIPassWordKeyBoardBtnDelegate>

@property (nonatomic, assign) BOOL random;
@property (nonatomic, assign) id <SIPassWordKeyBoardSymbolPadDelegate> delegate;
@property (nonatomic, strong) NSArray *symbolArray;
@property (nonatomic, weak)   UIButton *numPadCheckBtn;
@property (nonatomic, weak)   UIButton *wordBtn;

@end

@protocol SIPassWordKeyBoardWordPadDelegate <NSObject>

@required
- (void)keyboardWordPadDidClickSwitchBtn:(UIButton *)btn;

@end

@interface SIPassWordKeyBoardWordPad : SIPassWordKeyBoardBasePad <SIPassWordKeyBoardBtnDelegate>

@property (nonatomic, assign) BOOL random;
@property (nonatomic, assign) id <SIPassWordKeyBoardWordPadDelegate> delegate;
@property (nonatomic, strong) NSArray  *wordArray;
@property (nonatomic, weak)   UIButton *trasitionWordBtn;
@property (nonatomic, weak)   UIButton *numPadCheckBtn;
@property (nonatomic, weak)   UIButton *symbolBtn;

@end

@implementation SIPassWordKeyBoardBasePad

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}
- (UITextField *)responder{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponder = [keyWindow valueForKey:@"firstResponder"];
    _responder = (UITextField *)firstResponder;
    return _responder;
}
- (void)deleteBtnClick{
    [SIPassWordKeyBoardTool deleteStringForResponder:self.responder];
}
- (void)okBtnClick{
    BOOL canReturn = YES;
    if ([self.responder.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        canReturn = [self.responder.delegate textFieldShouldReturn:self.responder];
    }
    
    if (!canReturn) return;
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

@end

@implementation SIPassWordKeyBoardTool

+ (NSRange)rangeFromTextRange:(UITextRange *)textRange inTextField:(UITextField *)textField{
    
    UITextPosition* beginning = textField.beginningOfDocument;
    UITextPosition* start = textRange.start;
    UITextPosition* end = textRange.end;
    
    const NSInteger location = [textField offsetFromPosition:beginning toPosition:start];
    const NSInteger length = [textField offsetFromPosition:start toPosition:end];
    
    return NSMakeRange(location, length);
}
+ (UITextRange *)textRangeFromRange:(NSRange)range inTextField:(UITextField *)textField{
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *startPosition = [textField positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [textField positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [textField textRangeFromPosition:startPosition toPosition:endPosition];
    return selectionRange;
}
+ (void)setSelectedRange:(NSRange)range ofTextField:(UITextField *)textField{
    
    UITextRange *selectionRange = [self textRangeFromRange:range inTextField:textField];
    [textField setSelectedTextRange:selectionRange];
}
+ (void)appendString:(NSString *)newString forResponder:(UITextField *)textField{
    
    NSRange selectRange = [SIPassWordKeyBoardTool rangeFromTextRange:textField.selectedTextRange inTextField:textField];
    
    BOOL shouldChange = YES;
    if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        shouldChange = [textField.delegate textField:textField shouldChangeCharactersInRange:selectRange replacementString:newString];
    }
    if (!shouldChange) return;
    
    [textField insertText:newString];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField userInfo:nil];
}

+ (void)deleteStringForResponder:(UITextField *)textField{
    [textField deleteBackward];
}

@end

@implementation SIPassWordKeyBoardBtn

+ (SIPassWordKeyBoardBtn *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate{
    SIPassWordKeyBoardBtn *btn = [SIPassWordKeyBoardBtn buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:btn action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadBtn"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadBtnHighLighted"] forState:UIControlStateHighlighted];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    btn.delegate = delegate;
    
    return btn;
}
- (void)btnClick:(SIPassWordKeyBoardBtn *)btn{
    if ([self.delegate respondsToSelector:@selector(keyboardBtnDidClick:)]) {
        [self.delegate keyboardBtnDidClick:btn];
    }
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end

@implementation SIPassWordKeyBoardSymbolPad

- (NSArray *)symbolArray{
    if (!_symbolArray) {
        _symbolArray = @[@"*",@"/",@":",@";",@"(",@")",@"[",@"]",@"$",@"=",@"!",@"^",@"&",@"%",@"+",@"-",@"￥",@"?",@"{",@"}",@"#",@"_",@"\\",@"|",@"~",@"`",@"∑",@"€",@"£",@"。"];
    }
    return _symbolArray;
}
- (void)setRandom:(BOOL)random{
    _random = random = random;
    if (random) {
        
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.symbolArray];
        for(int i = 0; i< self.symbolArray.count; i++)
        {
            int m = (arc4random() % (self.symbolArray.count - i)) + i;
            [newArray exchangeObjectAtIndex:i withObjectAtIndex: m];
        }
        self.symbolArray = newArray;
        for (UIButton *btn in self.subviews) {
            [btn removeFromSuperview];
        }
        [self addControl];
    }
    
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addControl];
    }
    
    return self;
}
- (void)addControl{
    NSMutableArray *btnArray = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        SIPassWordKeyBoardBtn *btn = [SIPassWordKeyBoardBtn buttonWithTitle:self.symbolArray[i] tag:i delegate:self];
        [self addSubview:btn];
        [btnArray addObject:btn];
    }
    self.btnArray = btnArray;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadDeleteBtn"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteBtn];
    
    UIButton *numPadCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [numPadCheckBtn setTitle:@"123" forState:UIControlStateNormal];
    [numPadCheckBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
    [numPadCheckBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    numPadCheckBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [numPadCheckBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:numPadCheckBtn];
    
    UIButton *wordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [wordBtn setTitle:@"ABC" forState:UIControlStateNormal];
    [wordBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
    wordBtn.titleLabel.textColor = numPadCheckBtn.titleLabel.textColor;
    [wordBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:wordBtn];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"完成" forState:UIControlStateNormal];
    [okBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
    okBtn.titleLabel.textColor = numPadCheckBtn.titleLabel.textColor;
    [okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:okBtn];
    
    self.okBtn = okBtn;
    self.wordBtn = wordBtn;
    self.numPadCheckBtn = numPadCheckBtn;
    self.deleteBtn = deleteBtn;
    
    self.okBtn.layer.cornerRadius = 5.0;
    self.okBtn.layer.masksToBounds = YES;
    self.numPadCheckBtn.layer.cornerRadius = 5.0;
    self.numPadCheckBtn.layer.masksToBounds = YES;
    self.wordBtn.layer.cornerRadius = 5.0;
    self.wordBtn.layer.masksToBounds = YES;
    self.deleteBtn.layer.cornerRadius = 5.0;
    self.deleteBtn.layer.masksToBounds = YES;
    
}
- (void)switchBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(keyboardSymbolPadDidClickSwitchBtn:)]) {
        [self.delegate keyboardSymbolPadDidClickSwitchBtn:btn];
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize currentSize = self.bounds.size;
    int padMargin = 0;
    
    CGFloat btnW = (currentSize.width - 13*margin)/10;
    CGFloat btnH = (currentSize.height - 5*margin)/4;
    
    for (int i = 0; i < 30; i++) {
        SIPassWordKeyBoardBtn *btn = self.btnArray[i];
        btn.frame = CGRectMake(padMargin + 2*margin + (i%10)*(btnW + margin), margin + (i/10)*(margin + btnH), btnW, btnH);
    }
    
    CGFloat bigBtnW = (currentSize.width - 7*margin)/4;
    self.numPadCheckBtn.frame = CGRectMake(padMargin + 2*margin, 4*margin + btnH*3, bigBtnW, btnH);
    self.wordBtn.frame = CGRectMake(padMargin + 3*margin+bigBtnW, 4*margin + btnH*3, bigBtnW, btnH);
    self.deleteBtn.frame = CGRectMake(padMargin + 4*margin + 2*bigBtnW, 4*margin + btnH*3, bigBtnW, btnH);
    self.okBtn.frame = CGRectMake(padMargin + 5*margin + 3*bigBtnW, 4*margin + btnH*3, bigBtnW, btnH);
    
}

#pragma mark - SIPassWordKeyBoardBtnDelegate
-(void)keyboardBtnDidClick:(SIPassWordKeyBoardBtn *)btn{
    [SIPassWordKeyBoardTool appendString:btn.titleLabel.text forResponder:self.responder];
}

@end

@implementation SIPassWordKeyBoardNumPad

- (NSArray *)numArray{
    if (!_numArray) {
        _numArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"@",@"."];
    }
    return _numArray;
}
- (void)setRandom:(BOOL)random{
    _random = random = random;
    if (random) {
        
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.numArray];
        for(int i = 0; i< self.numArray.count; i++)
        {
            int m = (arc4random() % (self.numArray.count - i)) + i;
            [newArray exchangeObjectAtIndex:i withObjectAtIndex: m];
        }
        self.numArray = newArray;
        [self removeAllBtns];
        [self addControl];
    }
    
}
- (void)switchBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(keyboardNumPadDidClickSwitchBtn:)]) {
        [self.delegate keyboardNumPadDidClickSwitchBtn:btn];
    }
}
- (void)setPadType:(SIPassWordKeyBoardNumPadType)padType{
    if (padType == SIPassWordKeyBoardNumPadOnly) {
        self.numArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    }else{
        self.numArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"@",@"."];
    }
    if (_padType != padType) {
        _padType = padType;
        [self removeAllBtns];
        [self addControl];
    }
}
- (void)removeAllBtns{
    for (UIButton *btn in self.subviews) {
        [btn removeFromSuperview];
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addControl];
    }
    return self;
}
- (void)addControl{
    
    NSMutableArray *btnArray = [NSMutableArray array];
    SIPassWordKeyBoardBtn *btn1 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[0] tag:0 delegate:self];
    [self addSubview:btn1];
    
    SIPassWordKeyBoardBtn *btn2 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[1] tag:1 delegate:self];
    [self addSubview:btn2];
    
    SIPassWordKeyBoardBtn *btn3 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[2] tag:2 delegate:self];
    [self addSubview:btn3];
    
    SIPassWordKeyBoardBtn *btn4 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[3] tag:4 delegate:self];
    [self addSubview:btn4];
    
    SIPassWordKeyBoardBtn *btn5 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[4] tag:5 delegate:self];
    [self addSubview:btn5];
    
    SIPassWordKeyBoardBtn *btn6 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[5] tag:6 delegate:self];
    [self addSubview:btn6];
    
    SIPassWordKeyBoardBtn *btn7 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[6] tag:8 delegate:self];
    [self addSubview:btn7];
    
    SIPassWordKeyBoardBtn *btn8 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[7] tag:9 delegate:self];
    [self addSubview:btn8];
    
    SIPassWordKeyBoardBtn *btn9 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[8] tag:10 delegate:self];
    [self addSubview:btn9];
    
    SIPassWordKeyBoardBtn *btn0 = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[9] tag:13 delegate:self];
    [self addSubview:btn0];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadDeleteBtn"] forState:UIControlStateNormal];
    [self addSubview:deleteBtn];
    deleteBtn.tag = 11;
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self addSubview:okBtn];
    [okBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
    okBtn.tag = 15;
    
    [deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnArray = btnArray;
    [self.btnArray addObject:btn1];
    [self.btnArray addObject:btn2];
    [self.btnArray addObject:btn3];
    [self.btnArray addObject:btn4];
    [self.btnArray addObject:btn5];
    [self.btnArray addObject:btn6];
    [self.btnArray addObject:btn7];
    [self.btnArray addObject:btn8];
    [self.btnArray addObject:btn9];
    [self.btnArray addObject:deleteBtn];
    [self.btnArray addObject:btn0];
    [self.btnArray addObject:okBtn];
    
    
    if (self.padType == SIPassWordKeyBoardNumPadDefault) {
        
        SIPassWordKeyBoardBtn *btnAT = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[10] tag:12 delegate:self];
        [self addSubview:btnAT];
        
        SIPassWordKeyBoardBtn *pointBtn = [SIPassWordKeyBoardBtn buttonWithTitle:self.numArray[11] tag:14 delegate:self];
        [self addSubview:pointBtn];
        
        UIButton *wordSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        wordSwitchBtn.tag = 3;
        [wordSwitchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [wordSwitchBtn setTitle:@"ABC" forState:UIControlStateNormal];
        wordSwitchBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [wordSwitchBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
        [self addSubview:wordSwitchBtn];
        
        UIButton *symbolSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [symbolSwitchBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
        [symbolSwitchBtn setTitle:@"@#%" forState:UIControlStateNormal];
        [symbolSwitchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        symbolSwitchBtn.titleLabel.font = wordSwitchBtn.titleLabel.font;
        symbolSwitchBtn.tag = 7;
        [self addSubview:symbolSwitchBtn];
        
        [wordSwitchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [symbolSwitchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.btnArray addObject:btnAT];
        [self.btnArray addObject:pointBtn];
        [self.btnArray addObject:symbolSwitchBtn];
        [self.btnArray addObject:wordSwitchBtn];
        
        for (int i = 11; i<16; i++) {
            UIButton *btn = self.btnArray[i];
            btn.layer.cornerRadius = 5;
            btn.layer.masksToBounds = YES;
        }
    }else if(self.padType == SIPassWordKeyBoardNumPadOnly){
        for (int i = 0; i<self.btnArray.count; i++) {
            UIButton *btn = self.btnArray[i];
            btn.tag = i;
        }
    }
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize currentSize = self.bounds.size;
    int padMargin = 0;
    UIDeviceOrientation currentOri = [UIDevice currentDevice].orientation;
    
    if (self.padType == SIPassWordKeyBoardNumPadOnly) {
        
        int rowNum = 4;//行
        int lineNum = 3;//列
        
        UIButton *btnTag8 = self.btnArray[8];
        UIButton *btnTag10 = self.btnArray[9];
        if (currentOri != UIDeviceOrientationPortrait ) {
            rowNum = 3;
            lineNum = 4;
            if (btnTag8.tag==8) {
                btnTag8.tag = 9;
                btnTag10.tag = 8;
            }
        }else{
            if (btnTag8.tag!=8) {
                btnTag8.tag = 8;
                btnTag10.tag = 9;
            }
        }
        
        CGFloat btnW = (currentSize.width - (lineNum+1)*margin)/lineNum;
        CGFloat btnH = (currentSize.height - (rowNum+1)*margin)/rowNum;
        
        for (SIPassWordKeyBoardBtn *btn in self.btnArray) {
            btn.frame = CGRectMake(padMargin +margin + btn.tag % lineNum * (btnW + margin), margin + btn.tag / lineNum * (btnH + margin), btnW, btnH);
        }
    }else{
        
        CGFloat btnW = (currentSize.width - 5*margin)/4;
        CGFloat btnH = (currentSize.height - 5*margin)/4;
        for (SIPassWordKeyBoardBtn *btn in self.btnArray) {
            btn.frame = CGRectMake(padMargin +margin + btn.tag % 4 * (btnW + margin), margin + btn.tag / 4 * (btnH + margin), btnW, btnH);
        }
    }
}
#pragma mark - SIPassWordKeyBoardBtnDelegate
-(void)keyboardBtnDidClick:(SIPassWordKeyBoardBtn *)btn{
    [SIPassWordKeyBoardTool appendString:btn.titleLabel.text forResponder:self.responder];
}

@end

@implementation SIPassWordKeyBoardWordPad

- (NSArray *)wordArray{
    if (!_wordArray) {
        _wordArray = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m"];
    }
    return _wordArray;
}
- (void)setRandom:(BOOL)random{
    _random = random = random;
    if (random) {
        
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.wordArray];
        for(int i = 0; i< self.wordArray.count; i++)
        {
            int m = (arc4random() % (self.wordArray.count - i)) + i;
            [newArray exchangeObjectAtIndex:i withObjectAtIndex: m];
        }
        self.wordArray = newArray;
        for (UIButton *btn in self.subviews) {
            [btn removeFromSuperview];
        }
        [self addControl];
    }
    
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addControl];
    }
    return self;
}
- (void)addControl{
    NSMutableArray *btnArray = [NSMutableArray array];
    for (int i = 0; i< 26; i++) {// 添加26个英文字母
        SIPassWordKeyBoardBtn *btn = [SIPassWordKeyBoardBtn buttonWithTitle:self.wordArray[i] tag:i delegate:self];
        [btnArray addObject:btn];
        [self addSubview:btn];
    }
    self.btnArray = btnArray;
    
    SIPassWordKeyBoardBtn *blankBtn = [SIPassWordKeyBoardBtn buttonWithTitle:@"空格" tag:26 delegate:self];
    [btnArray addObject:blankBtn];
    [self addSubview:blankBtn];
    
    UIButton *trasitionWordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [trasitionWordBtn setImage:[UIImage imageNamed:@"images.bundle/trasition_normal"] forState:UIControlStateNormal];
    [trasitionWordBtn setImage:[UIImage imageNamed:@"images.bundle/trasition_highlighted"] forState:UIControlStateSelected];
    
    [trasitionWordBtn addTarget:self action:@selector(trasitionWord:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:trasitionWordBtn];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadDeleteBtn2"] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteBtn];
    
    UIButton *numPadCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [numPadCheckBtn setTitle:@"123" forState:UIControlStateNormal];
    [numPadCheckBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
    [numPadCheckBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    numPadCheckBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [numPadCheckBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:numPadCheckBtn];
    
    UIButton *symbolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [symbolBtn setTitle:@"@#%" forState:UIControlStateNormal];
    [symbolBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
    symbolBtn.titleLabel.textColor = numPadCheckBtn.titleLabel.textColor;
    [symbolBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:symbolBtn];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"完成" forState:UIControlStateNormal];
    [okBtn setBackgroundImage:[UIImage imageNamed:@"images.bundle/keypadLongBtn"] forState:UIControlStateNormal];
    okBtn.titleLabel.textColor = numPadCheckBtn.titleLabel.textColor;
    [okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:okBtn];
    
    self.okBtn = okBtn;
    self.symbolBtn = symbolBtn;
    self.numPadCheckBtn = numPadCheckBtn;
    self.deleteBtn = deleteBtn;
    self.trasitionWordBtn = trasitionWordBtn;
    
    
    self.numPadCheckBtn.layer.cornerRadius = 5.0;
    self.numPadCheckBtn.layer.masksToBounds = YES;
    self.okBtn.layer.cornerRadius = 5.0;
    self.okBtn.layer.masksToBounds = YES;
    self.symbolBtn.layer.cornerRadius = 5.0;
    self.symbolBtn.layer.masksToBounds = YES;
    
    self.deleteBtn.layer.cornerRadius = 5.0;
    self.deleteBtn.layer.masksToBounds = YES;
    
}
- (void)trasitionWord:(UIButton *)trasitionWordBtn{
    trasitionWordBtn.selected = !trasitionWordBtn.selected;
    if (trasitionWordBtn.selected) {
        for (int i = 0; i<26; i++) {
            SIPassWordKeyBoardBtn *btn = self.btnArray[i];
            [btn setTitle:[btn.titleLabel.text uppercaseString] forState:UIControlStateNormal];
        }
    }else{
        for (int i = 0; i<26; i++) {
            SIPassWordKeyBoardBtn *btn = self.btnArray[i];
            [btn setTitle:[btn.titleLabel.text lowercaseString] forState:UIControlStateNormal];
        }
    }
    
}
- (void)switchBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(keyboardWordPadDidClickSwitchBtn:)]) {
        [self.delegate keyboardWordPadDidClickSwitchBtn:btn];
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize currentSize = self.bounds.size;
    int padMargin = 0;
    
    CGFloat smallBtnW = (currentSize.width - 13*margin)/10;
    CGFloat btnH = (currentSize.height - 5*margin)/4;
    
    for (int i = 0; i < 10; i++) {
        SIPassWordKeyBoardBtn *btn = self.btnArray[i];
        btn.frame = CGRectMake(padMargin + 2*margin + i*(smallBtnW + margin), margin, smallBtnW, btnH);
    }
    
    CGFloat margin2 = (currentSize.width - 8*margin - 9*smallBtnW)/2;
    for (int i = 10; i < 19; i++) {
        SIPassWordKeyBoardBtn *btn = self.btnArray[i];
        btn.frame = CGRectMake(padMargin + margin2 + (i-10)*(smallBtnW + margin), 2*margin + btnH, smallBtnW, btnH);
    }
    
    CGFloat margin3 = (currentSize.width - 9.5*smallBtnW - 6*margin)/4;
    self.trasitionWordBtn.frame = CGRectMake(padMargin + margin3, 3*margin + 2*btnH, smallBtnW, btnH);
    
    self.deleteBtn.frame = CGRectMake(padMargin + margin3*3 + 6*margin + 8*smallBtnW, 3*margin + 2*btnH, smallBtnW*1.5, btnH);
    for (int i = 19; i<26; i++) {
        SIPassWordKeyBoardBtn *btn = self.btnArray[i];
        btn.frame = CGRectMake(padMargin + 2*margin3 + smallBtnW + (i-19)*(smallBtnW + margin), 3*margin + 2*btnH, smallBtnW, btnH);
    }
    CGFloat bigBtnW = (currentSize.width - 5*margin)/4;
    self.numPadCheckBtn.frame = CGRectMake(padMargin + margin, 4*margin + btnH*3, bigBtnW, btnH);
    SIPassWordKeyBoardBtn *btn = [self.btnArray lastObject];
    btn.frame = CGRectMake(padMargin + 2*margin+bigBtnW, 4*margin + btnH*3, bigBtnW, btnH);
    self.symbolBtn.frame = CGRectMake(padMargin + 3*margin + 2*bigBtnW, 4*margin + btnH*3, bigBtnW, btnH);
    self.okBtn.frame = CGRectMake(padMargin + 4*margin + 3*bigBtnW, 4*margin + btnH*3, bigBtnW, btnH);
}

#pragma mark - SIPassWordKeyBoardBtnDelegate
- (void)keyboardBtnDidClick:(SIPassWordKeyBoardBtn *)btn{
    
    NSString *newText = btn.titleLabel.text;
    if ([btn.titleLabel.text isEqualToString:@"空格"]) {
        newText = @" ";
    }
    
    [SIPassWordKeyBoardTool appendString:newText forResponder:self.responder];
}

@end

@interface SIPassWordKeyBoard ()<SIPassWordKeyBoardNumPadDelegate,SIPassWordKeyBoardWordPadDelegate,SIPassWordKeyBoardSymbolPadDelegate>

@property (nonatomic, strong) SIPassWordKeyBoardNumPad    *numPad;
@property (nonatomic, strong) SIPassWordKeyBoardWordPad   *wordPad;
@property (nonatomic, strong) SIPassWordKeyBoardSymbolPad *symbolPad;

@end

@implementation SIPassWordKeyBoard

- (instancetype)initWithKeyBoardType:(SIPassWordKeyBoardNumPadType)keyBoardType {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:116/255.0 green:144/255.0 blue:194/255.0 alpha:0.2];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        SIPassWordKeyBoardNumPad *numPad = [[SIPassWordKeyBoardNumPad alloc] initWithFrame:self.bounds];
        numPad.delegate = self;
        numPad.padType = keyBoardType;
        self.numPad = numPad;
        [self addSubview:numPad];
    }
    return self;
}

- (instancetype)init{
    return [self initWithKeyBoardType:SIPassWordKeyBoardNumPadDefault];
}

- (SIPassWordKeyBoardNumPad *)numPad{
    if (!_numPad) {
        _numPad = [[SIPassWordKeyBoardNumPad alloc] initWithFrame:self.bounds];
        if (self.random) _wordPad.random = YES;
        _numPad.delegate = self;
    }
    return _numPad;
}
- (SIPassWordKeyBoardWordPad *)wordPad{
    if (!_wordPad) {
        _wordPad = [[SIPassWordKeyBoardWordPad alloc] initWithFrame:self.bounds];
        if (self.random) _wordPad.random = YES;
        _wordPad.delegate = self;
    }
    return _wordPad;
}
- (SIPassWordKeyBoardSymbolPad *)symbolPad{
    if (!_symbolPad) {
        _symbolPad =  [[SIPassWordKeyBoardSymbolPad alloc] initWithFrame:self.bounds];
        if (self.random) _symbolPad.random = YES;
        _symbolPad.delegate = self;
    }
    return _symbolPad;
}

- (void)keyboardNumPadDidClickSwitchBtn:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"ABC"]) {
        [self addSubview:self.wordPad];
        self.wordPad.frame = self.bounds;
        [self.numPad removeFromSuperview];
    }else{
        [self addSubview:self.symbolPad];
        self.symbolPad.frame = self.bounds;
        [self.numPad removeFromSuperview];
    }
}

- (void)keyboardWordPadDidClickSwitchBtn:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"123"]) {
        [self addSubview:self.numPad];
        self.numPad.frame = self.bounds;
        [self.wordPad removeFromSuperview];
    }else{
        [self addSubview:self.symbolPad];
        self.symbolPad.frame = self.bounds;
        [self.wordPad removeFromSuperview];
    }
}

- (void)keyboardSymbolPadDidClickSwitchBtn:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"123"]) {
        [self addSubview:self.numPad];
        self.numPad.frame = self.bounds;
        [self.symbolPad removeFromSuperview];
    }else{
        [self addSubview:self.wordPad];
        self.wordPad.frame = self.bounds;
        [self.symbolPad removeFromSuperview];
    }
}


@end



