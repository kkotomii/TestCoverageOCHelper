//
//  MyWebSocket.m
//  TestCoverageOCHelper
//
//  Created by 徐芙蓉 on 2023/5/19.
//

#import "MyWebSocket.h"
#import "CoverageTool.h"

API_AVAILABLE(ios(13.0))
@interface MyWebSocket()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionWebSocketTask *webSocketTask;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSURLRequest *webSocketURL;
@end

@implementation MyWebSocket

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.webSocketURL = [NSURLRequest requestWithURL:url];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        if (@available(iOS 13.0, *)) {
            _webSocketTask = [_urlSession webSocketTaskWithRequest:_webSocketURL];
        } else {
            // Fallback on earlier versions
        }
        [self setInfo];
    }
    return self;
}

- (void)setInfo {
    [[CoverageTool shareInstance] setFileManager];
}

//打开连接
- (void)connect {
    if (@available(iOS 13.0, *)) {
        [self.webSocketTask cancel];
        self.webSocketTask = [_urlSession webSocketTaskWithRequest:self.webSocketURL];
        [self.webSocketTask resume];
        [self receiveMessage];
    } else {
        // Fallback on earlier versions
    }
}

- (void)sendHeartbeat {
    //发送心跳包
    [self send:@""];
}

//断开连接
- (void)disconnect {
    if (@available(iOS 13.0, *)) {
        NSInteger closeCode = NSURLSessionWebSocketCloseCodeNormalClosure;
        NSData *closeReason = [@"WebSocket connection closed" dataUsingEncoding:NSUTF8StringEncoding];
        [self.webSocketTask cancelWithCloseCode:closeCode reason:closeReason];
    } else {
        // Fallback on earlier versions
    }
    NSLog(@"WebSocket 连接已断开");
}

- (void)send:(NSString *)message {
    if (@available(iOS 13.0, *)) {
        NSURLSessionWebSocketMessage *webSocketMessage = [[NSURLSessionWebSocketMessage alloc] initWithString:message];
        [_webSocketTask sendMessage:webSocketMessage completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"发送消息时出错：%@", error.localizedDescription);
            } else {
                NSLog(@"消息已发送：%@", message);
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)sendWithData:(NSData *)messageData {
    if (@available(iOS 13.0, *)) {
        NSURLSessionWebSocketMessage *webSocketMessage = [[NSURLSessionWebSocketMessage alloc] initWithData:messageData];
        [_webSocketTask sendMessage:webSocketMessage completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"发送消息时出错：%@", error.localizedDescription);
            } else {
                NSLog(@"消息已发送：%@", messageData);
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)URLSession:(NSURLSession *)session webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask didOpenWithProtocol:(NSString * _Nullable)protocol  API_AVAILABLE(ios(13.0)){
    NSLog(@"WebSocket 连接已打开");
    
    if(self.timer) {
        NSLog(@"我是连接已打开的timer");
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)URLSession:(NSURLSession *)session webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode reason:(NSData * _Nullable)reason  API_AVAILABLE(ios(13.0)){
    NSLog(@"WebSocket 连接已关闭");
    // 重新连接 WebSocket
//    self.session = session;
//    self.webSocketTask = webSocketTask;
    // 连接已正常关闭，可以重新连接
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self restartConnect];
    });
}

- (void)restartConnect {
    NSLog(@"restartConnect");
    if(self.timer) {
        NSLog(@"我是restartConnect的timer");
        [self.timer invalidate];
        self.timer = nil;
    }
    
    NSLog(@"我是webSocketTask = %@", self.webSocketTask);
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

//- (void)restartConnect {
//    NSLog(@"restartConnect");
//    //重新连接
//    if (@available(iOS 13.0, *)) {
//        self.webSocketTask = [self.session webSocketTaskWithRequest:self.webSocketURL];
//        [self.webSocketTask resume];
//        [self receiveMessage];
//    } else {
//        // Fallback on earlier versions
//    }
//}

- (void)timerAction:(NSTimer *)timer {
    NSLog(@"timerAction1");
    if (@available(iOS 13.0, *)) {
//        NSURLSessionWebSocketTask *newTask = [self.session webSocketTaskWithRequest: self.webSocketTask.originalRequest];
        [self.webSocketTask cancel];
        self.webSocketTask = [_urlSession webSocketTaskWithRequest:self.webSocketURL];
//        self.webSocketTask = newTask;
        NSLog(@"我是webSocketTask%@", self.webSocketTask);
        if (self.webSocketTask.state != NSURLSessionTaskStateRunning) {
            [self.webSocketTask resume];
        }
        [self receiveMessage];
        NSLog(@"timerAction2");
    } else {
        // Fallback on earlier versions
    }
}

- (void)receiveMessage {
    if (@available(iOS 13.0, *)) {
        [_webSocketTask receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error) {
            if (error) {
                NSLog(@"接收消息时发生错误：%@", error.localizedDescription);
                // 连接已正常关闭，可以重新连接
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self restartConnect];
                });
            } else {
                switch ([message type]) {
                    case NSURLSessionWebSocketMessageTypeData: {
                        NSString *text = [[NSString alloc] initWithData:message.data encoding:NSUTF8StringEncoding];
                        NSLog(@"接收到消息：%@", text);
                        [[CoverageTool shareInstance] getCoverage];
                        break;
                    }
                    case NSURLSessionWebSocketMessageTypeString: {
                        NSLog(@"接收到消息：%@", message.string);
                        [self handleResponseEvent:message.string];
                        break;
                    }
                    default:
                        break;
                }
                [self receiveMessage];
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)handleResponseEvent: (NSString *)message {
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (dictionary && [dictionary[@"event"] isEqual: @"collect"]) {
        // 覆盖率收集
        [[CoverageTool shareInstance] getCoverage];
        NSData *fileData = [[CoverageTool shareInstance] sendFile];
        [self sendWithData:fileData];
        NSLog(@"覆盖率收集");
    } else if (dictionary && [dictionary[@"event"] isEqual: @"reset"]){
        // 覆盖率重置
        [[CoverageTool shareInstance] clearCoverage];
//        NSData *fileData = [[CoverageTool shareInstance] sendFile];
//        [self sendWithData:fileData];
        NSLog(@"覆盖率重置");
    }
    
    NSLog(@"%@", dictionary);
}

@end
