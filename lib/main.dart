import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Soccer Control',
      home: ControlPage(),
    );
  }
}

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  BluetoothConnection? connection;
  List<BluetoothDevice> discoveredDevices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Robot Soccer Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _startDiscovery();
              },
              child: Text('Discover Bluetooth Devices'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: discoveredDevices.length,
                itemBuilder: (context, index) {
                  BluetoothDevice device = discoveredDevices[index];
                  return ListTile(
                    title: Text('${device.name} (${device.address})'),
                    onTap: () {
                      _connectToDevice(device);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                controlButton('Forward', 'F'),
                SizedBox(width: 20),
                controlButton('Left', 'L'),
                SizedBox(width: 20),
                controlButton('Stop', 'S'),
                SizedBox(width: 20),
                controlButton('Right', 'R'),
              ],
            ),
            SizedBox(height: 20),
            controlButton('Backward', 'B'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (connection == null || !connection!.isConnected) {
                  showToast('Not connected to the robot.');
                } else {
                  showToast('Already connected to the robot.');
                }
              },
              child: Text('Check Connection Status'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _disconnectBluetooth();
              },
              child: Text('Disconnect Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }

  Widget controlButton(String label, String command) {
    return ElevatedButton(
      onPressed: () {
        sendBluetoothData(command);
      },
      child: Text(label),
    );
  }

  void sendBluetoothData(String data) {
    if (connection != null && connection!.isConnected) {
      final List<int> bytes = utf8.encode('$data');
      connection!.output.add(Uint8List.fromList(bytes));
      connection!.output.allSent.then((_) {
        print('Sent: $data');
      });
    } else {
      showToast('Not connected to the robot.');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _startDiscovery() async {
    discoveredDevices.clear();
    try {
      // Check if Bluetooth is available
      if (await FlutterBluetoothSerial.instance.isAvailable == null) {
        showToast('Bluetooth availability could not be determined');
        return;
      }

      // Check if Bluetooth is not available
      bool isBluetoothAvailable =
          await FlutterBluetoothSerial.instance.isAvailable ?? false;
      if (!isBluetoothAvailable) {
        showToast('Bluetooth is not available on this device');
        return;
      }

      // Start discovery
      FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        BluetoothDevice device = result.device;
        showToast('Discovered device: ${device.name} (${device.address})');
        setState(() {
          discoveredDevices.add(device);
        });
      });

      // Wait for a while to allow discovery to complete
      await Future.delayed(Duration(seconds: 5));

      showToast('Discovery completed');
    } catch (error) {
      showToast('Error during discovery: $error');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address)
              .timeout(Duration(seconds: 10)); // Adjust the timeout duration

      showToast('Connected to the robot');
      setState(() {
        this.connection = connection;
      });

      // Listen to data stream
      connection.input?.listen(
        (Uint8List data) {
          // Handle incoming data
          String receivedData = utf8.decode(data);
          print('Received data: $receivedData');
          // Add your logic to handle received data
        },
        onDone: () {
          // Handle when the connection is closed
          showToast('Connection closed');
          setState(() {
            this.connection = null;
          });
        },
        onError: (error) {
          // Handle errors during data stream
          showToast('Error in data stream: $error');
        },
      );

      // Now you can send data through this.connection
      // Example: this.connection.output.add(Uint8List.fromList([1, 2, 3]));
    } catch (error) {
      showToast('Error connecting to the robot: $error');
    }
  }

  void _disconnectBluetooth() {
    if (connection != null && connection!.isConnected) {
      connection!.finish();
      showToast('Disconnected from the robot');
    } else {
      showToast('Not connected to the robot.');
    }
  }
}
