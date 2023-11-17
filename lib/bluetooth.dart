// // BluetoothWidget.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class BluetoothWidget extends StatefulWidget {
//   @override
//   _BluetoothWidgetState createState() => _BluetoothWidgetState();
// }

// class _BluetoothWidgetState extends State<BluetoothWidget> {
//   BluetoothConnection? connection;
//   List<BluetoothDevice> discoveredDevices = [];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             _startDiscovery();
//           },
//           child: Text('Discover Bluetooth Devices'),
//         ),
//         SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () {
//             if (connection == null || !connection!.isConnected) {
//               showToast('Not connected to the robot.');
//             } else {
//               showToast('Already connected to the robot.');
//             }
//           },
//           child: Text('Check Connection Status'),
//         ),
//         SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () {
//             _disconnectBluetooth();
//           },
//           child: Text('Disconnect Bluetooth'),
//         ),
//         SizedBox(height: 20),
//         Text(
//           'Discovered Devices:',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: discoveredDevices.length,
//             itemBuilder: (context, index) {
//               BluetoothDevice device = discoveredDevices[index];
//               return ListTile(
//                 title: Text('${device.name} (${device.address})'),
//                 onTap: () {
//                   _connectToDevice(device);
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   void showToast(String message) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }

//   // ... (rest of the code remains the same)
// }
