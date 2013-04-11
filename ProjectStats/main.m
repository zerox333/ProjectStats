//
//  main.m
//  ProjectStats
//
//  Created by ZeroX on 13-4-11.
//  Copyright (c) 2013年 ZeroX. All rights reserved.
//

#import <Foundation/Foundation.h>

NSPipe *runSystemCommand(NSString *cmd)
{
    NSTask * task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:[NSArray arrayWithObjects:@"-c", cmd, nil]];
    
    NSPipe * outPipe = [NSPipe pipe];
    [task setStandardOutput:outPipe];
    
    [task launch];
    [task release];
    
    return outPipe;
}

void getStats(NSString *path)
{
    NSPipe *pipe = runSystemCommand([NSString stringWithFormat:@"find %@ -maxdepth 1 -name \"*.m\" -or -name \"*.h\" -or -name \"*.mm\" | xargs wc -l", path]);
    
    NSFileHandle * read = [pipe fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding] autorelease];
    if (stringRead.length == 0) {
        return;
    }
    NSLog(@"output:\n%@", stringRead);
    [stringRead writeToFile:[path stringByAppendingString:@"/stats.txt"]
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
}

void cleanStats(NSString *path)
{
    runSystemCommand([NSString stringWithFormat:@"find %@ -type f -name \"stats.txt\" | xargs rm -rf",path]);
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSString *path = argc == 2 ? [NSString stringWithUTF8String:argv[1]] : @".";
        NSArray *pathArray = [[NSFileManager defaultManager] subpathsAtPath:path];
        BOOL isDirectory;
        for (NSString *subPath in pathArray)
        {
            NSString *fullPath = [path stringByAppendingFormat:@"/%@", subPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory])
            {
                if (isDirectory)
                {
                    getStats([path stringByAppendingFormat:@"/%@", subPath]);
                }
            }
        }
    }
    return 0;
}

