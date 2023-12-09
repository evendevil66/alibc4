#import "Alibc4Plugin.h"
#import "AlibcTradeSDK/AlibcTradeSDK.h"
#import <AlibcTradeSDK/AlibcTradeService.h>
#import <AlibcTradeSDK/AlibcTradePageFactory.h>
#import <AlibabaAuthEntrance/ALBBSDK.h>
#import <AlibabaAuthEntrance/ALBBCompatibleSession.h>
#import <UTDID/UTDevice.h>
#import "webview/ALiTradeWebViewController.h"

@interface Alibc4Plugin ()
@property (nonatomic, strong) AlibcTradeShowParams *showParams;
@property (nonatomic, strong) AlibcTradeTaokeParams *taokeParams;
@end

@implementation Alibc4Plugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"alibc4"
            binaryMessenger:[registrar messenger]];
  Alibc4Plugin* instance = [[Alibc4Plugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
      result(@"getPlatformVersion");
  } else  if ([@"init" isEqualToString:call.method]) {
      // 百川平台基础SDK初始化，加载并初始化各个业务能力插件
      [[AlibcTradeSDK sharedInstance] setDebugLogOpen:YES];
      [[AlibcTradeSDK sharedInstance] asyncInitWithSuccess:^{
          NSLog(@"百川SDK初始化成功");
          result(@{ @"code":@0});
      } failure:^(NSError *error) {
          NSLog(@"百川SDK初始化失败");
          result(@{ @"code":@-1,@"msg":error.description});
      }];
  } else  if ([@"login" isEqualToString:call.method]) {
      if(![[ALBBCompatibleSession sharedInstance] isLogin]) {
          [[ALBBSDK sharedInstance] setH5Only:NO];
          [[ALBBSDK sharedInstance] auth:[UIApplication sharedApplication].keyWindow.rootViewController successCallback:^{
              ALBBUser *user= [[ALBBCompatibleSession sharedInstance] getUser];
              result(@{ @"code":@0,@"msg":user.openId});
          } failureCallback:^(NSError *error) {
              NSString *tip=[NSString stringWithFormat:@"登录失败:%@",error.description];
              result(@{ @"code":@-1,@"msg":tip});
          }];
      } else {
          ALBBUser *user= [[ALBBCompatibleSession sharedInstance] getUser];
          result(@{ @"code":@0,@"msg":user.openId});
      }
  } else  if ([@"logout" isEqualToString:call.method]) {
      if([[ALBBCompatibleSession sharedInstance] isLogin]) {
          [[ALBBSDK sharedInstance] logout];
      }
      result(@{ @"code":@0});
  } else  if ([@"getUserInfo" isEqualToString:call.method]) {
      ALBBUser *user= [[ALBBCompatibleSession sharedInstance] getUser];
      NSDictionary *userInfo=@{
          @"nick":user.nick,
          @"avatarUrl":user.avatarUrl,
          @"openId":user.openId,
          @"openSid":user.openSid,
          @"topAccessToken":user.topAccessToken,
          @"topAuthCode":user.topAuthCode
      };
      result(@{ @"code":@0,@"msg":userInfo});
  }else  if ([@"setChannel" isEqualToString:call.method]) {
      NSDictionary *params=  call.arguments;
      [[AlibcTradeSDK sharedInstance] setChannel:params[@"typeName"] name:params[@"channelName"]];
      result(@{ @"code":@0});
  }else  if ([@"checkSession" isEqualToString:call.method]) {
      if([[ALBBCompatibleSession sharedInstance] isLogin]){
          ALBBUser *user= [[ALBBCompatibleSession sharedInstance] getUser];
          result(@{ @"code":@0,@"msg":user.openId});
      }else{
          result(@{ @"code":@0});
      }
  }else  if ([@"oauth" isEqualToString:call.method]) {

  }else  if ([@"getUtdid" isEqualToString:call.method]) {
      result(@{ @"code":@0,@"msg": [UTDevice utdid]});
  }else  if ([@"setISVVersion" isEqualToString:call.method]) {
      NSString *params=  call.arguments;
      [[AlibcTradeSDK sharedInstance] setIsvVersion:params];
      result(@{ @"code":@0});
  }else  if ([@"openByBizCode" isEqualToString:call.method]) {
      NSDictionary *params=  call.arguments;
      [self initParams:params];
      id<AlibcTradePage> page;
      NSString *code=@"detail";
      if(params[@"shopId"]){
          page = [AlibcTradePageFactory shopPage:params[@"shopId"]];
          code=@"shop";
      }
      if(params[@"itemId"]){
          page = [AlibcTradePageFactory itemDetailPage:params[@"itemId"]];
          code=@"detail";
      }
      //媒体可以传入自定义webview或者不传 百川SDK默认会创建webview
      ALiTradeWebViewController* view = [[ALiTradeWebViewController alloc] init];
      [[AlibcTradeSDK sharedInstance].tradeService
                             openByBizCode:code
                             page:page
                             webView:view.webView
                             parentController:view
                             showParams:_showParams
                             taoKeParams:_taokeParams
                             trackParam:@{}
                             tradeProcessSuccessCallback:^(AlibcTradeResult *alibcTradeResult){
                                   result(@{ @"code":@0});
                            }
                          tradeProcessFailedCallback:^(NSError *error){
                                   result(@{ @"code":@-1,@"msg":error.description});
                          }];
  }else  if ([@"openByUrl" isEqualToString:call.method]) {
      NSDictionary *params=  call.arguments;
      [self initParams:params];
      //媒体可以传入自定义webview或者不传 百川SDK默认会创建webview
      ALiTradeWebViewController* view = [[ALiTradeWebViewController alloc] init];
      [[AlibcTradeSDK sharedInstance].tradeService
                             openByUrl:params[@"url"]
                             identity:@"trade"
                             webView:view.webView
                             parentController:view
                             showParams:_showParams
                             taoKeParams:_taokeParams
                             trackParam:@{}
                             tradeProcessSuccessCallback:^(AlibcTradeResult *alibcTradeResult){
                                   result(@{ @"code":@0});
                            }
                          tradeProcessFailedCallback:^(NSError *error){
                                   result(@{ @"code":@-1,@"msg":error.description});
                          }];
      result(@{ @"code":@0});
  }else  if ([@"openCart" isEqualToString:call.method]) {
      NSDictionary *params=  call.arguments;
      [self initParams:params];
      id<AlibcTradePage> page = [AlibcTradePageFactory myCartsPage];
      NSString *code=@"cart";
      //媒体可以传入自定义webview或者不传 百川SDK默认会创建webview
      ALiTradeWebViewController* view = [[ALiTradeWebViewController alloc] init];
      [[AlibcTradeSDK sharedInstance].tradeService
                             openByBizCode:code
                             page:page
                             webView:view.webView
                             parentController:view
                             showParams:_showParams
                             taoKeParams:_taokeParams
                             trackParam:@{}
                             tradeProcessSuccessCallback:^(AlibcTradeResult *alibcTradeResult){
                                   result(@{ @"code":@0});
                            }
                          tradeProcessFailedCallback:^(NSError *error){
                                   result(@{ @"code":@-1,@"msg":error.description});
                          }];
  }else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)initParams:(NSDictionary*)params{
    NSLog(@"initParams>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>:%@",params);
    _showParams =[[AlibcTradeShowParams alloc] init];
    if(params[@"openType"]&&[params[@"openType"] isEqualToString:@"auto"]){
        _showParams.openType=AlibcOpenTypeAuto;
    }else{
        _showParams.openType=AlibcOpenTypeNative;
    }
    if(params[@"clientType"]&&[params[@"clientType"] isEqualToString:@"tmall"]){
        _showParams.linkKey=@"tmall";
    }else{
        _showParams.linkKey=@"taobao";
    }
    if(params[@"backUrl"]){
        _showParams.backUrl=params[@"backUrl"];
    }
    if(params[@"failType"]){
        _showParams.isNeedCustomNativeFailMode=YES;
        int failType=(int) (long)params[@"failType"];
        switch (failType) {
            case 0:
            default://不做处理
                _showParams.nativeFailMode=AlibcNativeFailModeJumpH5;
                break;
            case 1://跳转浏览器

                break;
            case 2://跳转下载页
                _showParams.nativeFailMode=AlibcNativeFailModeJumpDownloadPage;
                break;
            case 3://应用内webview打开
                _showParams.nativeFailMode=AlibcNativeFailModeJumpH5;
                if(params[@"degradeUrl"]){
                    _showParams.degradeUrl=params[@"degradeUrl"];
                }
                break;
        }
    }else{
        _showParams.nativeFailMode=AlibcNativeFailModeJumpH5;
    }
    
    _taokeParams=[[AlibcTradeTaokeParams alloc] init];
    if(params[@"pid"]){
        _taokeParams.pid=params[@"pid"];
    }
    if(params[@"aid"]){
        _taokeParams.adzoneId=params[@"aid"];
    }
    if(params[@"subPid"]){
        _taokeParams.subPid=params[@"subPid"];
    }
    if(params[@"unionId"]){
        _taokeParams.unionId=params[@"unionId"];
    }
    if(params[@"aid"]){
        _taokeParams.adzoneId=params[@"aid"];
    }
    
    NSMutableDictionary *ext=[NSMutableDictionary dictionaryWithDictionary:@{}];
    if(params[@"sellerId"]){
        ext[@"sellerId"]=params[@"sellerId"];
    }
    if(params[@"taokeAppkey"]){
        ext[@"taokeAppkey"]=params[@"taokeAppkey"];
    }
    _taokeParams.extParams=ext;

}

@end
