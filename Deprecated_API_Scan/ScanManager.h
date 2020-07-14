//
//  ScanManager.h
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/12.
//  Copyright © 2020 李扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScanManager : NSObject

// 不要使用此方法，输出的内容会混乱
+ (void)startViaOutput;

+ (void)startViaContent;

@end
