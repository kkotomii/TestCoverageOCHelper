//
//  TestCoverageHelper.m
//  TestCoverageOCHelper
//
//  Created by 徐芙蓉 on 2023/5/17.
//

#import "TestCoverageHelper.h"
#import "InstrProfiling.h"
#import "MyWebSocket.h"
#import "Reachability.h"

@interface TestCoverageHelper()
@property (nonatomic, strong) MyWebSocket *webSocket;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation TestCoverageHelper

+(instancetype)shareInstance
{
    static TestCoverageHelper *_actionTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _actionTool = [[TestCoverageHelper alloc]init];
    });
    return _actionTool;
}

- (void)resignInfo: (NSString *)webUrl {
//    NSUUID *uuid = [[NSUUID alloc] init];
//    NSString *urlString = [NSString stringWithFormat:@"ws://172.21.0.61:5888/ws?fingerprint=%@&versionName=%@", uuid, versionName];
    NSString *urlString = webUrl;
    self.webSocket = [[MyWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];

    NSLog(@"%@", urlString);
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];

//    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    [reachability startNotifier];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
//    if (networkStatus == NotReachable) {
//        NSLog(@"没有可用网络连接");
//    } else if (networkStatus == ReachableViaWiFi) {
//        [self.webSocket connect];
//        NSLog(@"已连接到 Wi-Fi 网络");
//    } else if (networkStatus == ReachableViaWWAN) {
//        [self.webSocket connect];
//        NSLog(@"已连接到移动数据网络");
//    }
}

- (void)reachabilityChanged:(NSNotification *)notification {
    Reachability *reachability = [notification object];

    NetworkStatus networkStatus = [reachability currentReachabilityStatus];

    if (networkStatus == NotReachable) {
        NSLog(@"没有可用网络连接");
    } else if (networkStatus == ReachableViaWiFi) {
        NSLog(@"已连接到 Wi-Fi 网络");
        [self.webSocket connect];
    } else if (networkStatus == ReachableViaWWAN) {
        NSLog(@"已连接到移动数据网络");
        [self.webSocket connect];
    }
}

//断开连接
- (void)disconnect {
    [self.webSocket disconnect];
}

//连接
- (void)connect {
    [self.webSocket connect];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
