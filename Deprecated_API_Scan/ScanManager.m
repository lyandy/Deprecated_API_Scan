//
//  ScanManager.m
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/12.
//  Copyright © 2020 李扬. All rights reserved.
//

#import "ScanManager.h"
#import "XcodeBuildUtil.h"
#import "DocsExport.h"

@implementation ScanManager

+ (void)startViaOutput
{
    
//    NSString *str = @"/Users/liyang/git/company/maimai/maimai_react_native/maimai_ios/Important/Util/NTUtilities.h:124:32: warning: 'UIActionSheet' is deprecated: first deprecated in iOS 8.3 - UIActionSheet is deprecated. Use UIAlertController with a preferredStyle of UIAlertControllerStyleActionSheet instead [-Wdeprecated-declarations]";
    
//    NSString *str = [NSString stringWithContentsOfFile:@"/Users/liyang/Desktop/1/1.txt" encoding:NSUTF8StringEncoding error:nil];
//
//    [DocsExport pushBuildLine:str];

    // 首先clean
    [XcodeBuildUtil syncClean];

    // 编译
    [XcodeBuildUtil asyncBuild:^(NSString *line) {
        printf("===> %s", [line UTF8String]);
        [DocsExport pushBuildContent:line];
    } finished:^{
        printf("------->完成");
        [DocsExport export2File];
    }];
    
    // 由于是 async 要自己维护 runloop
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];
}

+ (void)startViaContent
{
    // 首先clean
    printf("---> xcodebuild clean \n");
    [XcodeBuildUtil syncClean];
    
    // build
    printf("---> xcodebuild build 此过程大约持续5~8分钟，请耐心等候... \n");
    NSString *content = [XcodeBuildUtil syncBuild];
//    NSString *content = [NSString stringWithContentsOfFile:@"/Users/liyang/Desktop/1/1.txt" encoding:NSUTF8StringEncoding error:nil];
    
    // regex
    printf("---> DocsExport regex start \n");
    [DocsExport pushBuildContent:content];
    
    // export
    printf("---> DocsExport writeToFile start \n");
    [DocsExport export2File];
}

@end
