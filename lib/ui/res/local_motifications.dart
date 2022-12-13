import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  static final LocalNotificationsService _notificationService =
      LocalNotificationsService._internal();

  factory LocalNotificationsService() {
    return _notificationService;
  }

  LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'school_notifications', // id
    'Notificaciones escolares', // title
    /* 'Este canal es utilizado para  recibir notificaciones escolares .', // description */
    importance: Importance.high,
  );

  Future<void> init() async {
    // channel for heads up notifications
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // setting for android
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    // setting for ios
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      //  onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    // create the completed settings object
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    // initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);
  }

  void showNotification(
    int id,
    String title,
    String body,
  ) async {
    _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
          android: AndroidNotificationDetails(_channel.id, _channel.name,
              /* _channel.description, */
              icon: "@mipmap/ic_launcher"
              // other properties...
              )), /* payload: "go-to-notification"*/
    );
  }
}
