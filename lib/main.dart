import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'ads/ads_callback.dart';
import 'controller/auth_controller.dart';
import 'controller/home_controller.dart';
import 'controller/pref.dart';
import 'controller/favorite_server_controller.dart';
import 'controller/referral_controller.dart';
import 'controller/speed_test_controller.dart';
import 'data/api/api_client.dart';
import 'service/notification_service.dart';
import 'utils/my_color.dart';
import 'utils/my_helper.dart';
import 'view/screens/splash_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data.isNotEmpty) {}
}

NotificationService notificationService = NotificationService();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  GetStorage storage = GetStorage();

  // Initialize notifications
  notificationService.ensureNotificationPermission();
  await NotificationService.startListeningNotificationEvents();

  const firebaseOptionsAndroid = FirebaseOptions(
    apiKey: 'AIzaSyBERuGBROMGgb87cXibocTGI8OPLjTiBTo',
    appId: '1:787804813632:android:2be09fb7add5544a89e2a5',
    messagingSenderId: '787804813632',
    projectId: 'dbug-codecanyon',
  );

  const firebaseOptionsIOS = FirebaseOptions(
    apiKey: 'AIzaSyB7FjoE4NU667n7VCyvW_QsezaH46MvGoA',
    appId: '1:787804813632:ios:20cc5b303617dae789e2a5',
    messagingSenderId: '787804813632',
    projectId: 'dbug-codecanyon',
  );

  try {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(options: firebaseOptionsAndroid);
    } else if (Platform.isIOS) {
      await Firebase.initializeApp(options: firebaseOptionsIOS);
    } else {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {}
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (storage.read(MyHelper.notification) ?? true) {
      _showNotification(message);
    }
  });

  MobileAds.instance.initialize();
  await UnityAds.init(
    gameId: storage.read(MyHelper.unityAdsAppId) ?? '',
    onComplete: () {},
    onFailed: (error, message) {},
  );
  FacebookAudienceNetwork.init(iOSAdvertiserTrackingEnabled: true);
  await Pref.initializeHive();

  ApiClient myApiClient =
      ApiClient(appBaseUrl: MyHelper.baseUrl, sharedPreferences: storage);

  // Register ApiClient with GetX dependency injection
  Get.put<ApiClient>(myApiClient, permanent: true);

  Get.lazyPut<AdsCallBack>(() => AdsCallBack(), fenix: true);
  Get.lazyPut<HomeController>(() => HomeController(apiClient: myApiClient),
      fenix: true);
  Get.lazyPut<AuthController>(() => AuthController(apiClient: myApiClient),
      fenix: true);
  Get.lazyPut<FavoriteServerController>(
      () => FavoriteServerController(apiClient: myApiClient),
      fenix: true);
  Get.lazyPut<ReferralController>(
      () => ReferralController(apiClient: myApiClient),
      fenix: true);
  Get.lazyPut<SpeedTestController>(
      () => SpeedTestController(apiClient: myApiClient),
      fenix: true);

  runApp(
    Phoenix(
      child: const MyApp(),
    ),
  );
}

int generateNotificationId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
}

void _showNotification(RemoteMessage message) async {
  final Map<String, dynamic> data = message.data;

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'default_channel',
    'Push Notifications',
    channelDescription: 'Notify updated news and information',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    generateNotificationId(),
    message.notification?.title ?? 'New Notification',
    message.notification?.body ??
        'You have a new message from ${MyHelper.appname}.',
    platformChannelSpecifics,
    payload: data['ad_id']?.toString(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: MyColor.bg),
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Builder(
            builder: (context) {
              return child!;
            },
          ),
        );
      },
    );
  }
}
