//
//  TaskPipe.h
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/14.
//  Copyright © 2020 李扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskPipe : NSObject

+ (NSString *)runCommand:(NSString *)commandToRun;

+ (void)runCommandWaitForDataInBackgroundAndNotify:(NSString *)commandToRun output:(void(^)(NSString * line))output;

@end
