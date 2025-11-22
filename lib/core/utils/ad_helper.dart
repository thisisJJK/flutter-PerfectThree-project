import 'dart:io';

class AdHelper {
  // 구글이 제공하는 공식 테스트용 배너 광고 ID입니다.
  // 앱 출시(배포) 시에는 실제 AdMob 콘솔에서 발급받은 ID로 교체해야 합니다.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // 안드로이드 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}