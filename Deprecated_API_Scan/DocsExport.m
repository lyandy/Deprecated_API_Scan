//
//  DocsExport.m
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/14.
//  Copyright © 2020 李扬. All rights reserved.
//

#import "DocsExport.h"

#define EXPORT_FILE_PATH @"/Users/liyang/Downloads"

static NSMutableDictionary *frameworksDictM = nil;
static NSUInteger count = 0;

@implementation DocsExport

+ (void)pushBuildContent:(NSString *)content
{
    static NSRegularExpression *regexValue = nil;
    if (regexValue == nil)
    {
        regexValue = [NSRegularExpression regularExpressionWithPattern:@"(/Users/.+/maimai_ios/.+:[0-9]+:[0-9]+):.(error|warning):\\s+('(.+)'\\s+is\\s+deprecated:.+)\\[" options:0 error:nil];
    }
    
    if (frameworksDictM == nil) { frameworksDictM = [NSMutableDictionary dictionary]; }

    [regexValue enumerateMatchesInString:content options:0 range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable contentResult, NSMatchingFlags flags, BOOL * _Nonnull stop) {
       
        // 检索到的符合规则的整行字符串， 就是line本身
//        NSString *lineStr = [content substringWithRange:[contentResult rangeAtIndex:0]];
        
        // 类标记完整路径，类似这样 /Users/liyang/git/company/maimai/maimai_react_native/maimai_ios/Important/Util/NTUtilities.h:124:32
        NSString *classMarkPathStr = [content substringWithRange:[contentResult rangeAtIndex:1]];
        printf("%lu---> %s  ", (unsigned long)++count, [classMarkPathStr UTF8String]);
        
        // 编译结果类型，error或者warning
//        NSString *compilingMarkStr = [line substringWithRange:[contentResult rangeAtIndex:2]];
        
        // api 过期理由，类似 'UIActionSheet' is deprecated: first deprecated in iOS 8.3 - UIActionSheet is deprecated. Use UIAlertController with a preferredStyle of UIAlertControllerStyleActionSheet instead
        NSString *deprecatedReason = [content substringWithRange:[contentResult rangeAtIndex:3]];
        
        // 过期api，类似 UIActionSheet
        NSString *deprecatedAPI = [content substringWithRange:[contentResult rangeAtIndex:4]];
        
        // 获取对应的 frameworkName 类似 PlatformSDK
        NSRange markRange = [classMarkPathStr rangeOfString:@"maimai_ios"];
        if (markRange.location == NSNotFound) {
            NSLog(@"-=-=-> 出错");
            assert("出错啦");
            return;
        }
        
        // 获取路径后半部分 类似 maimai_ios/Important/Util/SytemAuthorization/MMAlbumAuthHelper.m:126:18
        NSString *classMarkPostStr = [classMarkPathStr substringFromIndex:markRange.location];
        NSArray *classMarkPostArr = [classMarkPostStr componentsSeparatedByString:@"/"];
        if (classMarkPostArr.count < 3) // 至少格式为 maimai_ios/xxx/xxx.class:343:23
        {
            NSLog(@"-=-=-> 出错");
            assert("出错啦");
            return;
        }
        NSString *frameworkName = [classMarkPostStr componentsSeparatedByString:@"/"][1];
        // 获取 classLineOffsetStr 类似 xxx.class:3534:233
        NSString *classLineOffsetStr = classMarkPostArr.lastObject;
        
        // Important 归属为 PlatformSDK
        if ([frameworkName isEqualToString:@"Important"]) { frameworkName = @"PlatformSDK"; }
        
        if (frameworksDictM[frameworkName] == nil)
        {
            frameworksDictM[frameworkName] = [NSMutableDictionary dictionary];
        }
        
        NSMutableDictionary *deprecatedAPIDictM = frameworksDictM[frameworkName];
        if (deprecatedAPIDictM[deprecatedAPI] == nil)
        {
            deprecatedAPIDictM[deprecatedAPI] = [NSMutableDictionary dictionary];
        }
        
        // 组合 mark 和 reason
        NSMutableDictionary *classMarkPostDictM = deprecatedAPIDictM[deprecatedAPI];
        classMarkPostDictM[classLineOffsetStr] = deprecatedReason;
        
        // 组合 api 和 mark
        deprecatedAPIDictM[deprecatedAPI] = classMarkPostDictM;
        // 组合 framework 和 api
        frameworksDictM[frameworkName] = deprecatedAPIDictM;
        
        NSLog(@"");
    }];
    
    NSLog(@"");
}

+ (void)export2File
{
    [frameworksDictM enumerateKeysAndObjectsUsingBlock:^(NSString * frameworkName, NSMutableDictionary *deprecatedAPIDictM, BOOL * _Nonnull stop) {
        
        printf("---> 组合 %s 数据 \n", [frameworkName UTF8String]);
        NSMutableString *strM = [NSMutableString stringWithString:@"||API||class:line:offset||reason/suggestion||developer||dev_date||reviewer||review_date||comment||\n"];
        
        [deprecatedAPIDictM enumerateKeysAndObjectsUsingBlock:^(NSString *api, NSMutableDictionary *classMarkPostDictM, BOOL * _Nonnull stop) {
            [classMarkPostDictM enumerateKeysAndObjectsUsingBlock:^(NSString *classLineOffsetStr, NSString *deprecatedReason, BOOL * _Nonnull stop) {
                NSString *lineStr = [NSString stringWithFormat:@"|%@ |%@ |%@ | | | | | |\n", api, classLineOffsetStr, deprecatedReason];
                [strM appendString:lineStr];
            }];
        }];
        
        printf("---> 输出 %s 数据 \n", [frameworkName UTF8String]);
        [[strM.copy dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[NSString stringWithFormat:@"%@/%@_deprecated.txt", EXPORT_FILE_PATH, frameworkName] atomically:YES];
    }];
    
    printf("\n-------> all done! \n");
}

@end
