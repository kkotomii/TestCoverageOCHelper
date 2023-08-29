//
//  MyWebSocket.h
//  TestCoverageOCHelper
//
//  Created by 徐芙蓉 on 2023/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyWebSocket : NSObject <NSURLSessionWebSocketDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;

- (instancetype)initWithURL:(NSURL *)url;
- (void)connect;
- (void)disconnect;
- (void)send:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
