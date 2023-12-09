package com.maomengte.alibc4;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.text.TextUtils;
import android.webkit.WebChromeClient;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;

import com.ali.auth.third.core.MemberSDK;
import com.ali.auth.third.core.config.AuthOption;
import com.ali.auth.third.core.context.KernelContext;
import com.ali.auth.third.core.model.Session;
import com.ali.auth.third.ui.LoginActivity;
import com.alibaba.baichuan.android.trade.AlibcTrade;
import com.alibaba.baichuan.android.trade.AlibcTradeSDK;
import com.alibaba.baichuan.android.trade.callback.AlibcTradeInitCallback;
import com.alibaba.baichuan.android.trade.model.AlibcShowParams;
import com.alibaba.baichuan.android.trade.model.OpenType;
import com.alibaba.baichuan.android.trade.page.AlibcAddCartPage;
import com.alibaba.baichuan.android.trade.page.AlibcBasePage;
import com.alibaba.baichuan.android.trade.page.AlibcDetailPage;
import com.alibaba.baichuan.android.trade.page.AlibcMyCartsPage;
import com.alibaba.baichuan.android.trade.page.AlibcShopPage;
import com.alibaba.baichuan.trade.biz.AlibcConstants;
import com.alibaba.baichuan.trade.biz.AlibcTradeCallback;
import com.alibaba.baichuan.trade.biz.applink.adapter.AlibcFailModeType;
import com.alibaba.baichuan.trade.biz.auth.AlibcAuth;
import com.alibaba.baichuan.trade.biz.context.AlibcTradeResult;
import com.alibaba.baichuan.trade.biz.core.taoke.AlibcTaokeParams;
import com.alibaba.baichuan.trade.biz.login.AlibcLogin;
import com.alibaba.baichuan.trade.biz.login.AlibcLoginCallback;
import com.alibaba.baichuan.trade.common.AlibcTradeCommon;
import com.ut.device.UTDevice;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * Alibc4Plugin
 */
