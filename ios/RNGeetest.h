#import <React/RCTBridgeModule.h>
#import <GTFramework/GTFramework.h>

@interface RNGeetest : NSObject <RCTBridgeModule, GTManageDelegate>

@property (nonatomic, strong) GTManager *manager;

@end
