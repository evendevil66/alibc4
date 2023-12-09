import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'alibc4_platform_interface.dart';

/// An implementation of [Alibc4Platform] that uses method channels.
class MethodChannelAlibc4 extends Alibc4Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('alibc4');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map?> init() async {
    final map = await methodChannel.invokeMethod<Map>('init');
    return map;
  }

  @override
  Future<Map?> login() async {
    final map = await methodChannel.invokeMethod<Map>('login');
    return map;
  }

  @override
  Future<Map?> logout() async {
    final map = await methodChannel.invokeMethod<Map>('logout');
    return map;
  }

  @override
  Future<Map?> getUserInfo() async {
    final map = await methodChannel.invokeMethod<Map>('getUserInfo');
    return map;
  }

  @override
  Future<Map?> setChannel(typeName,channelName) async {
    final map = await methodChannel.invokeMethod<Map>('setChannel',{"typeName":typeName,"channelName":channelName});
    return map;
  }

  @override
  Future<Map?> setISVVersion(version) async {
    final map = await methodChannel.invokeMethod<Map>('setISVVersion',version);
    return map;
  }

  @override
  Future<Map?> openByBizCode(Map params) async {
    final map = await methodChannel.invokeMethod<Map>('openByBizCode',params);
    return map;
  }

  @override
  Future<Map?> openByUrl(Map params) async {
    final map = await methodChannel.invokeMethod<Map>('openByUrl',params);
    return map;
  }

  @override
  Future<Map?> openCart(Map params) async {
    final map = await methodChannel.invokeMethod<Map>('openCart',params);
    return map;
  }

  @override
  Future<Map?> checkSession() async {
    final map = await methodChannel.invokeMethod<Map>('checkSession');
    return map;
  }

  @override
  Future<Map?> getUtdid() async {
    final map = await methodChannel.invokeMethod<Map>('getUtdid');
    return map;
  }

  @override
  Future<Map?> oauth(url) async {
    final map = await methodChannel.invokeMethod<Map>('oauth',url);
    return map;
  }
}
