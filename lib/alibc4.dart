
import 'alibc4_platform_interface.dart';

class Alibc4 {
  Future<String?> getPlatformVersion() {
    return Alibc4Platform.instance.getPlatformVersion();
  }

  
  Future<Map?> init()  {
    return Alibc4Platform.instance.init();
  }

  Future<Map?> login()  {
    return Alibc4Platform.instance.login();
  }

  Future<Map?> logout()  {
    return Alibc4Platform.instance.logout();
  }

  Future<Map?> getUserInfo()  {
    return Alibc4Platform.instance.getUserInfo();
  }

  Future<Map?> setChannel(typeName,channelName)  {
    return Alibc4Platform.instance.setChannel(typeName,channelName);
  }

  Future<Map?> setISVVersion(version)  {
    return Alibc4Platform.instance.setISVVersion(version);
  }

  Future<Map?> openByBizCode(Map params)  {
    return Alibc4Platform.instance.openByBizCode(params);
  }

  Future<Map?> openByUrl(Map params)  {
    return Alibc4Platform.instance.openByUrl(params);
  }

  Future<Map?> openCart(Map params)  {
    return Alibc4Platform.instance.openCart(params);
  }

  Future<Map?> checkSession()  {
    return Alibc4Platform.instance.checkSession();
  }

  Future<Map?> getUtdid()  {
    return Alibc4Platform.instance.getUtdid();
  }

  Future<Map?> oauth(url)  {
    return Alibc4Platform.instance.oauth(url);
  }
}
