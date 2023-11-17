import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  Timer? _sendCommandTimer;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _startSendingDefaultCommand();
  }

  void _startSendingDefaultCommand() {
    const Duration defaultCommandInterval = Duration(seconds: 1);

    _sendCommandTimer?.cancel();

    _sendCommandTimer = Timer.periodic(defaultCommandInterval, (timer) {
      if (connection != null && connection!.isConnected && !_isButtonPressed) {
        _sendCommand('S'); // Send 'S' continuously when no button is pressed
      } else {
        _sendCommandTimer?.cancel(); // Cancel the timer when a button is pressed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MECHATRONICS LAB SOCCER CONTROLLER'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              _startDiscovery();
            },
            child: Text('Discover Bluetooth Devices'),
          ),
          SizedBox(height: 20),
          ResponsiveGrid(
            buttons: buttons,
            onPressed: _sendCommand,
            onTapUp: () {
              _resetButtonState();
            },
            onButtonPressed: (isPressed) {
              setState(() {
                _isButtonPressed = isPressed;
              });
              if (_isButtonPressed) {
                _sendCommandTimer?.cancel();
              } else {
                _startSendingDefaultCommand();
              }
            },
          ),
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
          SizedBox(height: 20),
          Text(
            'Discovered Devices:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
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
        ],
      ),
    );
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
      if (await FlutterBluetoothSerial.instance.isAvailable == null) {
        showToast('Bluetooth availability could not be determined');
        return;
      }

      bool isBluetoothAvailable =
          await FlutterBluetoothSerial.instance.isAvailable ?? false;
      if (!isBluetoothAvailable) {
        showToast('Bluetooth is not available on this device');
        return;
      }

      FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        BluetoothDevice device = result.device;
        showToast('Discovered device: ${device.name} (${device.address})');
        setState(() {
          discoveredDevices.add(device);
        });
      });

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
              .timeout(Duration(seconds: 10));

      showToast('Connected to the robot');
      setState(() {
        this.connection = connection;
      });

      connection.input?.listen(
        (Uint8List data) {
          String receivedData = utf8.decode(data);
          print('Received data: $receivedData');
        },
        onDone: () {
          showToast('Connection closed');
          setState(() {
            this.connection = null;
          });
        },
        onError: (error) {
          showToast('Error in data stream: $error');
        },
      );

      // Cancel the default command timer when connected
      _sendCommandTimer?.cancel();
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

  Future<void> _sendCommand(String command) async {
    print('Sending command: $command');
    if (connection != null && connection!.isConnected) {
      for (int i = 0; i < command.length; i++) {
        String currentChar = command[i];
        connection!.output.add(Uint8List.fromList(utf8.encode(currentChar)));
        await connection!.output.allSent;
      }
    }
  }

  void _resetButtonState() {
    setState(() {
      _isButtonPressed = false;
    });
    _sendCommand('S'); // Stop command when the button is released
    _startSendingDefaultCommand(); // Restart the timer when the button is released
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Map<String, dynamic>> buttons;
  final void Function(String) onPressed;
  final VoidCallback onTapUp;
  final Function(bool) onButtonPressed;

  ResponsiveGrid({
    required this.buttons,
    required this.onPressed,
    required this.onTapUp,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    int buttonsPerRow = 3; // Adjust as needed
    int rowCount = (buttons.length / buttonsPerRow).ceil();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(rowCount, (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(buttonsPerRow, (buttonIndex) {
            int index = rowIndex * buttonsPerRow + buttonIndex;
            if (index < buttons.length) {
              return CircularButton(
                label: buttons[index]['label'],
                command: buttons[index]['command'],
                angle: buttons[index]['angle'],
                onPressed: onPressed,
                onTapUp: onTapUp,
                onButtonPressed: onButtonPressed,
              );
            } else {
              // Empty container for the last row if buttons don't fill the entire row
              return Container();
            }
          }),
        );
      }),
    );
  }
}

class CircularButton extends StatefulWidget {
  final String label;
  final String command;
  final double angle;
  final void Function(String) onPressed;
  final VoidCallback onTapUp;
  final Function(bool) onButtonPressed;

  const CircularButton({
    required this.label,
    required this.command,
    required this.angle,
    required this.onPressed,
    required this.onTapUp,
    required this.onButtonPressed,
  });

  @override
  _CircularButtonState createState() => _CircularButtonState();
}

class _CircularButtonState extends State<CircularButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
        widget.onPressed(widget.command);
        widget.onButtonPressed(true);
      },
      onTapUp: (_) {
        _resetButtonState();
      },
      onTapCancel: () {
        _resetButtonState();
      },
      child: ElevatedButton(
        onPressed: () {
          // This is needed to prevent the button from being disabled
        },
        style: ElevatedButton.styleFrom(
          primary: _isPressed ? Colors.red : Colors.blue,
          onPrimary: Colors.white,
          shape: CircleBorder(),
          padding: EdgeInsets.all(10), // Adjust padding for smaller buttons
          minimumSize: Size(80, 80), // Set the size of the button
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _resetButtonState() {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed('S'); // Stop command when the button is released
    widget.onTapUp(); // Call the provided onTapUp callback
    widget.onButtonPressed(false);
  }
}

List<Map<String, dynamic>> buttons = [
  {'label': 'F', 'command': 'F', 'angle': 0.0},
  {'label': 'FL', 'command': 'l', 'angle': 315.0},
  {'label': 'S', 'command': 'S', 'angle': 180.0},
  {'label': 'FR', 'command': 'r', 'angle': 45.0},
  {'label': 'L', 'command': 'L', 'angle': 270.0},
  {'label': 'R', 'command': 'R', 'angle': 90.0},
  {'label': 'B', 'command': 'B', 'angle': 180.0},
  {'label': 'BL', 'command': 'b', 'angle': 225.0},
  {'label': 'BR', 'command': 'I', 'angle': 135.0},
];
