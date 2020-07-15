//
//  DocsExport.m
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/14.
//  Copyright © 2020 李扬. All rights reserved.
//

#import "DocsExport.h"

#define EXPORT_FILE_FULL_PATH @"/Users/liyang/Downloads/deprecated_api.txt"

static NSMutableDictionary *depracatedApiDictM = nil;
static NSUInteger buildRecordCount = 0;
static NSUInteger buildDistinguishRecordCount = 0;
static NSMutableSet *moduleSetM = nil;

@implementation DocsExport

+ (void)pushBuildContent:(NSString *)content
{
    static NSRegularExpression *regexValue = nil;
    if (regexValue == nil)
    {
        regexValue = [NSRegularExpression regularExpressionWithPattern:@"(/Users/.+/maimai_ios/.+:[0-9]+:[0-9]+):.(error|warning):\\s+('(.+)'\\s+is\\s+deprecated:.+)\\[" options:0 error:nil];
    }
    
    if (depracatedApiDictM == nil) { depracatedApiDictM = [NSMutableDictionary dictionary]; }
    if (moduleSetM == nil) { moduleSetM = [NSMutableSet set]; }

    [regexValue enumerateMatchesInString:content options:0 range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable contentResult, NSMatchingFlags flags, BOOL * _Nonnull stop) {
       
        // 检索到的符合规则的整行字符串， 就是line本身
//        NSString *lineStr = [content substringWithRange:[contentResult rangeAtIndex:0]];
        
        // 类标记完整路径，类似这样 /Users/liyang/git/company/maimai/maimai_react_native/maimai_ios/Important/Util/NTUtilities.h:124:32
        NSString *classMarkPathStr = [content substringWithRange:[contentResult rangeAtIndex:1]];
        printf("%lu---> %s  ", (unsigned long)++buildRecordCount, [classMarkPathStr UTF8String]);
        
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
        
//        // 获取 classLineOffsetStr 类似 xxx.class:3534:233
//        NSString *classLineOffsetStr = classMarkPostArr.lastObject;
        
        // Important 归属为 PlatformSDK
        if ([frameworkName isEqualToString:@"Important"]) { frameworkName = @"PlatformSDK"; }
        [moduleSetM addObject:frameworkName];
        
        if (depracatedApiDictM[deprecatedAPI] == nil)
        {
            depracatedApiDictM[deprecatedAPI] = [NSMutableDictionary dictionary];
        }
        
        NSMutableDictionary *moduleDictM = depracatedApiDictM[deprecatedAPI];
        if (moduleDictM[frameworkName] == nil)
        {
            moduleDictM[frameworkName] = [NSMutableDictionary dictionary];
        }
        
        // 组合 mark 和 reason
        NSMutableDictionary *classMarkPostDictM = moduleDictM[frameworkName];
        classMarkPostDictM[classMarkPostStr] = deprecatedReason;
        
        // 组合 api 和 mark
        moduleDictM[frameworkName] = classMarkPostDictM;
        // 组合 framework 和 api
        depracatedApiDictM[deprecatedAPI] = moduleDictM;
        
        NSLog(@"");
    }];
    
    NSLog(@"");
}

+ (void)export2File
{
    NSMutableString *strM = [NSMutableString stringWithString:@"||n||API||Module||class:line:offset||reason/suggestion||developer||dev_date||cr||comment||\n"];
    
    //由于allKeys返回的是无序数组，这里我们要排列它们的顺序
    NSArray *sortedArray = [depracatedApiDictM.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];

    [sortedArray enumerateObjectsUsingBlock:^(NSString *deprecatedAPI, NSUInteger idx, BOOL * _Nonnull stop) {
        
        printf("---> 组合 %s 数据 \n", [deprecatedAPI UTF8String]);
        
        NSMutableDictionary *moduleDictM = depracatedApiDictM[deprecatedAPI];
        [moduleDictM enumerateKeysAndObjectsUsingBlock:^(NSString *frameworkName, NSMutableDictionary *classMarkPostDictM, BOOL * _Nonnull stop) {
            [classMarkPostDictM enumerateKeysAndObjectsUsingBlock:^(NSString *classLineOffsetStr, NSString *deprecatedReason, BOOL * _Nonnull stop) {
                ++buildDistinguishRecordCount;
                NSString *lineStr = [NSString stringWithFormat:@"|%lu |%@ |%@ |%@ |%@ | | | | |\n", buildDistinguishRecordCount, deprecatedAPI, frameworkName, classLineOffsetStr, deprecatedReason];
                [strM appendString:lineStr];
            }];
        }];
        
        printf("---> 输出 %s 数据 \n", [deprecatedAPI UTF8String]);
    }];
    
    [[strM.copy dataUsingEncoding:NSUTF8StringEncoding] writeToFile:EXPORT_FILE_FULL_PATH atomically:YES];
    
    printf("\n---> 扫描统计：\n---> xcode build 过期api记录 数目: %lu\n---> 去重归纳后 过期api记录 数目: %lu\n---> 过期api 类型 数目: %lu\n---> 涉及的framework: %lu (%s)\n",
           buildRecordCount, buildDistinguishRecordCount, sortedArray.count, moduleSetM.count, [[moduleSetM.allObjects componentsJoinedByString:@"、"] UTF8String]);

    printf("\n-------> all done! \n");
}

@end
