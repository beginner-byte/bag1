//
//  NoaChatKitUITests.m
//  NoaChatKitUITests
//
//  Created by Apple on 2026/8/9.
//

#import <XCTest/XCTest.h>

@interface NoaChatKitUITests : XCTestCase

@end

@implementation NoaChatKitUITests

/// 页面迁移回归遇到首个失败即停止，保留最接近根因的截图和元素树。
- (void)setUp {
    self.continueAfterFailure = NO;
}

/// 启动已登录应用并验证“我的”及 Swift 团队列表页面能够进入。
- (void)testMineAndTeamPages {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    XCTAssertTrue([app waitForState:XCUIApplicationStateRunningForeground timeout:20]);

    XCUIElement *minePage = app.otherElements[@"cohere.mine"];
    if (![minePage waitForExistenceWithTimeout:3]) {
        NSArray<XCUIElement *> *mineCandidates = @[
            app.tabBars.buttons[@"我的"],
            app.buttons[@"我的"],
            app.staticTexts[@"我的"]
        ];
        for (XCUIElement *candidate in mineCandidates) {
            if (candidate.exists && candidate.isHittable) {
                [candidate tap];
                break;
            }
        }
    }
    XCTAssertTrue([minePage waitForExistenceWithTimeout:10],
                  @"未进入 Swift“我的”页面，请确认测试账号已登录");
    [self attachScreenshotNamed:@"我的页面"];

    XCUIElement *teamEntry = app.staticTexts[@"我的团队"];
    XCTAssertTrue([teamEntry waitForExistenceWithTimeout:5], @"“我的团队”入口缺失");
    [teamEntry tap];

    XCUIElement *teamPage = app.otherElements[@"cohere.team.list"];
    XCTAssertTrue([teamPage waitForExistenceWithTimeout:10], @"未进入 Swift 团队列表页面");
    XCTAssertTrue(app.staticTexts[@"我的团队"].exists, @"团队列表标题缺失");
    [self attachScreenshotNamed:@"团队列表页面"];
}

/// 把当前屏幕附加到测试结果，便于核对 Figma 布局和真机状态。
/// - Parameter name: 测试结果中显示的中文截图名称。
- (void)attachScreenshotNamed:(NSString *)name {
    XCUIScreenshot *screenshot = XCUIScreen.mainScreen.screenshot;
    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:screenshot];
    attachment.name = name;
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
