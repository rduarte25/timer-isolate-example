import 'dart:async'; //import dart:async
import 'package:flutter/material.dart'; //import of material
import 'dart:isolate'; //import isolate for control of the task in background

void main() => runApp(new App()); //main method called at top of application

//the class app this is the principal class
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Timer Example',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          new HomePage(key: new GlobalKey(), title: 'Timer Example Home Page'),
    );
  }
}

//HomePage class is que home page for app
class HomePage extends StatefulWidget {
  HomePage({required key, this.title}) : super(key: key);
  final String? title;

  @override
  _HomePageState createState() => _HomePageState();
}

//State of home page
class _HomePageState extends State<HomePage> {
  Isolate? _isolate; //isolate propertie for timer
  bool _running = false; //boolean is runnig
  static int _counter = 0; //integer counter of seconds
  String notification = ""; //message of notification
  ReceivePort? _receivePort; //Port receive is not know

  //start of timer
  void _start() async {
    _running = true; //star running timer
    _receivePort = ReceivePort(); //initialitation of receivePort
    _isolate = await Isolate.spawn(_checkTimer, _receivePort!.sendPort);
    _receivePort!.listen(_handleMessage, onDone: () {
      print("done!");
    });
  }

  //check state timer for launch
  static void _checkTimer(SendPort sendPort) async {
    Timer.periodic(new Duration(microseconds: 1000), (Timer t) {
      _counter++;
      String message = 'Notification ' + _counter.toString();
      print('SEND ' + message);
      sendPort.send(message);
    });
  }

  //handle of message
  void _handleMessage(dynamic data) {
    print('RECEIVE ' + data);
    setState(() {
      notification = data;
    });
  }

  //stop timer
  void _stop() {
    if (_isolate != null) {
      setState(() {
        _running = false;
        notification = '';
      });
      _receivePort!.close();
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  //Build method of view
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(widget.title.toString())),
      body: new Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(notification),
            ]),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _running ? _stop : _start,
        tooltip: _running ? 'Timer stop' : 'Timer start',
        child: _running ? new Icon(Icons.stop) : new Icon(Icons.play_arrow),
      ),
    );
  }
}
