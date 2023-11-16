// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Firebase Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   double servo1Angle = 90.0;
//   double servo2Angle = 90.0;
//   double servo3Angle = 90.0;
//   double servo4Angle = 90.0;
//   double servo5Angle = 90.0;

//   late DatabaseReference _database;

//   @override
//   void initState() {
//     super.initState();
//     _initializeFirebase();
//   }

//   Future<void> _initializeFirebase() async {
//     _database = FirebaseDatabase.instance.reference();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Robotic Arm Controller App',
//           style: TextStyle(color: Colors.white),
//         ),
//         leading: Icon(Icons.rocket),
//         backgroundColor: Colors.grey,
//         shadowColor: Colors.redAccent,
//         elevation: 2,
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Center(
//                 child: Builder(
//                   builder: (context) => Row(
//                     children: <Widget>[
//                       // ... (unchanged code)

//                       ElevatedButton(
//                         onPressed: () {
//                           sendDataToFirebase();
//                         },
//                         child: Text('Move All Servos'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // Footer
//           Container(
//             padding: EdgeInsets.all(16.0),
//             width: 450,
//             height: 100,
//             color: Colors.grey, // Adjust the color as needed
//             child: Column(
//               children: [
//                 Text(
//                   'Mechatronics Lab',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//                 Text(
//                   'Mymensingh Engineering College',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget servoSlider(String servoName, double angle, Function(double) onChanged,
//       IconData icon) {
//     // ... (unchanged code)
//   }

//   void sendDataToFirebase() {
//     _database.child('servos').set({
//       'servo1Angle': servo1Angle,
//       'servo2Angle': servo2Angle,
//       'servo3Angle': servo3Angle,
//       'servo4Angle': servo4Angle,
//       'servo5Angle': servo5Angle,
//     });
//   }
// }
