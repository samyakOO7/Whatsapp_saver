import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/authDetails.dart';
import 'dashboard.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  static const String adUnitId = 'ca-app-pub-2358526312866333/4538654077';
  // real unit code
  static bool isAdLoaded = false;
  BuildContext? myContext;
  late BannerAd myBanner = BannerAd(
    adUnitId: adUnitId,
    size: AdSize.fullBanner,
    request: AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (ad){
        setState(() {
          isAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error)
      {
        setState(() {
          ad.dispose();
          print(error);
        });
      }
    ),
  );
  // Add the MobileAdTargetingInfo for test devices

  @override
  void initState() {
    super.initState();
    myBanner.load();
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Saver'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () {
                AdaptiveTheme.of(context).toggleThemeMode();
              }),
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
        bottom: TabBar(tabs: [
          Container(
            padding: const EdgeInsets.all(12.0),
            child: const Text(
              'IMAGES',
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            child: const Text(
              'VIDEOS',
            ),
          ),
        ]),
      ),
      body: const Dashboard(),
      bottomNavigationBar: SizedBox(
      height: myBanner.size.height.toDouble(),
        width: myBanner.size.width.toDouble(),// Adjust the height as needed
        child: isAdLoaded ? AdWidget(ad: myBanner) : SizedBox(), // Display the banner ad
    ),

    );
  }
  void _signOut() async {
    // Implement your sign-out logic here.
    // For example, if you're using Firebase Authentication, you can sign out as follows:
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the sign-in screen or any other appropriate screen after sign-out.
      // For example:
      if (myContext != null) {
        Navigator.of(myContext!).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AuthDetails(), // Replace with your sign-in screen
          ),
        );
      }
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  Future<void> choiceAction(String choice) async {
    if (choice == Constants.about) {
    } else if (choice == Constants.rate) {
    } else if (choice == Constants.share) {}
    else if(choice == Constants.signOut)
      {
        _signOut();
      }
  }
}

class Constants {
  static const String about = 'About App';
  static const String rate = 'Rate App';
  static const String share = 'Share with friends';
  static const String signOut = 'Sign Out';

  static const List<String> choices = <String>[about, rate, share, signOut];
}
