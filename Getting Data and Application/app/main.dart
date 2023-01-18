import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Data app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sensor Data App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final myController = TextEditingController();

class _MyHomePageState extends State<MyHomePage> {
  bool check = false;
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;

  Future<http.Response> sendData() {
    print('post');
    return http.post(
      Uri.parse(myController.text),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'accelerometer': '$_accelerometerValues',
        'gyroscope': '$_gyroscopeValues'

      }),
    );
  }

  var _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    if (check) {
      final accelerometer = _accelerometerValues
          ?.map((double v) => v.toStringAsFixed(1))
          .toList();
      final gyroscope =
          _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
      sendData();

      return Scaffold(
        appBar: AppBar(
          title: const Text('Sensor Data Collection'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Accelerometer: $accelerometer'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Gyroscope: $gyroscope'),
                ],
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    check = false;
                    _streamSubscriptions = <StreamSubscription<dynamic>>[];
                  });
                },
                child: Text("Stop"))
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sensor '),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                width: 350.0,
                child: TextField(
                  controller: myController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a search term',
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Accelerometer: '),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Gyroscope: '),
                ],
              ),
            ),

            ElevatedButton(
                onPressed: () {
                  setState(() {
                    check = true;
                    _streamSubscriptions = <StreamSubscription<dynamic>>[];
                  });
                },
                child: Text("Start"))
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );

  }
}
