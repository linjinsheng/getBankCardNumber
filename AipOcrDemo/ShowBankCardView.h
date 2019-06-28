//
//  ShowBankCardView.h
//  AipOcrDemo
//
//  Created by eddy_Mac on 2019/5/8.
//  Copyright © 2019年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

@interface ShowBankCardView : UIView

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, copy)   NSString *bankCard;
@property (nonatomic, strong) UIImage *bankCardImage;

@property (nonatomic, copy) void (^sureHander)(void);

+ (void)showBankCardWithBankCard:(NSString *)bankCard
                   bankCardImage:(UIImage *)bankCardImage
                 btnEventHandler:(void(^)(void))handler;

@end
