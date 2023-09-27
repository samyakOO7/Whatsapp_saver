import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../ui/homepage.dart';
import 'authDetails.dart';
import 'firebaseAuth.dart';

class AuthSignUpDetails extends StatefulWidget {
  @override
  _AuthSignUpDetailsState createState() => _AuthSignUpDetailsState();
}

class _AuthSignUpDetailsState extends State<AuthSignUpDetails> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  int? androidSDK;

  @override
  void initState() {
    super.initState();
    _loadPermission();
  }

  Future<void> _loadPermission() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    setState(() {
      androidSDK = androidInfo.version.sdkInt;
    });
  }

  Future<int> _requestPermission() async {
    PermissionStatus status;
    if (androidSDK! >= 30) {
      status = await Permission.manageExternalStorage.request();
    } else {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      return 1;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<FirebaseAuthService>(context);
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Email and Password Verification'),
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16.0),
                Text(
                  'Welcome to WhatsApp Saver',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 35),
                Center(
                  child: Image.asset(
                    'assets/images/logo1.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'First Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your first name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Last Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your last name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
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
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(),
                  ),
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
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
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
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String firstName = firstNameController.text;
                    String lastName = lastNameController.text;
                    String email = emailController.text;
                    String password = passwordController.text;

                    // Check if the user already exists
                    final existingUser = await _authService.checkUserExistence(email);

                    if (existingUser) {
                      // User already exists, show a dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('User Already Exists'),
                            content: Text('User with this email already exists. Please sign in instead.'),
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
                    } else {
                      // User does not exist, proceed with sign-up
                      dynamic signUpResult = await _authService.createUserWithEmailAndPassword(email, password, firstName, lastName);

                      if (signUpResult is User) {
                        int permissionStatus = await _requestPermission();
                        if (permissionStatus == 1) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DefaultTabController(
                                length: 2,
                                child: MyHome(),
                              ),
                            ),
                          );
                        } else {
                          // Handle storage permission not granted
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Storage Permission Required'),
                                content: Text('Please allow storage permission.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _requestPermission();
                                      });
                                    },
                                    child: Text('OK'),
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
                              title: Text('Sign-Up Failed'),
                              content: Text(signUpResult.toString()),
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
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 15,),
                ElevatedButton(
                  onPressed: () async {
                    var signUp = await _authService.signInWithGoogle();
                    if (signUp == null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Sign-Up Failed'),
                            content: Text(signUp == null ? 'Some problem occurred' : signUp.toString()),
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
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AuthDetails(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
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
  runApp(MaterialApp(
    home: AuthSignUpDetails(),
  ));
}
