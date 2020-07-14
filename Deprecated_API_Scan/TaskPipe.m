//
//  TaskPipe.m
//  Deprecated_API_Scan
//
//  Created by 李扬 on 2020/7/14.
//  Copyright © 2020 李扬. All rights reserved.
//

#import "TaskPipe.h"

static void(^outputBlock)(NSString *);

@implementation TaskPipe

+ (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments = @[@"-c", [NSString stringWithFormat:@"%@", commandToRun]];
    [task setArguments: arguments];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
       
    [task launch];
       
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

+ (void)runCommandWaitForDataInBackgroundAndNotify:(NSString *)commandToRun output:(void (^)(NSString *))output
{
    outputBlock = output;
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments = @[@"-c", [NSString stringWithFormat:@"%@", commandToRun]];
    [task setArguments: arguments];

    NSPipe *p = [NSPipe pipe];
    [task setStandardOutput:p];
    
    NSFileHandle *fh = [p fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:NSFileHandleDataAvailableNotification object:fh];

    [task launch];
}

+ (void)receivedData:(NSNotification *)notif
{
    NSFileHandle *fh = [notif object];
    NSData *data = [fh availableData];
    if (data.length > 0)
    {
        [fh waitForDataInBackgroundAndNotify];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (outputBlock != nil) { outputBlock(str); }
    }
}

@end
