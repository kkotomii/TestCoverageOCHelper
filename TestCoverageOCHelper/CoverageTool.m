//
//  CoverageTool.m
//  TestCoverageOCHelper
//
//  Created by 徐芙蓉 on 2023/5/19.
//

#import "CoverageTool.h"
#import "InstrProfiling.h"

@implementation CoverageTool
NSString *name = @"test.profraw";
NSString *newName = @"newTest.profraw";
NSString *lastName = @"lastTest.profraw";
NSString *filePath = @"";
NSString *newFilePath = @"";
NSString *lastFilePath = @"";
NSFileManager *fileManager;

+(instancetype)shareInstance
{
    static CoverageTool *_actionTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _actionTool = [[CoverageTool alloc]init];
    });
    return _actionTool;
}

- (void)setFileManager {
    fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectory = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//    filePath = [[documentDirectory URLByAppendingPathComponent:name] path];
    newFilePath = [[documentDirectory URLByAppendingPathComponent:newName] path];
//    lastFilePath = [[documentDirectory URLByAppendingPathComponent:lastName] path];
//    if ([fileManager fileExistsAtPath:newFilePath]) {
//        if ([fileManager fileExistsAtPath:filePath]) {
//            [self mergeFiles:@[[NSURL fileURLWithPath:lastName], [NSURL fileURLWithPath:lastName]] destination:[NSURL fileURLWithPath:lastName]];
//        } else {
//            [fileManager copyItemAtPath:newFilePath toPath:filePath error:nil];
//        }
//    }
    
    NSLog(@"文件路径：%@", filePath);
}

- (void)getCoverage {
    if ([fileManager fileExistsAtPath:newFilePath]) {
        [fileManager removeItemAtPath:newFilePath error:nil];
    }
    __llvm_profile_set_filename([newFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
    __llvm_profile_write_file();
    
//    [self uploadFileToServer];
}

- (void)clearCoverage {
    if ([fileManager fileExistsAtPath:newFilePath]) {
        [fileManager removeItemAtPath:newFilePath error:nil];
        NSLog(@"clearCoverage 中删除原来文件");
    }
//
//    if ([fileManager fileExistsAtPath:filePath]) {
//        [fileManager removeItemAtPath:filePath error:nil];
//    }
//
//    if ([fileManager fileExistsAtPath:lastFilePath]) {
//        [fileManager removeItemAtPath:lastFilePath error:nil];
//    }
    
    __llvm_profile_reset_counters();
//    __llvm_profile_set_filename([newFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
//    __llvm_profile_write_file();
}

- (void) mergeFiles: (NSArray<NSURL *> *)files destination:(NSURL *)destination {
    [fileManager createFileAtPath:destination.path contents:nil attributes:nil];
    NSFileHandle *writer = [NSFileHandle fileHandleForWritingToURL:destination error:nil];
    for (NSURL *partLocation in files) {
        NSFileHandle *reader = [NSFileHandle fileHandleForReadingFromURL:partLocation error:nil];
        NSData *data = nil;
        NSUInteger chunkSize = 1000000;
        while ((data = [reader readDataOfLength:chunkSize])) {
            NSUInteger bytesRead = [data length];
            if (bytesRead > 0) {
                [writer writeData:data];
            }
        }
        [reader closeFile];
    }
    [writer closeFile];
}

- (NSData *)sendFile {
    NSData *fileData = [[NSData alloc] init];
    NSError *error = nil;
    fileData = [NSData dataWithContentsOfFile:newFilePath options:NSDataReadingMappedAlways error:&error];
    return fileData;
}

@end
