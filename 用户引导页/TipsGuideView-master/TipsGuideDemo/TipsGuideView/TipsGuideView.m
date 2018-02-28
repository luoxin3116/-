//
//  TipsGuideView.m
//  TipsGuideDemo
//
//  Created by wangzheng on 17/6/2.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "TipsGuideView.h"
#import "UIView+Layout.h"
#import "UIImage+Mask.h"

// 思路: 上下左右 中间 拼接成 蒙板 , 根据中间具体位置 来布局箭头,tipsLabel,和 知道按钮
@interface TipsGuideView ()
/**
 底部的view
 */
@property (nonatomic, weak) UIView *parentView;
/**
 知道了按钮
 */
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic, strong) UIImageView *btnMaskView;
@property (nonatomic, strong) UIImageView *arrwoView;
@property (nonatomic, strong) UILabel *tipsLabel;

//mask的rect
@property (nonatomic, assign) CGRect maskRect;


/**
 上面的maskview
 */
@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) UIView *leftMaskView;
@property (nonatomic, strong) UIView *rightMaskView;


/**
 
 */
@property (assign, nonatomic) NSInteger index;
@property (nonatomic, strong) NSArray *rectsArr;
@property (nonatomic, strong) NSMutableArray *tipsArr;
@property (nonatomic, copy) NSString *tipsStr;
@end

@implementation TipsGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.index = 0;
        [self addSubview:self.topMaskView];
        [self addSubview:self.bottomMaskView];
        [self addSubview:self.leftMaskView];
        [self addSubview:self.rightMaskView];
        [self addSubview:self.okBtn];
        [self addSubview:self.btnMaskView];
        [self addSubview:self.arrwoView];
        [self addSubview:self.tipsLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = _parentView.bounds;
    
    _btnMaskView.frame = self.maskRect;
    
    _topMaskView.left = 0;
    _topMaskView.top = 0;
    _topMaskView.height = _btnMaskView.top;
    _topMaskView.width = self.width;
    
    _bottomMaskView.left = 0;
    _bottomMaskView.top = _btnMaskView.bottom;
    _bottomMaskView.width = self.width;
    _bottomMaskView.height = self.height - _bottomMaskView.top;
    
    _leftMaskView.left = 0;
    _leftMaskView.top = _btnMaskView.top;
    _leftMaskView.width = _btnMaskView.left;
    _leftMaskView.height = _btnMaskView.height;
    
    _rightMaskView.left = _btnMaskView.right;
    _rightMaskView.top = _btnMaskView.top;
    _rightMaskView.width = self.width - _rightMaskView.left;
    _rightMaskView.height = _btnMaskView.height;
    
    _tipsLabel.text = self.tipsStr;
    [_tipsLabel sizeToFit];
    
    CGPoint self_Center = self.center;
    CGPoint btnMask_Center = _btnMaskView.center;
    
    if (btnMask_Center.x <= self_Center.x && btnMask_Center.y <= self_Center.y) {
        
        [_arrwoView setImage:[UIImage imageNamed:@"left_top"]];
        
        _arrwoView.left = _btnMaskView.center.x;
        _arrwoView.top  = _btnMaskView.bottom + 8;
        
        _tipsLabel.left = _arrwoView.right + 6;
        _tipsLabel.top = _arrwoView.bottom + 10;
        
        _okBtn.centerX = self.width/2;
        _okBtn.bottom = _tipsLabel.bottom + 80;
        
    }
    
    if (btnMask_Center.x >= self_Center.x && btnMask_Center.y <= self_Center.y){
        
        [_arrwoView setImage:[UIImage imageNamed:@"right_top"]];
        
        _arrwoView.right = _btnMaskView.center.x;
        _arrwoView.top = _btnMaskView.bottom + 8;
        
        _tipsLabel.right = _arrwoView.left - 6;
        _tipsLabel.top = _arrwoView.bottom + 10;
        
        _okBtn.centerX = self.width/2;
        _okBtn.bottom = _tipsLabel.bottom + 80;
    }
    
    if (btnMask_Center.x <= self_Center.x && btnMask_Center.y >= self_Center.y) {
        
        [_arrwoView setImage:[UIImage imageNamed:@"left_down"]];
        
        _arrwoView.left = _btnMaskView.center.x;
        _arrwoView.bottom = _btnMaskView.top - 8;
        
        _tipsLabel.left = _arrwoView.right;
        _tipsLabel.bottom = _arrwoView.top - 10;
        
        _okBtn.centerX = self.width/2;
        _okBtn.bottom = _tipsLabel.top - 80;
        
    }
    
    if (btnMask_Center.x >= self_Center.x && btnMask_Center.y >= self_Center.y) {
        
        
        [_arrwoView setImage:[UIImage imageNamed:@"right_down"]];
        
        _arrwoView.right = _btnMaskView.center.x;
        _arrwoView.bottom = _btnMaskView.top - 8;
        
        _tipsLabel.right = _arrwoView.left - 6;
        _tipsLabel.bottom = _arrwoView.top + 10;
        
        _okBtn.centerX = self.width/2;
        _okBtn.bottom = _tipsLabel.top - 80;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self next];
}

