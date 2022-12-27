import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:collection';
import 'dart:math';

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
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 15),
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
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => HallOfFame()));
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

  var sortedEntries = data.entries.toList()..sort((e1, e2) {
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

  void _startGame() {
    setState(() {
      _is_game_playing = true;
    });
  }


  bool _showButton() {
    if (_is_game_playing) { return false; }
    if (_is_logged_in) { return false; }

    return true;
  }



  @override
  Widget build(BuildContext context) {

    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    String main_message = '';

    if (_is_logged_in) {
      main_message =  "hello, you currently play as ${_who_is_logged_in}";
    } else {
      main_message =  "To play you need to login";
    }


    double height = (MediaQuery.of(context).size.height);
    double width = (MediaQuery.of(context).size.width);

    var rng = Random();
    double wrand = rng.nextDouble() * width;
    double hrand = rng.nextDouble() * height;


    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        actions: <Widget>[
          TextButton(
            style: style,
            onPressed: () {},
            child: Text(main_message),
          ),
        ],
      ),
      drawer: NavDrawer(),
      body: Container(
        child: Stack(
          children: [
            Positioned(
              top: hrand,
              left: wrand,
              child: TextButton(
                child: Text('      '),
                onPressed: () { print('Pressed'); },
                style: TextButton.styleFrom(
                         primary: Colors.red,
                         backgroundColor: Colors.red,
                         onSurface: Colors.red,
                       ),
              ),
            ),
          ]
        )
      ),
      floatingActionButton: Visibility(
        visible: _showButton(),
        child:  FloatingActionButton.extended(
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
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Container(
        alignment: Alignment.centerRight,
        child: Align(
          alignment: Alignment.centerRight,
          child: ListView.builder(
            itemCount: authors.length,
            prototypeItem: ListTile(
              title: Text(authors.first),
            ),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(authors[index]),
              );
            },
          ),
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
          child: DataTable(
            columns: [
              DataColumn(label: Text('name')),
              DataColumn(label: Text('points')),
          ], rows: [
            DataRow(cells: [ DataCell(Text('name1')),  DataCell(Text('1111'))]),
            DataRow(cells: [ DataCell(Text('name1')),  DataCell(Text('2222'))]),
          ]),
        ),
      ),
    );
  }
}

