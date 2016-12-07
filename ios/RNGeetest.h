#import "RCTBridgeModule.h"
#import <GTFramework/GTFramework.h>

@interface RNGeetest : NSObject <RCTBridgeModule, GTManageDelegate>

@property (nonatomic, strong) GTManager *manager;
@property (nonatomic, strong) NSString *challengeURL;
@property (nonatomic, strong) NSString *validateURL;

@end
