//
//  XcodeBuildUtil.m
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/14.
//  Copyright © 2020 李扬. All rights reserved.
//

#import "XcodeBuildUtil.h"
#import "TaskPipe.h"

#define WORKSPACE @"/Users/liyang/git/company/maimai/maimai_react_native/maimai_ios/NeiTui.xcworkspace"
#define SCHEME @"NeiTui"
#define CONFIGURATION @"Debug"

@implementation XcodeBuildUtil

+ (NSString *)clean
{
    // clean build command
    NSString *cmd = [NSString stringWithFormat:@"xcodebuild clean -workspace %@ -scheme %@ -configuration %@", WORKSPACE, SCHEME, CONFIGURATION];
    
    return [TaskPipe runCommand:cmd];
}

+ (void)build:(void (^)(NSString *))output finished:(void (^)(void))finished
{
    // Debug build command
    NSString *cmd = [NSString stringWithFormat:@"xcodebuild build -workspace %@ -scheme %@ -configuration %@", WORKSPACE, SCHEME, CONFIGURATION];
    
    [TaskPipe runCommandWaitForDataInBackgroundAndNotify:cmd output:^(NSString *line) {
        output == nil ?: output(line);
        
        if ([line containsString:@"BUILD SUCCEEDED"])
        {
            finished == nil ?: finished();
        }
    }];
}

@end
