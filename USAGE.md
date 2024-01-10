#### B1: thêm module ads: thêm git submodule là module flutter ads bằng cách chạy lệnh:
```
git submodule add https://bitbucket.org/innofyapp/flutter_ads.git flutter_ads
```
--> chạy xong nó sẽ tự tạo folder tên flutter_ads và file .gitmodules tương ứng
--> nếu là pull về lúc pull về nó sẽ hỏi k thì chạy:` git submodule init/update`


#### B2: thêm cấu hình ads ở native:
android: thêm trong manifest
```
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
```
ios: thêm trong info.plist
```
	<key>GADApplicationIdentifier</key>
	<string>ca-app-pub-4973559944609228~2433291331</string>
```


#### B3: thêm adtheme cho android
refer ss_remote trong manifest (cần thêm AdTheme trong style)
```
        <activity
            android:name="com.google.android.gms.ads.AdActivity"
            android:theme="@style/AdTheme"
            android:screenOrientation="portrait"
            tools:replace="android:theme,android:screenOrientation">
        </activity>
```

#### B4: thêm vào depenencies trong pubspec.yaml:
```
  easy_ads_flutter:
    path: flutter_ads
```

#### B5: thêm remote config để điều khiển từ xa:

key = android_ / ios_ + cột Name ID trong Ads Script, android_show, ios_show để chung cho tất cả
type = bool

(đoạn này nên thêm key android_show, ios_show trước sau đó export ra file sửa thêm cho nhanh rồi import lại)

=> copy file config từ ss_remote hoặc đâu cũng đc
	(bên ss_remote đang tách cái AdKey enum đi hơi xa, để chung folder cũng đc hehe)
--> sửa các ad key tương ứng và sửa tên remote tương ứng

#### B6: thêm quản lí ad id

- thêm file json chứa các adUnitId: thêm các file dev như ss_remote, thêm gitignore vào đầu file gitignore để sau thêm key prod không bị đưa lên git
```
# custom
assets/adkey/adkey_prod_android.json
assets/adkey/adkey_prod_ios.json
```
- load json tương ứng (dev/prod) vào app config để dùng:
    hiện tại đang dùng class AdUnitKey là class parse file json
    và ProdAdIdManager + DevAdIdManager để riêng cho dev và prod (chia environment để check và load file json tương ứng)

#### B7: init easy ad (tốt nhất nên đặt trong màn splash sau khi khởi tạo firebase và environment config)

```dart
await EasyAds.instance.initialize(
      AppConfig.adIdManager,
      Assets.icons.splashLogo.image(height: 293.h, width: 259.w), // icon sẽ được hiện với ad resume
      unityTestMode: true,
      adMobAdRequest: const AdRequest(httpTimeoutMillis: 30000),
      admobConfiguration: RequestConfiguration(), // có thể có hoặc k, có để thêm test device id
      navigatorKey: // navigator key của toàn bộ app,
    );
```
có thể tham khảo ss_remote cái xử lí khi không có mạng để retry lấy remote config ở màn splash 
#### B8: sử dụng ads

- chú ý: ad open app cần được khởi tạo
```dart
EasyAds.instance.initAdmob(
        appOpenAdUnitId: AppConfig.adIdManager.admobKeys.openAll,
      );
```

EasyAds.instance.appLifecycleReactor.setOnSplashScreen(true/false) ở splash để k hiện resume trên splash
và gọi EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true); khi thực hiện các chức năng ngoài app (ví dụ như rate app dù nó ra store là app khác nhưng thuộc luồng chức năng của app nên quay lại không được hiện resume ads nên mới cần cái này để đánh dấu nó là chức năng đi sang app khác)

- show ad inter gọi hàm EasyAds.instance.showInterstitialAd() có sẵn
- show ad banner gọi EasyBannerAd() có sẵn
- show ad native cần tạo các factory ở native (refer ss_remote tại file `MainActivity.kt` và `AppDelegate.swift`) rồi gọi (chú ý cần có khoảng cách với nội dung app và cần custom lại style cho gần giống với app)
```
EasyNativeAd(
        factoryId: AppConfig.adIdManager.nativeCommonFactory,
        adId: adId,
        height: 272,
      ),
```
ở 2 file trên thì là nơi khai báo factory (và hủy), bên cạnh đó cần thêm các file layout tương ứng, factoryID có thể đặt tùy theo dự án, ở ss_remote đang có 3 cái thì 
 - Native_Common là native to có meadia view
 - Native_Small không có mediaview
 - Inline_Small_Native là ad native bé hơn nữa
 