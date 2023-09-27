import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:wa_status_saver/auth/firebaseAuth.dart';
import 'package:wa_status_saver/firebase_options.dart';
import 'auth/authDetails.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var databaseUrl = 'https://whatsapp-status-saver-a1f20-default-rtdb.firebaseio.com';
  var apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
  var projectId = DefaultFirebaseOptions.currentPlatform.projectId;
  var messagingSenderId = DefaultFirebaseOptions.currentPlatform.messagingSenderId;
  var appId = DefaultFirebaseOptions.currentPlatform.appId;
  await Firebase.initializeApp(
    options: FirebaseOptions(
      databaseURL: databaseUrl,
      apiKey: apiKey, appId: appId, messagingSenderId: messagingSenderId, projectId: projectId, // Add your database URL here
    )
  );
  MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: <String>[],
    ),
  );

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseAuthService>(
      create: (_)=> FirebaseAuthService(),
      child: AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.teal,
          // accentColor: Colors.amber,
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          // accentColor: Colors.amber,
        ),
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Savvy',
          theme: theme,
          darkTheme: darkTheme,
          home: AuthDetails(),
        ),
      ),
    );
  }
}
