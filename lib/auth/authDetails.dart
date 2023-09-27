import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../ui/homepage.dart';
import 'authSignUpDetails.dart';
import 'firebaseAuth.dart';

class AuthDetails extends StatefulWidget {
  @override
  _AuthDetailsState createState() => _AuthDetailsState();
}

class _AuthDetailsState extends State<AuthDetails> {
  String email = '';
  String password = '';
  bool isPasswordVisible = false;
  int? androidSDK;

  @override
  void initState() {
    super.initState();
    _checkStoragePermissionAndRedirect();
  }

  Future<void> _checkStoragePermissionAndRedirect() async {
    final storagePermissionStatus = await _loadPermission();
    if (storagePermissionStatus == 1) {
      _navigateToHome();
    }
  }

  Future<void> _navigateToHome() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DefaultTabController(
            length: 2,
            child: MyHome(),
          ),
        ),
      );
    }
  }

  Future<int> _loadPermission() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    setState(() {
      androidSDK = androidInfo.version.sdkInt;
    });
    if (androidSDK! >= 30) {
      final _currentStatusManaged = await Permission.manageExternalStorage.status;
      if (_currentStatusManaged.isGranted) {
        return 1;
      } else if (_currentStatusManaged.isDenied || _currentStatusManaged.isRestricted) {
        final _requestStatusManaged = await Permission.manageExternalStorage.request();
        if (_requestStatusManaged.isGranted) {
          return 1;
        }
      }
    } else {
      final _currentStatusStorage = await Permission.storage.status;
      if (_currentStatusStorage.isGranted) {
        return 1;
      } else if (_currentStatusStorage.isDenied || _currentStatusStorage.isRestricted) {
        final _requestStatusStorage = await Permission.storage.request();
        if (_requestStatusStorage.isGranted) {
          return 1;
        }
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<FirebaseAuthService>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Email and Password Verification'),
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 32.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome to WhatsApp Saver',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Image.asset(
                  'assets/images/logo1.png',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () async {
                          final user = await _authService.signInWithEmailAndPassword(email, password);

                          if (user != null) {
                            final storagePermissionStatus = await _loadPermission();
                            if (storagePermissionStatus == 1) {
                              _navigateToHome();
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Storage Permission Required'),
                                    content: Text('You need to grant storage permission to use this app.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          final permissionStatus = await Permission.manageExternalStorage.request();
                                          if (permissionStatus.isGranted) {
                                            _navigateToHome();
                                          }
                                        },
                                        child: Text('Grant Permission'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Authentication Error'),
                                  content: Text('Invalid email or password. Please try again.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          'VERIFY',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            var signIn = await _authService.signInWithGoogle();
                            if (signIn == null) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Sign-In Failed'),
                                    content: Text(signIn == null
                                        ? 'Some problem occurred'
                                        : signIn.toString()),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            print("Google Sign-In Error: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Sign In with Google',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to the application? ',
                              style: TextStyle(fontSize: 18),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AuthSignUpDetails(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: AuthDetails(),
    ),
  );
}
