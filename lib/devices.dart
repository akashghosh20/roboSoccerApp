// // DeviceListPage.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// class DeviceListPage extends StatelessWidget {
//   final List<BluetoothDevice> discoveredDevices;

//   DeviceListPage({required this.discoveredDevices});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Discovered Devices'),
//       ),
//       body: ListView.builder(
//         itemCount: discoveredDevices.length,
//         itemBuilder: (context, index) {
//           BluetoothDevice device = discoveredDevices[index];
//           return ListTile(
//             title: Text('${device.name} (${device.address})'),
//             onTap: () {
//               // You can add functionality here when a device is tapped
//             },
//           );
//         },
//       ),
//     );
//   }
// }
