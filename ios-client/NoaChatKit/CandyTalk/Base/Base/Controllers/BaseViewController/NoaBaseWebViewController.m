//
//  NoaBaseWebViewController.m
//  NoaKit
//
//  Created by Candy on 2026/9/20.
//

//当前网页加载类型
typedef NS_ENUM(NSUInteger, CurrentLoadType) {
    CurrentLoadTypeNormal = 1,      //网址正常浏览(http开头)
    CurrentLoadTypeHttp = 2,        //网址手动拼接http
    CurrentLoadTypeHttps = 3,       //网址手动拼接https
};

#import "NoaBaseWebViewController.h"
#import "NoaMessageAlertView.h"

@interface NoaBaseWebViewController ()<WKNavigationDelegate,WKUIDelegate>
//进度条
@property (nonatomic, strong) UIProgressView *viewProgress;
//当前网页加载类型
@property (nonatomic, assign) CurrentLoadType currentLoadType;

@end

@implementation NoaBaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentLoadType = CurrentLoadTypeNormal;
    
    self.navTitleStr = self.webViewTitle;
    [self setupWebView];
    [self setProgressView];
    [self webViewLoad];
    
    if ([NSString isNil:self.navTitleStr]) {
        //网页标题监听
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];        
    }
    //进度条监听
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setupWebView {
    //网页配置
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    config.allowsInlineMediaPlayback = YES;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH, DScreenWidth, DScreenHeight - DNavStatusBarH - DHomeBarH) configuration:config];
    //导航代理(处理加载，跳转等)
    self.webView.navigationDelegate = self;
    //UI代理(处理JS脚本等交互)
    self.webView.UIDelegate = self;//目前需求暂时用不到
    //是否允许手势左滑返回上一级, 类似导航控制的左滑返回
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
}

- (void)setProgressView {
    //进度条
    _viewProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH, DScreenWidth, 1)];
    _viewProgress.tkThemeTrackTintColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    _viewProgress.tkThemetintColors = @[COLOR_CLEAR, COLOR_CLEAR];
    _viewProgress.hidden = YES;
    [self.view addSubview:_viewProgress];
}

- (void)webViewLoad {
    if (!_webViewUrl) {
        return;
    }

    NSString *webRequestUrl = self.webViewUrl;
    switch (_currentLoadType) {
        case CurrentLoadTypeHttp:
        {
            //此时说明手动拼接http不能加载成功，改用https重新加载一次
            webRequestUrl = [self checkWebUrlForHTTPS:self.webViewUrl];
        }
            break;
            
        default:
        {
            //默认都是走http
            webRequestUrl = [self checkWebUrlForHTTP:self.webViewUrl];
        }
            break;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webRequestUrl]];
    //[NSMutableURLRequest requestWithURL:[NSURL URLWithString:webRequestUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    
    //Cookie
    [request addValue:[self readCurrentCookieWithDomain:webRequestUrl] forHTTPHeaderField:@"Cookie"];
    
    //网页加载
    [self.webView loadRequest:request];
}

//解决第一次进入的cookie丢失问题
- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString * cookieString = [[NSMutableString alloc]init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }
    //删除最后一个“;”
    if ([cookieString hasSuffix:@";"]) {
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    }
    return cookieString;
}

