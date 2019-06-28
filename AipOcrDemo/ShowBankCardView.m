//
//  ShowBankCardView.m
//  AipOcrDemo
//
//  Created by eddy_Mac on 2019/5/8.
//  Copyright © 2019年 Baidu. All rights reserved.
//

#import "ShowBankCardView.h"

@interface CardNumberItem : UIView

@property (nonatomic, strong) UILabel *cardNumberLb;

@property (nonatomic, strong) UIView *line;

@end

@implementation CardNumberItem

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self line];
    }
    return self;
}

- (UILabel *)cardNumberLb
{
    if (_cardNumberLb == nil)
    {
        _cardNumberLb = [[UILabel alloc] init];
        _cardNumberLb.textAlignment = NSTextAlignmentCenter;
        _cardNumberLb.font = [UIFont systemFontOfSize:16];
        
        [self addSubview:_cardNumberLb];
        
        [_cardNumberLb makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
        }];
    }
    
    return _cardNumberLb;
}

- (UIView *)line
{
    if (_line == nil)
    {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor lightGrayColor];
        
        [self addSubview:_line];
        
        [_line makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cardNumberLb.bottom).offset(10);
            make.left.right.equalTo(self);
            make.height.equalTo(1);
        }];
    }
    
    return _line;
}

@end


@interface ShowBankCardView ()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *titleLb;

@property (nonatomic, strong) UIImageView *cardImageView;

@property (nonatomic, strong) UIView *cardNumberBox;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *sureButton;

@end

@implementation ShowBankCardView

+ (void)showBankCardWithBankCard:(NSString *)bankCard bankCardImage:(UIImage *)bankCardImage btnEventHandler:(void (^)(void))handler
{
    ShowBankCardView *cardView = [[ShowBankCardView alloc] init];
    cardView.sureHander = handler;
    cardView.bankCard = bankCard;
    cardView.bankCardImage = bankCardImage;
    
    cardView.titleLb.text = @"请核对卡号信息，确认无误";
    cardView.cardImageView.image = bankCardImage;
    
    cardView.frame = [UIScreen mainScreen].bounds;
    cardView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    [cardView closeButton];
    [cardView sureButton];
    
    [cardView show];
}

- (void)setBankCard:(NSString *)bankCard
{
    NSString *first  = [bankCard substringToIndex:6];
    NSString *middle = [bankCard substringWithRange:NSMakeRange(6, 6)];
    NSString *last = [bankCard substringFromIndex:12];

    NSMutableArray *items = [NSMutableArray array];
    
    CardNumberItem *item1 = [[CardNumberItem alloc] init];
    item1.cardNumberLb.text = first;
    
    CardNumberItem *item2 = [[CardNumberItem alloc] init];
    item2.cardNumberLb.text = middle;
    
    CardNumberItem *item3 = [[CardNumberItem alloc] init];
    item3.cardNumberLb.text = last;
    
    [self.cardNumberBox addSubview:item1];
    [self.cardNumberBox addSubview:item2];
    [self.cardNumberBox addSubview:item3];
    
    [items addObjectsFromArray:@[item1,item2,item3]];
    
    [items mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:0 tailSpacing:0];
    [items makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.cardNumberBox);
    }];
}

- (UIView *)containerView
{
    if (_containerView == nil)
    {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:_containerView];
        
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(30);
            make.right.equalTo(self).offset(-30);
        }];
    }
    
    return _containerView;
}

- (UIButton *)closeButton
{
    if (_closeButton == nil)
    {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(onCloseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.containerView addSubview:_closeButton];
        
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView).offset(15);
            make.right.equalTo(self.containerView).offset(-15);
            make.size.equalTo(CGSizeMake(30, 30));
        }];
    }
    
    return _closeButton;
}

- (UILabel *)titleLb
{
    if (_titleLb == nil)
    {
        _titleLb = [[UILabel alloc] init];
     
        [self.containerView addSubview:_titleLb];
        
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.containerView).offset(20);
            make.right.equalTo(self.containerView).offset(-20);
        }];
    }
    
    return _titleLb;
}

- (UIImageView *)cardImageView
{
    if (_cardImageView == nil)
    {
        _cardImageView = [[UIImageView alloc] init];
     
        [self.containerView addSubview:_cardImageView];
        
        [_cardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLb.bottom).offset(20);
            make.left.right.equalTo(self.titleLb);
            make.height.greaterThanOrEqualTo(40);
        }];
    }
    
    return _cardImageView;
}

- (UIView *)cardNumberBox
{
    if (_cardNumberBox == nil)
    {
        _cardNumberBox = [[UIView alloc] init];
        
        [self.containerView addSubview:_cardNumberBox];
        
        [_cardNumberBox mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cardImageView.bottom).offset(20);
            make.left.right.equalTo(self.cardImageView);
            make.size.equalTo(CGSizeMake(46, 46));
        }];
    }
    
    return _cardNumberBox;
}

- (UIButton *)sureButton
{
    if (_sureButton == nil)
    {
        _sureButton = [[UIButton alloc] init];
        _sureButton.layer.cornerRadius = 25;
        _sureButton.layer.masksToBounds = YES;
        [_sureButton setTitle:@"确认" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _sureButton.backgroundColor = [UIColor yellowColor];
        [_sureButton addTarget:self action:@selector(onCloseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.containerView addSubview:_sureButton];
        
        [_sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cardNumberBox.bottom).offset(10);
            make.left.equalTo(self.containerView).offset(15);
            make.right.equalTo(self.containerView).offset(-15);
            make.height.equalTo(50);
            make.bottom.equalTo(self.containerView).offset(-15);
        }];
    }
    
    return _sureButton;
}


- (void)onCloseButtonClick:(UIButton *)sender
{
    [self hide];
}

- (void)show
{
    if (![self judgeShowCondition])
    {
        return;
    }
    
    self.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;

    } completion:^(BOOL finished) {

        [self removeFromSuperview];
        
        if (self.sureHander != nil)
        {
            self.sureHander();
        }
    }];
    
    self.isShowing = NO;
}


- (UINavigationController *)currentNavigationController
{
    UINavigationController *navigationController = nil;
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if ([controller isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)controller;
        controller = tabBarController.viewControllers[tabBarController.selectedIndex];
        
        if ([controller isKindOfClass:[UINavigationController class]])
        {
            navigationController = (UINavigationController *)controller;
        }
    }
    
    while (controller.presentedViewController != nil)
    {
        controller = controller.presentedViewController;
        
        if ([controller isKindOfClass:[UINavigationController class]])
        {
            navigationController = (UINavigationController *)controller;
        }
    }
    
    
    return navigationController;
}

/** 判断显示条件，如果有其他视图正在显示就不弹出 */
- (BOOL)judgeShowCondition
{
    if (_isShowing)
    {
        return NO;
    }
    
    self.isShowing = YES;
    
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if ([rootController.presentedViewController isKindOfClass:[UIAlertController class]])
    {
        return NO;
    }
    
    UINavigationController *curNavi = [self currentNavigationController];

    if ([curNavi isBeingPresented])
    {
        return NO;
    }
    
    for (UIView *subview in [UIApplication sharedApplication].keyWindow.subviews)
    {
        if ([subview isKindOfClass:[ShowBankCardView class]])
        {
            return NO;
        }
    }
    
    return YES;
    
}

@end
