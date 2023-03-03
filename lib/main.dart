import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String? payload;
StreamController<String> didReceiveLocalNotificationStream = StreamController<String>.broadcast();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry:point')
void notificationTapBackground(NotificationResponse response) {
  if (response.payload != null) {
    payload = response.payload;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isIOS || Platform.isAndroid){
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinInitializationSettings = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory('0'),
      ],
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {}
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isGranted = false;

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      bool isPermitted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestPermission() ??
          false;

      setState(() {
        isGranted = isPermitted;
      });
    } else if (Platform.isIOS) {
      bool isPermitted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions() ??
          false;
      setState(() {
        isGranted = isPermitted;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // AOS : 허용하면 다시는 안 물어봄. 근데 허용 안하면 2번 까지 물어봄
      _requestPermission();
    });
  }

  void _onTap() {
    final androidNotificationDetails = AndroidNotificationDetails(
      '아이디',
      '채널 이름',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // didReceiveLocalNotificationStream.add(response.payload!);
    flutterLocalNotificationsPlugin.show(
      0,
      '테스트',
      '바디입니다',
      NotificationDetails(
        android: androidNotificationDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                _onTap();
              },
              child: Text('푸시 부르기'),
            )
          ],
        ),
      ),
    );
  }
}