//解决 页面内跳转（a标签等）还是取不到cookie的问题
- (void)getCookie{
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [self.webView evaluateJavaScript:JSCookieString completionHandler:nil];
}
#pragma mark -- WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
    [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark -- WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    DLog(@"webView：开始加载...");
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    DLog(@"webView：失败原因:%@", error.userInfo);
    if (_currentLoadType == CurrentLoadTypeHttp) {
        //重新拼接https加载一次
        [self webViewLoad];
    }
    [HUD showMessage:LanguageToolMatch(@"加载失败")];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    DLog(@"webView：内容开始返回");
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    DLog(@"webView：页面加载完成");
    
    [self getCookie];
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    DLog(@"webView：提交发生错误");
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    DLog(@"webView：接收到 服务器跳转请求 即 服务重定向");
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL *url = navigationAction.request.URL;
    if ([NSString isNil:[url absoluteString]]) {
        return;
    }
    
    WeakSelf
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableURLRequest *headRequest = [NSMutableURLRequest requestWithURL:url];
    headRequest.HTTPMethod = @"HEAD";
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:headRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        StrongSelf
        if (error) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.allHeaderFields != nil && [httpResponse.allHeaderFields.allKeys containsObject:@"Content-Disposition"]) {
                NSString *contentDisposition = (NSString *)httpResponse.allHeaderFields[@"Content-Disposition"];
                if (![NSString isNil:contentDisposition] && [contentDisposition containsString:@"attachment"]) {
                    // 处理下载操作
                    NSString *urlString = navigationAction.request.URL.absoluteString;
                    [ZTOOL doInMain:^{
                        [strongSelf webDownloadFileAlert:urlString];
                    }];
                    decisionHandler(WKNavigationActionPolicyCancel);
                } else {
                    //不需要下载文件
                    decisionHandler(WKNavigationActionPolicyAllow);
                }
            } else {
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    DLog(@"当前跳转地址：%@",urlStr);
    self.currentUrlStr = urlStr;
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

// https验证
-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    //判断服务器采用的验证方法
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        if (challenge.previousFailureCount ==0) {
            //如果没有错误的情况下，创建一个凭证，并使用证书
            NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, card);
        }else {
            //验证失败，取消本次验证
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
        
    }else {
        //取消本次验证
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
    
}

#pragma mark - KVO监听函数
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //网页标题
    if ([keyPath isEqualToString:@"title"]) {
        self.navTitleStr = self.webView.title;
    }
    //网页进度条
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1.0) {
            _viewProgress.hidden = YES;
            [_viewProgress setProgress:0 animated:NO];
        }else {
            _viewProgress.hidden = NO;
            [_viewProgress setProgress:newprogress animated:YES];
        }
    }
}

//网址配置http开头
- (NSString *)checkWebUrlForHTTP:(NSString *)webUrl {
    if (webUrl.length > 0) {
        NSRange tempRange = [webUrl rangeOfString:@"://"];
        if (tempRange.location == NSNotFound) {
            _currentLoadType = CurrentLoadTypeHttp;
            
            return [NSString stringWithFormat:@"http://%@", webUrl];
        }else {
            NSString *scheme = [webUrl safeSubstringWithRange:NSMakeRange(0, tempRange.location)];
            assert((scheme != nil));
            if ([scheme compare:@"http" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return webUrl;
            }else if ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return webUrl;
            }else {
                [HUD showMessage:LanguageToolMatch(@"加载失败")];
                return nil;
            }
        }
        
    }else {
        [HUD showMessage:LanguageToolMatch(@"加载失败")];
        return nil;
    }
}

//网址配置https开头
- (NSString *)checkWebUrlForHTTPS:(NSString *)webUrl {
    if (webUrl.length > 0) {
        NSRange tempRange = [webUrl rangeOfString:@"://"];
        if (tempRange.location == NSNotFound) {
            _currentLoadType = CurrentLoadTypeHttps;
            
            return [NSString stringWithFormat:@"https://%@", webUrl];
        }else {
            NSString *scheme = [webUrl safeSubstringWithRange:NSMakeRange(0, tempRange.location)];
            assert((scheme != nil));
            if ([scheme compare:@"http" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return webUrl;
            }else if ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return webUrl;
            }else {
                [HUD showMessage:LanguageToolMatch(@"加载失败")];
                return nil;
            }
        }
        
    }else {
        [HUD showMessage:LanguageToolMatch(@"加载失败")];
        return nil;
    }
}

- (void)webDownloadFileAlert:(NSString *)urlString {
    WeakSelf
    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    msgAlertView.lblTitle.text = LanguageToolMatch(@"提示");
    msgAlertView.lblContent.text = LanguageToolMatch(@"去外部浏览器下载文件？");
    msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"在浏览器打开") forState:UIControlStateNormal];
    [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
    msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F5F6F9_DARK];
    [msgAlertView alertShow];
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        [weakSelf openSafariWithURL:urlString];
    };
}

- (void)openSafariWithURL:(NSString *)urlString {
   NSURL *url = [NSURL URLWithString:urlString];
   if ([[UIApplication sharedApplication] canOpenURL:url]) {
       [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
           if (success) {
               NSLog(@"Opened %@", urlString);
           } else {
               NSLog(@"Failed to open %@", urlString);
           }
       }];
   } else {
       NSLog(@"Can't open %@", urlString);
   }
}


- (void)dealloc {
    if ([NSString isNil:self.navTitleStr]) {
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
