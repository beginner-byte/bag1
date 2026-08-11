//
//  NoaCaptchaCodeTools.m
//  NoaKit
//
//  Created by Candy on 2024/7/23.
//

#import "NoaCaptchaCodeTools.h"
#import <WebKit/WebKit.h>

@interface NoaCaptchaCodeTools() <WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation NoaCaptchaCodeTools

- (void)verCaptchaCode {
    if (self.webView == nil) {
        // 创建 WebView 配置对象
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        if (ZHostTool.appSysSetModel.captchaChannel == 3) {
            //腾讯云
            [configuration.userContentController addScriptMessageHandler:self name:@"iosJSBridge"];
        }
        if (ZHostTool.appSysSetModel.captchaChannel == 4) {
            //阿里云
            [configuration.userContentController addScriptMessageHandler:self name:@"getVerifyResult"];
            [configuration.userContentController addScriptMessageHandler:self name:@"closeWebView"];
        }
        
        WKPreferences *preference = [[WKPreferences alloc]init];
        preference.javaScriptEnabled = YES;      //设置是否支持 javaScript 默认是支持的
        preference.javaScriptCanOpenWindowsAutomatically = YES; // 在 iOS 上默认为 NO，表示是否允许不经过用户交互由 javaScript 自动打开窗口
        configuration.preferences = preference;

        
        // 创建和配置 WebView
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        self.webView.frame = CGRectMake(0, 0, 0, 0);
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.opaque = NO;
        self.webView.clipsToBounds = YES;
        self.webView.scrollView.backgroundColor = [UIColor clearColor];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.webView.userInteractionEnabled = YES;
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        // 将 WebView 添加到视图中，并设置布局约束
        [CurrentWindow addSubview:self.webView];
    }
    // 加载本地 HTML
    if (ZHostTool.appSysSetModel.captchaChannel == 3) {
        //腾讯云
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"noa_captcha_tx" withExtension:@"html"];
        [self.webView loadFileURL:htmlURL allowingReadAccessToURL:htmlURL];
    }
    if (ZHostTool.appSysSetModel.captchaChannel == 4) {
        //阿里云
        self.aliyunVerNum += 1;
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"noa_captcha_alione" withExtension:@"html"];
        [self.webView loadFileURL:htmlURL allowingReadAccessToURL:htmlURL];
    }
}

//阿里云 二次验证
- (void)secondVerCaptchaCode {
    if (self.webView == nil) {
        // 创建 WebView 配置对象
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        if (ZHostTool.appSysSetModel.captchaChannel == 3) {
            //腾讯云
            [configuration.userContentController addScriptMessageHandler:self name:@"iosJSBridge"];
        }
        if (ZHostTool.appSysSetModel.captchaChannel == 4) {
            //阿里云
            [configuration.userContentController addScriptMessageHandler:self name:@"getVerifyResult"];
            [configuration.userContentController addScriptMessageHandler:self name:@"closeWebView"];
        }
        
        WKPreferences *preference = [[WKPreferences alloc]init];
        preference.javaScriptEnabled = YES;      //设置是否支持 javaScript 默认是支持的
        preference.javaScriptCanOpenWindowsAutomatically = YES; // 在 iOS 上默认为 NO，表示是否允许不经过用户交互由 javaScript 自动打开窗口
        configuration.preferences = preference;

        
        // 创建和配置 WebView
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        self.webView.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.opaque = NO;
        self.webView.clipsToBounds = YES;
        self.webView.scrollView.backgroundColor = [UIColor clearColor];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.webView.userInteractionEnabled = YES;
        self.webView.navigationDelegate = self;
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.UIDelegate = self;
        // 将 WebView 添加到视图中，并设置布局约束
        [CurrentWindow addSubview:self.webView];
    }
    // 加载本地 HTML
    if (ZHostTool.appSysSetModel.captchaChannel == 3) {
        //腾讯云
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"noa_captcha_tx" withExtension:@"html"];
        [self.webView loadFileURL:htmlURL allowingReadAccessToURL:htmlURL];
    }
    if (ZHostTool.appSysSetModel.captchaChannel == 4) {
        //阿里云
        self.aliyunVerNum += 1;
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"noa_captcha_alitwo" withExtension:@"html"];
        [self.webView loadFileURL:htmlURL allowingReadAccessToURL:htmlURL];
    }
    
}

// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面开始加载时调用");
}

// 页面加载失败时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"页面加载失败时调用");
}

// 当内容开始返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"当内容开始返回时调用");
}

// 页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"页面加载完成之后调用");
}

//提交发生错误时调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"提交发生错误时调用");
}

// 接收到服务器跳转请求即服务重定向时之后调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"接收到服务器跳转请求即服务重定向时之后调用");
}

// 实现 WKScriptMessageHandler 的代理方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"接收到无痕验证回调数据");
    NSString *paramStr = message.body;
    NSDictionary *paramDict = [NSString jsonStringToDic:paramStr];
    if (ZHostTool.appSysSetModel.captchaChannel == 3) {
        //腾讯云
        if([message.name isEqualToString:@"iosJSBridge"]){
            //在此处客户端得到js透传数据 并对数据进行后续操作
            NSString *ticket = (NSString *)[paramDict objectForKeySafe:@"ticket"];
            NSString *randstr = (NSString *)[paramDict objectForKeySafe:@"randstr"];
            if (![NSString isNil:ticket] && ![NSString isNil:randstr]) {
                if (self.tencentCaptchaResultSuccess) {
                    self.tencentCaptchaResultSuccess(ticket, randstr);
                }
            } else {
                if (self.captchaResultFail) {
                    self.captchaResultFail();
                }
            }
        }
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
    if (ZHostTool.appSysSetModel.captchaChannel == 4) {
        //阿里云
        if([message.name isEqualToString:@"getVerifyResult"]){
            //在此处客户端得到js透传数据 并对数据进行后续操作
            NSString *captchaVerifyParam = (NSString *)[paramDict objectForKeySafe:@"data"];
            if (![NSString isNil:captchaVerifyParam]) {
                if (self.aliyunCaptchaResultSuccess) {
                    self.aliyunCaptchaResultSuccess(captchaVerifyParam);
                }
            } else {
                if (self.captchaResultFail) {
                    self.captchaResultFail();
                }
            }
            [self.webView removeFromSuperview];
            self.webView = nil;
        }
        if([message.name isEqualToString:@"closeWebView"]){
            [self.webView removeFromSuperview];
            self.webView = nil;
        }
    }
}

@end
