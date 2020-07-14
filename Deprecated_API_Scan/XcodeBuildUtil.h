//
//  XcodeBuildUtil.h
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/14.
//  Copyright © 2020 李扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XcodeBuildUtil : NSObject

+ (NSString *)syncClean;

+ (NSString *)syncBuild;

+ (void)asyncBuild:(void(^)(NSString *line))output finished:(void(^)(void))finished;

@end
