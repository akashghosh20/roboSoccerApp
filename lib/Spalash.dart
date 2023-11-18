import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:roboticarmapp/main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 3 seconds, then navigate to the ControlPage
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ControlPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo image goes here
            Image.asset(
              'assets/images/logo.jpg', // replace with your image asset path
              width: 150, // adjust size as needed
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'MEC MECHARONICS LAB',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            SpinKitDoubleBounce(
              color: Colors.blue, // Adjust color as needed
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}