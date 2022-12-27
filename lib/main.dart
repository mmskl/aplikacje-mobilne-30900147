import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:collection';
import 'dart:math';
import 'dart:async';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manual reflex analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const Game(),
        '/hall-of-fame': (BuildContext context) => const HallOfFame(),
        '/about': (BuildContext context) => const About(),
        '/login': (BuildContext context) => const Login(),
      },
    );
  }
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        /* padding: EdgeInsets.zero, */
        children: <Widget>[
          Container(
            height: 55,
            child: DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Game'),
            onTap: () => {Navigator.of(context).pushReplacementNamed('/')},
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Hall of Fame'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HallOfFame()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => About()));
            },
          ),
        ],
      ),
    );
  }
}

Map<String, int> sortMap(Map<String, int> data) {
  var sortedEntries = data.entries.toList()
    ..sort((e1, e2) {
      var diff = e2.value.compareTo(e1.value);
      if (diff == 0) diff = e2.key.compareTo(e1.key);
      return diff;
    });

  return Map<String, int>.fromEntries(sortedEntries);
}

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  bool _is_game_playing = false;
  bool _is_logged_in = false;
  String _who_is_logged_in = 'anonymous';
  int _points = 0;

  bool _showPlayButton = false;

  int _minus_points = -5;
  int _plus_points = 10;
  int _max_at_once = 5;

  Random _rng = Random();
  Timer? _timer;
  int _gameplay = 6;
  Duration _playTime = Duration(seconds: 6);

  List<Widget> _positioned = List.filled(5, new Container());

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => _timer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => _playTime = Duration(seconds: _gameplay));
  }

  Widget _getBlock(double w, double h, bool hasLuck, int idx) {
    int pointsForUser = (hasLuck == true) ? _plus_points : _minus_points;
    MaterialColor color = (hasLuck == true) ? Colors.green : Colors.red;

    var onBlockPressed = () {
      setState(() {
        _points = _points + pointsForUser;
        _positioned[idx] = new Container();
      });
    };

    return Positioned(
      top: h,
      left: w,
      child: TextButton(
        child: Text('      '),
        onPressed: () {
          onBlockPressed();
        },
        style: TextButton.styleFrom(
          primary: color,
          backgroundColor: color,
          onSurface: color,
        ),
      ),
    );
  }

  void setCountDown() {
    double height = (MediaQuery.of(context).size.height);
    double width = (MediaQuery.of(context).size.width);

    double wrand = _rng.nextDouble() * width;
    double hrand = _rng.nextDouble() * height;

    // _positioned = [];

    for (var i = 0; i < _max_at_once; i++) {
      double wrand = _rng.nextDouble() * width;
      double hrand = _rng.nextDouble() * height;
      bool luck = false;
      if (_rng.nextDouble() > 0.51) {
        luck = true;
      }

      _positioned[i] = _getBlock(wrand, hrand, luck, i);
    }

    final reduceSecondsBy = 1;
    setState(() {
      final seconds = _playTime.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        _timer!.cancel();
      } else {
        _playTime = Duration(seconds: seconds);
      }
    });

    print("points: ${_points}");
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _is_game_playing = true;
    });
    startTimer();
  }

  void _shouldShowPlayButton() {
    if (_is_game_playing || !_is_logged_in) {
      setState(() {
        _showPlayButton = false;
      });
    } else {
      setState(() {
        _showPlayButton = true;
      });
    }
  }

  // just min and sec
  String _printStatusBar(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigitMinutes}:${twoDigitSeconds}, your points: ${_points}";
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    String main_message = '';

    if (_is_logged_in) {
      main_message = "hello, you currently play as ${_who_is_logged_in}";
    } else {
      main_message = "To play you need to login (click here)";
    }

    double height = (MediaQuery.of(context).size.height);
    double width = (MediaQuery.of(context).size.width);

    double wrand = _rng.nextDouble() * width;
    double hrand = _rng.nextDouble() * height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual reflex analyzer'),
        actions: <Widget>[
          TextButton(
            style: style,
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text(main_message),
          ),
        ],
      ),
      drawer: NavDrawer(),
      body: Container(child: Stack(children: _positioned)),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          child: Text(
            _printStatusBar(_playTime),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: _showPlayButton,
        child: FloatingActionButton.extended(
          onPressed: _startGame,
          label: Text('Start game'),
          icon: Icon(Icons.sports_esports),
        ),
      ),
    );
  }
}

class About extends StatelessWidget {
  const About({super.key});
  @override
  Widget build(BuildContext context) {
    List<String> authors = [
      'Marcin Moskal',
      'Kacper Kromka',
      'Piotr Badełek',
      'Szymon Manecki',
      'Przemysław Frąszczak',
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            // This set the position of the inside Container to top-left
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 60, bottom: 0, left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: Text(
                      'About project',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    )),
                    Container(
                        child: Text(
                      '\nManual reflex analyzer is supposed to check your skills by measuring how fast you\'re able to pick green and avoid red boxxes. It\'s a small project for school written in flutter without external libraries.',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    )),
                    Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Text('Authors:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500))),
                    Expanded(
                        child: ListView.builder(
                            itemCount: authors.length,
                            itemBuilder: (context, index) {
                              return Center(
                                  child: Text(authors[index],
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300)));
                            })),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HallOfFame extends StatelessWidget {
  const HallOfFame({super.key});
  @override
  Widget build(BuildContext context) {
    // todo: get from shared_preferences
    Map<String, int> players = {
      'Sterling': 65,
      'Marquis': 55,
      'Briar': 125,
      'Asher': 36,
      'Kori': 25,
      'Dionte': 55,
      'Korbin': 10,
      'Ania': 15,
    };

    // topPlayers = sortMap(players);

    // topPlayers.forEach((k,v) => {
    //   print('klucz: ${k}: wartość: ${v}')
    // });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hall of Fame',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
      body: Container(
        child: Center(
          child: DataTable(columns: [
            DataColumn(label: Text('name')),
            DataColumn(label: Text('points')),
          ], rows: [
            DataRow(cells: [DataCell(Text('name1')), DataCell(Text('1111'))]),
            DataRow(cells: [DataCell(Text('name1')), DataCell(Text('2222'))]),
          ]),
        ),
      ),
    );
  }
}








class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _LoginState createState() => _LoginState();
}
 
class _LoginState extends State<Login> {
  String username = '';
  String pin = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Type your username and pin'),
      ),
      body: Center(child: Column(children: <Widget>[
        Container(
          margin: EdgeInsets.all(40),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Username',
            ),
            onChanged: (text) {
              setState(() {
                username = text;
              });
            },
          )),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'PIN',
            ),
            onChanged: (text) {
              setState(() {
                pin = text;
              });
            },
          )),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () { },
            child: Text('TextButton'),
          )
          )
      ])));
  }
}
