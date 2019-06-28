//
//  ViewController.m
//  AipOcrDemo
//
//  Created by chenxiaoyu on 17/2/7.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <AipOcrSdk/AipOcrSdk.h>
#import "ShowBankCardView.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<NSArray<NSString *> *> *actionList;

@end

@implementation ViewController {
    // 默认的识别成功的回调
    void (^_successHandler)(id);
    // 默认的识别失败的回调
    void (^_failHandler)(NSError *);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    #error 【必须！】请在 ai.baidu.com中新建App, 绑定BundleId后，在此填写授权信息
    //    #error 【必须！】上传至AppStore前，请使用lipo移除AipBase.framework、AipOcrSdk.framework的模拟器架构，参考FAQ：ai.baidu.com/docs#/OCR-iOS-SDK/top
    //     授权方法1：在此处填写App的Api Key/Secret Key
    
    //    API Key   tqr99OMd8ioO54x9Df7lGWkS
    //    Secret Key   bzOT3EI3dqyikwDI5eretj0y9q6yYZYe
    
    
    [[AipOcrService shardService] authWithAK:@"TwWXBRMjOphxP0axV6BGjgV8" andSK:@"3Kjmcih1wlF7INGgY6MG1s4M1uuy7Nyo"];
    
    
    // 授权方法2（更安全）： 下载授权文件，添加至资源
    //    NSString *licenseFile = [[NSBundle mainBundle] pathForResource:@"aip" ofType:@"license"];
    //    NSData *licenseFileData = [NSData dataWithContentsOfFile:licenseFile];
    //    if(!licenseFileData) {
    //        [[[UIAlertView alloc] initWithTitle:@"授权失败" message:@"授权文件不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    //    }
    //    [[AipOcrService shardService] authWithLicenseFileData:licenseFileData];
    
    
    [self configureView];
    [self configureData];
    [self configCallback];
}

- (void)configureView {
    
    self.title = @"百度OCR";
}

- (void)configureData {
    
    self.actionList = [NSMutableArray array];
    [self.actionList addObject:@[@"银行卡正面拍照识别", @"bankCardOCROnline"]];
    
    [_tableView reloadData];
}

- (void)bankCardOCROnline
{
    UIViewController * vc = [AipCaptureCardVC ViewControllerWithCardType:CardTypeBankCard andImageHandler:^(UIImage *image) {
        [self showCardImage:image];
    }];
    
    // 打印出识别结果
    //    NSLog(@"银行卡的_successHandler为%@", _successHandler);
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)showCardImage:(UIImage *)cardImage
{
    [[AipOcrService shardService] detectBankCardFromImage:cardImage successHandler:^(id result) {
        
        NSString *card = result[@"result"][@"bank_card_number"];
        card = [card stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [[AipOcrService shardService] detectTextAccurateFromImage:cardImage withOptions:nil successHandler:^(id result) {
            
            NSArray *locas = result[@"words_result"];
            
            for (NSDictionary *d in locas)
            {
                NSDictionary *locaD = d[@"location"];
                
                NSLog(@"locaD==>>%@:%@",d[@"words"],locaD);
                
                if ([card isEqualToString:d[@"words"]])
                {
                    
                    CGFloat x = [locaD[@"left"] floatValue];
                    CGFloat y = [locaD[@"top"] floatValue];
                    CGFloat width = [locaD[@"width"] floatValue];
                    CGFloat height = [locaD[@"height"] floatValue];
                    
                    if (_successHandler != nil)
                    {
                        _successHandler(result);
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [ShowBankCardView showBankCardWithBankCard:card bankCardImage:[self imageByCroppingWithImage:cardImage cropRect:CGRectMake(x, y, width, height)] btnEventHandler:nil];
                    });
                    
                }
            }
            
        } failHandler:nil];
        
    } failHandler:_failHandler];
}

- (void)configCallback {
    __weak typeof(self) weakSelf = self;
    // 这是默认的识别成功的回调
    _successHandler = ^(id result){
        
        NSLog(@"默认的识别成功的回调为%@", result);
        NSLog(@"默认的识别成功的回调log_id为%@", result[@"log_id"]);
        NSLog(@"默认的识别成功的回调result为%@", result[@"result"]);
        NSLog(@"默认的识别成功的回调bank_card_number为%@", result[@"result"][@"bank_card_number"]);
        NSLog(@"默认的识别成功的回调bank_name为%@", result[@"result"][@"bank_name"]);
        NSString *title = @"识别结果";
        NSMutableString *message = [NSMutableString string];

        if(result[@"words_result"]){
            if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
                [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@: %@\n", key, obj];
                    }

                }];
            }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
                for(NSDictionary *obj in result[@"words_result"]){
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@\n", obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@\n", obj];
                    }

                }
            }

        }else{
            [message appendFormat:@"%@", result];

        }

//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alertView show];
//        }];
        
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    UIViewController *topRootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
                    
                    // 在这里加一个这个样式的循环
                    while (topRootViewController.presentedViewController)
                    {
                        // 这里固定写法
                        topRootViewController = topRootViewController.presentedViewController;
                    }
                    
                    [topRootViewController dismissViewControllerAnimated:YES completion:^{
                        NSLog(@"bankPhotoPicker退出");
                    }];
                }];
    };
    
    _failHandler = ^(NSError *error){
        NSLog(@"%@", error);
        NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[error code], [error localizedDescription]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[[UIAlertView alloc] initWithTitle:@"识别失败" message:msg delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }];
    };
}


//剪裁图片
- (UIImage*)imageByCroppingWithImage:(UIImage *)myImage cropRect:(CGRect)cropRect
{
    CGRect rect = cropRect;
    rect.origin.x = myImage.scale * rect.origin.x - 10;
    rect.origin.y = myImage.scale * rect.origin.y - 15;
    rect.size.width = myImage.scale * rect.size.width + 20;
    rect.size.height = myImage.scale * rect.size.height + 30;
    
    CGImageRef imageRef = myImage.CGImage;
    CGImageRef imagePartRef=CGImageCreateWithImageInRect(imageRef,rect);
    UIImage * cropImage=[UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    
    return cropImage;
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.actionList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    NSArray *actions = self.actionList[indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:@"DemoActionCell" forIndexPath:indexPath];
    cell.textLabel.text = actions[0];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 55;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SEL funSel = NSSelectorFromString(self.actionList[indexPath.row][1]);
    if (funSel) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:funSel];
#pragma clang diagnostic pop
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