public class Alibc4Plugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    Context context;
    Activity activity;
    AlibcShowParams showParams;
    AlibcTaokeParams taokeParams;
    Map<String, String> trackParams = new HashMap<>(); //自定义参数

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "alibc4");
        channel.setMethodCallHandler(this);
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("init")) {
            AlibcTradeSDK.asyncInit((Application) context, new AlibcTradeInitCallback() {
                @Override
                public void onSuccess() {
                    result.success(getResult(0));
                }

                @Override
                public void onFailure(int code, String msg) {
                    result.success(getResult(-1, code + " " + msg));
                }
            });
        } else if (call.method.equals("login")) {
            AlibcLogin.getInstance().turnOnDebug();
            AlibcLogin.getInstance().showLogin(new AlibcLoginCallback() {
                @Override
                public void onSuccess(int loginResult, String s, String openId) {
                    LogUtils.e("login>>" + openId);
                    result.success(getResult(0, openId));
                }

                @Override
                public void onFailure(int code, String msg) {
                    // code：错误码  msg： 错误信息
                    result.success(getResult(-1, code + " " + msg));
                }
            });
        } else if (call.method.equals("logout")) {
            AlibcLogin.getInstance().logout(new AlibcLoginCallback() {
                @Override
                public void onSuccess(int loginResult, String s, String openId) {
                    LogUtils.e("logout>>" + openId);
                    result.success(getResult(0));
                }

                @Override
                public void onFailure(int code, String msg) {
                    // code：错误码  msg： 错误信息
                    result.success(getResult(-1, code + " " + msg));
                }
            });
        } else if (call.method.equals("getUserInfo")) {
            Session session = AlibcLogin.getInstance().getSession();
            if (session != null) {
                Map<String, Object> map = new HashMap<>();
                map.put("userid", session.userid);
                map.put("avatarUrl", session.avatarUrl);
                map.put("openId", session.openId);
                map.put("openSid", session.openSid);
                map.put("topAccessToken", session.topAccessToken);
                map.put("topAuthCode", session.topAuthCode);
                map.put("topExpireTime", session.topExpireTime);
                map.put("ssoToken", session.ssoToken);
                map.put("havanaSsoToken", session.havanaSsoToken);
                result.success(getResult(0, map));
            } else {
                result.success(getResult(-1));
            }
        } else if (call.method.equals("setChannel")) {
            Map<String, String> map = (Map<String, String>) call.arguments;
            AlibcTradeSDK.setChannel(map.get("typeName"), map.get("channelName"));
            result.success(getResult(0));
        } else if (call.method.equals("setISVVersion")) {
            AlibcTradeSDK.setISVVersion((String) call.arguments);
        } else if (call.method.equals("openByBizCode")) {
            Map<String, String> map = (Map<String, String>) call.arguments;
            initParams(map);
            AlibcBasePage page = null;
            String code = "detail";
            if (map.get("itemId") != null) {//打开详情页
                page = new AlibcDetailPage(map.get("itemId"));
                code = "detail";
            }
            if (map.get("shopId") != null) {//打开店铺首页
                page = new AlibcShopPage(map.get("shopId"));
                code = "shop";
            }
            AlibcTrade.openByBizCode(activity, page, null, new WebViewClient(), new WebChromeClient(), code, showParams, taokeParams, trackParams, new AlibcTradeCallback() {
                @Override
                public void onTradeSuccess(AlibcTradeResult tradeResult) {
                    result.success(getResult(0));
                }

                @Override
                public void onFailure(int code, String msg) {
                    result.success(getResult(-1, code + " " + msg));
                }
            });
        } else if (call.method.equals("openCart")) {
            Map<String, String> map = (Map<String, String>) call.arguments;
            initParams(map);
            AlibcBasePage page = new AlibcMyCartsPage();
            AlibcTrade.openByBizCode(activity, page, null, new WebViewClient(), new WebChromeClient(), "cart", showParams, taokeParams, trackParams, new AlibcTradeCallback() {
                @Override
                public void onTradeSuccess(AlibcTradeResult tradeResult) {
                    result.success(getResult(0));
                }

                @Override
                public void onFailure(int code, String msg) {
                    result.success(getResult(-1, code + " " + msg));
                }
            });
        } else if (call.method.equals("openByUrl")) {
            Map<String, String> map = (Map<String, String>) call.arguments;
            initParams(map);
            if (map.get("url") != null) {
                AlibcTrade.openByUrl(activity, "", map.get("url"), null, new WebViewClient(), new WebChromeClient(), showParams, taokeParams, trackParams, new AlibcTradeCallback() {
                    @Override
                    public void onTradeSuccess(AlibcTradeResult tradeResult) {
                        result.success(getResult(0));
                    }

                    @Override
                    public void onFailure(int code, String msg) {
                        result.success(getResult(-1, code + " " + msg));
                    }
                });
            } else {
                result.success(getResult(-1, "url must not be null"));
            }
        } else if (call.method.equals("checkSession")) {
            AlibcLogin alibcLogin = AlibcLogin.getInstance();
            if (alibcLogin.isLogin()) {
                result.success(getResult(0, alibcLogin.getSession().openId));
            } else {
                result.success(getResult(0));
            }
        } else if (call.method.equals("getUtdid")) {
            result.success(getResult(0, UTDevice.getUtdid(context)));
        } else {
            result.notImplemented();
        }
    }

    void initParams(Map map) {
        LogUtils.e("initParams>>" + map.toString());
        showParams = new AlibcShowParams();
        //OpenType（页面打开方式）： 枚举值（Auto和Native），Native表示唤端，Auto表示不做设置
        if (map.get("openType") != null && map.get("openType").equals("auto")) {
            showParams.setOpenType(OpenType.Auto);
        } else {
            showParams.setOpenType(OpenType.Native);
        }
        //clientType表示唤端类型：taobao---唤起淘宝客户端；tmall---唤起天猫客户端
        if (map.get("clientType") != null && map.get("clientType").equals("tmall")) {
            showParams.setClientType("tmall");
        } else {
            showParams.setClientType("taobao");
        }
        showParams.setOpenType(OpenType.Native);
        showParams.setClientType("taobao");
        if (map.get("title") != null) {
            showParams.setTitle(map.get("title").toString());
        }
        if (map.get("degradeUrl") != null) {
            showParams.setDegradeUrl(map.get("degradeUrl").toString());
        }
        //BACK_URL（小把手）：唤端返回的scheme,如果不传默认将不展示小把手；如果想展示小把手，可以自己传入自定义的scheme
        if (map.get("backUrl") != null) {
            showParams.setBackUrl(map.get("backUrl").toString());
        }
        int failType = 0;
        if (map.get("failType") != null) {
            failType = (int) map.get("failType");
        }
        //唤端失败模式
        switch (failType) {
            case 0:
            default://默认
                showParams.setNativeOpenFailedMode(AlibcFailModeType.AlibcNativeFailModeJumpH5);
                break;
            case 1://跳转浏览器
                showParams.setNativeOpenFailedMode(AlibcFailModeType.AlibcNativeFailModeJumpBROWER);
                break;
            case 2://跳转下载页
                showParams.setNativeOpenFailedMode(AlibcFailModeType.AlibcNativeFailModeJumpDOWNLOAD);
                break;
        }
        // taokeParams（淘客）参数配置：配置aid或pid的方式分佣
        //（注：1、如果走adzoneId的方式分佣打点，需要在extraParams中显式传入taokeAppkey，否则打点失败；
        // 2、如果是打开店铺页面(shop)，需要在extraParams中显式传入sellerId，否则同步打点转链失败）
        taokeParams = new AlibcTaokeParams("", "", "");
        if (map.get("pid") != null) {
            taokeParams.setPid(map.get("pid").toString());
        }
        if (map.get("aid") != null) {
            taokeParams.setAdzoneid(map.get("aid").toString());
        }
        if (map.get("subPid") != null) {
            taokeParams.setSubPid(map.get("subPid").toString());
        }
        if (map.get("unionId") != null) {
            taokeParams.setUnionId(map.get("unionId").toString());
        }
        taokeParams.extraParams = trackParams;
        if (map.get("sellerId") != null) {
            taokeParams.extraParams.put("sellerId", map.get("sellerId").toString());
        }
        if (map.get("taokeAppkey") != null) {
            taokeParams.extraParams.put("taokeAppkey", map.get("taokeAppkey").toString());
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    Map<String, Object> getResult(int code) {
        Map<String, Object> map = new HashMap<>();
        map.put("code", code);
        return map;
    }

    Map<String, Object> getResult(int code, Object msg) {
        Map<String, Object> map = new HashMap<>();
        map.put("code", code);
        map.put("msg", msg);
        return map;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}
