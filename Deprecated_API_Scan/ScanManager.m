//
//  ScanManager.m
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/12.
//  Copyright © 2020 李扬. All rights reserved.
//

#import "ScanManager.h"
#import "XcodeBuildUtil.h"

@implementation ScanManager

+ (void)start
{
//    NSError *error = nil;
//    NSRegularExpression *regexTempChildValue = [NSRegularExpression
//                                                regularExpressionWithPattern:@"^(.+:[0-9]+:[0-9]+):.(error|warning):\\s+('(.+)'\\s+is\\s+deprecated:.+instead)"
//                                                options:0
//                                                error:&error];
//    NSString *str = @"/Users/liyang/git/company/maimai/maimai_react_native/maimai_ios/Important/Util/NTUtilities.h:124:32: warning: 'UIActionSheet' is deprecated: first deprecated in iOS 8.3 - UIActionSheet is deprecated. Use UIAlertController with a preferredStyle of UIAlertControllerStyleActionSheet instead [-Wdeprecated-declarations]";
//    [regexTempChildValue enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult * _Nullable lineResult, NSMatchingFlags flags, BOOL * _Nonnull stop) {
//        NSString *string = str;
//        NSLog(@"");
//
//    }];
    
    // 首先clean
    [XcodeBuildUtil clean];
    
    // 编译
    [XcodeBuildUtil build:^(NSString *line) {
        
    } finished:^{
        
    }];
    
    // 要自己维护 runloop
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];
}

@end
