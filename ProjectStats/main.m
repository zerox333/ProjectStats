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
    NSLog(@"\n%@\n", stringRead);
    [stringRead writeToFile:[path stringByAppendingString:@"/stats.txt"]
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
}

void cleanStats(NSString *path)
{
    runSystemCommand([NSString stringWithFormat:@"find %@ -type f -name \"stats.txt\" | xargs rm -rf",path]);
}

void printfHowToUse()
{
    printf(" ----------------------------------------------");
    printf("\n| How To Use:                                  |\n");
    printf("| ProjectStats [pathOfProject]       --- stats |\n");
    printf("|              [-c pathOfProject]    --- clean |\n");
    printf(" ----------------------------------------------\n");
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        switch (argc) {
            case 2:
            {
                NSString *path = [[NSString stringWithUTF8String:argv[1]] length] > 0 ? [NSString stringWithUTF8String:argv[1]] : @".";
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
                break;
            case 3:
            {
                if ([[NSString stringWithUTF8String:argv[1]] isEqualToString:@"-c"] && [[NSString stringWithUTF8String:argv[2]] length] > 0)
                {
                    cleanStats([NSString stringWithUTF8String:argv[2]]);
                }
            }
                break;
                
            default:
            {
                printf("Arguments error...\n");
                printfHowToUse();
            }
                break;
        }
        

    }
    return 0;
}

