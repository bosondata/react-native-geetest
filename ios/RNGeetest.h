#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif
#import <GTFramework/GTFramework.h>

@interface RNGeetest : NSObject <RCTBridgeModule, GTManageDelegate>

@property (nonatomic, strong) GTManager *manager;

@end
