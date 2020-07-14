//
//  ScanManager.m
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/12.
//  Copyright © 2020 李扬. All rights reserved.
//

#import "ScanManager.h"

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
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"-c", @"xcodebuild build -workspace /Users/liyang/git/company/maimai/maimai_react_native/maimai_ios/NeiTui.xcworkspace -scheme NeiTui -configuration Debug", nil];
    [task setArguments: arguments];

    NSPipe *p = [NSPipe pipe];
    [task setStandardOutput:p];
    NSFileHandle *fh = [p fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:NSFileHandleDataAvailableNotification object:fh];

    [task launch];
    
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];

}

+ (void)receivedData:(NSNotification *)notif {
    NSFileHandle *fh = [notif object];
    NSData *data = [fh availableData];
    if (data.length > 0) { // if data is found, re-register for more data (and print)
        [fh waitForDataInBackgroundAndNotify];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@" ,str);
        if ([str containsString:@"BUILD SUCCEEDED"]) {
            NSLog(@"\n\n\n\n============== 结束");
        }
//        printf("%s", [str UTF8String]);
    }
}

@end