//将button和view传入，使用泛型可以增加
- (void)showInView:(UIView *)view maskBtns:(NSArray <UIView *>*)btns withTips:(NSArray <NSString *>*)tipsArr{
    //有效减少创建内存大小，以后用上
    NSMutableArray *rects = [NSMutableArray arrayWithCapacity:btns.count];
    for (int i = 0; i < [btns count]; i++) {
        UIView *btn = btns[i];
        CGRect btnMaskRect = btn.frame;
        //round  如果参数是小数  则求本身的四舍五入.
        //ceil   如果参数是小数  则求最小的整数但不小于本身.
        //floor  如果参数是小数  则求最大的整数但不大于本身.
        btnMaskRect.size = CGSizeMake(floor(btnMaskRect.size.width + 10), floor(btnMaskRect.size.height + 10));
        btnMaskRect.origin = CGPointMake(floor(btnMaskRect.origin.x - 5), floor(btnMaskRect.origin.y - 5));
    //添加rect到数组中，注意rect并不是对象，不能直接存进去，只能换成NSValue
        [rects addObject:[NSValue valueWithCGRect:btnMaskRect]];
    }
    //将rect信息放入到tips中
    [self showInView:view maskRects:rects withTips:tipsArr];
}

- (void)showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr{
    self.rectsArr = rects;
    self.tipsArr = [NSMutableArray arrayWithArray:tipsArr];
    if ([rects count] > [tipsArr count]){
        self.tipsArr = [NSMutableArray arrayWithArray:tipsArr];
        NSInteger delta = rects.count - tipsArr.count;
        //哈哈哈
        for (int i= 0; i<delta; i++) {
            [self.tipsArr addObject:@"老哥, 加个tips啊"];
        }
    }
    //取出其中的第一个tip
    self.tipsStr = [self.tipsArr firstObject];
    //将传入的
    self.parentView = view;
    CGRect firstRect = [[rects firstObject] CGRectValue];
    self.maskRect = firstRect;
    self.alpha = 0;
    [view addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:nil];
}



- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)next{
    
    self.index++;
    if (self.index >= self.rectsArr.count) {
        [self dismiss];
    }else{
        self.tipsStr = self.tipsArr[self.index];
        self.maskRect = [self.rectsArr[self.index] CGRectValue];
        [self layoutSubviews];
    }
}

#pragma mark - getter and setter

- (UIButton *)okBtn {
    if (!_okBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"okBtn"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        _okBtn = btn;
    }
    return _okBtn;
}

- (UIImageView *)btnMaskView {
    if (!_btnMaskView) {
        UIImage *image = [UIImage imageNamed:@"whiteMask"];
        image = [image maskImage:[[UIColor blackColor] colorWithAlphaComponent:0.71]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        _btnMaskView = imageView;
    }
    return _btnMaskView;
}

- (UIImageView *)arrwoView {
    if (!_arrwoView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_down"]];
        _arrwoView = imageView;
    }
    return _arrwoView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        UILabel *tipsLabel = [[UILabel alloc] init];
        tipsLabel.text = @"";
        tipsLabel.numberOfLines = 0;
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.font = [UIFont systemFontOfSize:14];
        [tipsLabel sizeToFit];
        _tipsLabel = tipsLabel;
        
    }
    return _tipsLabel;
}

- (UIView *)topMaskView {
    if (!_topMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.71];
        _topMaskView = view;
    }
    return _topMaskView;
}

- (UIView *)bottomMaskView {
    if (!_bottomMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.71];
        _bottomMaskView = view;
    }
    return _bottomMaskView;
}

- (UIView *)leftMaskView {
    if (!_leftMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.71];
        _leftMaskView = view;
    }
    return _leftMaskView;
}

- (UIView *)rightMaskView {
    if (!_rightMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.71];
        _rightMaskView = view;
    }
    return _rightMaskView;
}

- (NSArray *)rectsArr{
    if (!_rectsArr) {
        _rectsArr = [NSArray array];
    }
    return _rectsArr;
}

- (NSMutableArray *)tipsArr{
    if (!_tipsArr) {
        _tipsArr = [NSMutableArray array];
    }
    return _tipsArr;
}
@end

