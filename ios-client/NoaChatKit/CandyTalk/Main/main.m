//
//  main.m
//  NoaKit
//
//  Created by Apple on 2026/8/9.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    if([[NSThread currentThread] isMainThread]){
        [MMKV initializeMMKV:nil];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [MMKV initializeMMKV:nil];
        });
    }
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
