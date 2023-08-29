//
//  CoverageTool.h
//  TestCoverageOCHelper
//
//  Created by 徐芙蓉 on 2023/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoverageTool : NSObject
+ (instancetype)shareInstance;
- (void)setFileManager;
- (void)clearCoverage;
- (void)getCoverage;
- (NSData *)sendFile;
@end

NS_ASSUME_NONNULL_END
