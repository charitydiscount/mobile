import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigWrapper {
  RemoteConfig _remoteConfig;

  Future<double> getWithdrawalThreshold() async {
    RemoteConfigValue configValue = await _getValue('withdrawal_threshold');
    return configValue.asDouble();
  }

  Future<String> getSearchEndpoint() async {
    RemoteConfigValue configValue = await _getValue('search_endpoint');
    return configValue.asString();
  }

  Future<String> getAffiliateEndpoint() async {
    RemoteConfigValue configValue = await _getValue('affiliate_endpoint');
    return configValue.asString();
  }

  Future<String> getPicturesBucket() async {
    RemoteConfigValue configValue = await _getValue('pictures_bucket');
    return configValue.asString();
  }

  Future<String> getDynamicLinksPrefix() async {
    RemoteConfigValue configValue = await _getValue('dynamic_link_prefix');
    return configValue.asString();
  }

  Future<String> getMetaImage() async {
    RemoteConfigValue configValue = await _getValue('meta_image_url');
    return configValue.asString();
  }

  Future<String> getString(String key) async {
    RemoteConfigValue configValue = await _getValue(key);
    return configValue.asString();
  }

  Future<RemoteConfigValue> _getValue(String key) async {
    if (_remoteConfig == null) {
      await _setInstance();
    }
    return _remoteConfig.getValue(key);
  }

  Future<void> _setInstance() async {
    _remoteConfig = await RemoteConfig.instance;
    try {
      await _remoteConfig.fetch(expiration: const Duration(hours: 0));
      await _remoteConfig.activateFetched();
    } catch (e) {}
  }
}

final RemoteConfigWrapper remoteConfig = RemoteConfigWrapper();
