#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>

#import "RNGeetest.h"

@implementation RCTConvert (GTPresentType)

RCT_ENUM_CONVERTER(GTPresentType, (@{@"center": @(GTPopupCenterType),
                                     @"bottom": @(GTPopupBottomType)
                                     }), GTPopupCenterType, integerValue)

@end

@implementation RNGeetest {
    BOOL rejectOnClose;
}

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE()

- (GTManager *)manager {
    if (!_manager) {
        _manager = [[GTManager alloc] init];
        [_manager setGTDelegate:self];
        //多语言配置
        [_manager languageSwitch:LANGTYPE_AUTO];
        //配置布局方式
        [_manager useGTViewWithPresentType:GTPopupCenterType];
        //验证高度约束
        [_manager useGTViewWithHeightConstraintType:GTViewHeightConstraintLargeViewWithLogo];
        //使用背景模糊
        [_manager useVisualViewWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        //验证背景颜色(例:yellow rgb(255,200,50))
        [_manager setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    }
    return _manager;
}

RCT_EXPORT_METHOD(setDebugMode:(BOOL)debugMode) {
    // debug配置
    [self.manager enableDebugMode:debugMode];
}

RCT_EXPORT_METHOD(useSecurityAuthentication:(BOOL)ssl) {
    // https配置
    [self.manager useSecurityAuthentication:ssl];
}

RCT_EXPORT_METHOD(setPresentType:(GTPresentType)type) {
    [self.manager useGTViewWithPresentType:type];
}

RCT_EXPORT_METHOD(request:(nonnull NSString *) challengeURL
              validateURL:(nonnull NSString *)validateURL
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    __weak __typeof(self) weakSelf = self;
    NSURL *requestURL = [NSURL URLWithString:challengeURL];
    GTCallFinishBlock finishBlock = ^(NSString *code, NSDictionary *result, NSString *message) {

        if ([code isEqualToString:@"1"]) {
            //在用户服务器进行二次验证(start Secondery-Validate)
            [weakSelf secondaryValidate:code
                                 result:result
                                message:message
                            validateURL:validateURL
                               resolver:resolve
                               rejecter:reject];
        } else {
            NSLog(@"geetest: code : %@, message : %@", code, message);
        }
    };

    //用户关闭验证时调用
    GTCallCloseBlock closeBlock = ^{
        //用户关闭验证后执行的方法
        NSLog(@"geetest: close");
        if (rejectOnClose) {
            reject(@"close", @"User closed validation", NULL);
            [self.bridge.eventDispatcher sendAppEventWithName:@"GeetestValidationFinished"
                                                         body:@NO];
        }
    };

    //默认failback处理, 在此打开验证
    GTDefaultCaptchaHandlerBlock defaultCaptchaHandlerBlock = ^(NSString *gt_captcha_id, NSString *gt_challenge, NSNumber *gt_success_code) {
        rejectOnClose = YES;
        //根据custom server的返回success字段判断是否开启failback
        if ([gt_success_code intValue] == 1) {

            if (gt_captcha_id.length == 32) {
                //打开极速验证，在此处完成gt验证结果的返回
                [weakSelf.manager openGTViewAddFinishHandler:finishBlock closeHandler:closeBlock animated:YES];
            } else {
                NSLog(@"geetest: invalid geetest ID, please set right ID");
            }

        } else {
            //当极验服务器不可用时，将执行此处网站主的自定义验证方法或者其他处理方法(gt-server is not available, add your handler methods in here)
            /**请网站主务必考虑这一处的逻辑处理，否者当极验服务不可用的时候会导致用户的业务无法正常执行*/
            UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"提示"
                                                              message:@"极验验证服务异常不可用"
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [warning show];
            });
            NSLog(@"geetest: 极验验证服务暂时不可用,请网站主在此写入启用备用验证的方法");
        }
    };

    //配置验证, 必须weak, 否则内存泄露
    [weakSelf.manager configureGTest:requestURL
                             timeout:30.0
                      withCookieName:nil
                             options:GTDefaultAsynchronousRequest
                   completionHandler:defaultCaptchaHandlerBlock];
}

- (void)secondaryValidate:(NSString *)code
                   result:(NSDictionary *)result
                  message:(NSString *)message
              validateURL:(NSString *)validateURL
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject {
    if (code && result) {
        @try {
            if ([code isEqualToString:@"1"]) {
                __block NSMutableString *postResult = [[NSMutableString alloc] init];

                //行为判定通过，进行二次验证
                NSString *custom_server_validate_url = validateURL;
                NSDictionary *headerFields = @{@"Content-Type":@"application/x-www-form-urlencoded;charset=UTF-8"};

                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:custom_server_validate_url]];
                [result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [postResult appendFormat:@"%@=%@&",key,obj];
                }];
                NSLog(@"geetest: postResult: %@",postResult);
                if (postResult.length > 0) {
                    NSURLSessionConfiguration *configurtion = [NSURLSessionConfiguration defaultSessionConfiguration];
                    configurtion.allowsCellularAccess = YES;
                    configurtion.HTTPAdditionalHeaders = headerFields;
                    configurtion.timeoutIntervalForRequest = 15.0;
                    configurtion.timeoutIntervalForResource = 15.0;

                    NSURLSession *session = [NSURLSession sessionWithConfiguration:configurtion];
                    request.HTTPMethod = @"POST";
                    // demo中与仅仅使用表单格式格式化二次验证数据作为演示, 使用其他的格式也是可以的, 但需要与网站主的服务端沟通好以便提交并解析数据
                    request.HTTPBody = [postResult dataUsingEncoding:NSUTF8StringEncoding];

                    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

                        if (!error) {
                            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                                // 二次验证成功后执行的方法
                                rejectOnClose = NO;
                                resolve(NULL);
                                [self.bridge.eventDispatcher sendAppEventWithName:@"GeetestValidationFinished"
                                                                             body:@YES];
                            } else {
                                NSLog(@"geetest: statusCode: %ld", (long)httpResponse.statusCode);
                            }
                        } else {
                            NSLog(@"geetest: error: %@", error.localizedDescription);
                        }
                    }];
                    [sessionDataTask resume];
                    [session finishTasksAndInvalidate];
                }

            } else {
                NSLog(@"geetest: client captcha failed:\ncode :%@ message:%@ result:%@", code, message, result);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"geetest: client captcha exception:%@", exception.description);
        }
        @finally {

        }
    }
}

- (NSDictionary *)constantsToExport {
    return @{ @"presentTypePopupCenter": @(GTPopupCenterType),
              @"presentTypePopupBottom": @(GTPopupBottomType)
             };
};

#pragma --mark GTManageDelegate

- (void)GTNetworkErrorHandler:(NSError *)error{
    if (error.code == -999) {
        //忽略此类型错误, 仅打印
        //用户在加载请求时, 关闭验证可能导致此错误
        NSLog(@"geetest: Error: %@", error.localizedDescription);
    }
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                             message:error.localizedDescription
                                                            delegate:self
                                                   cancelButtonTitle:@"知道了"
                                                   otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak __typeof(self) weakSelf = self;
            [weakSelf.manager closeGTViewIfIsOpen];
            [errorAlert show];
        });
        NSLog(@"geetest: Error: %@", error.localizedDescription);
    }

}

@end
