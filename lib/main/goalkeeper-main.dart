import 'package:flutter/material.dart';
import 'package:real_goalkeeper/database/database-helper.dart';
import 'package:real_goalkeeper/models/session.dart';
import 'package:real_goalkeeper/settings/workout-overview.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GoalkeeperMain extends StatefulWidget {
  @override
  _GoalkeeperMainState createState() => _GoalkeeperMainState();
}

class _GoalkeeperMainState extends State<GoalkeeperMain> {

  int sessionCount;
  String usernameWelcome = '';
  DatabaseHelper _dbHelper;
  Session _session = Session();
  List<Session> _sessions = [];

  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _getWelcomingScreen();
    _refreshSessionList();
    //_negateSeen();
  }

  Future _negateSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seen', false);
  }

  Future<void> _getWelcomingScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('Username');
    setState(() => usernameWelcome = 'Welcome $userID');
  }

  Future<void> _refreshSessionList() async {
    List<Session> x = await _dbHelper.fetchSession();
    setState(() {
      _sessions = x;
    });
  }

  /*_getSessionCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => sessionCount = prefs.getInt('SessionCount'));
  }*/

  Future<void> _removeSession(int id, String overview) async {

    await _dbHelper.deleteSession(id);
    await _dbHelper.altDeleteOverview(overview);
    _refreshSessionList();
  }

  Future<void> _saveSessionForWS(String session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentSession', session);
  }

  Future<void> _createSession(Session session) async {
    await _dbHelper.insertSession(session);
  }


  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('WorkoutDay'),
            content: TextFormField(
              decoration: InputDecoration(
                hintText: 'Session',
              ),
              onChanged: (val) async => setState(() => _session.day = val),
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Create'),
                  onPressed: () async {
                    await _createSession(_session);
                    _refreshSessionList();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  Future<void> _showAlertForDelete(String session, int id) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure to delete this session?'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Yes, delete this session'),
                  onPressed: () async {
                    await _removeSession(id, session);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoalkeeperMain()));
                  }),
              FlatButton(
                  child: Text('No, do not delete this session'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoalkeeperMain()));
                  })
            ],
          );
        });
  }

  Widget displayIt(String title, int id) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Color.fromRGBO(238, 203, 173, 1),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12.0),
          title: Text(title,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 30.0,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(139, 139, 131, 0.8),
              )),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Material(
              color: Color.fromRGBO(238, 203, 173, 1),
              child: IconButton(
                  icon: Icon(Icons.fitness_center),
                  iconSize: 35,
                  onPressed: () async{
                    await _saveSessionForWS(title);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => WorkoutOverview()));
                  }),
            ),
            Material(
              color: Color.fromRGBO(238, 203, 173, 1),
              child: IconButton(
                  icon: Icon(Icons.assessment),
                  iconSize: 35,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoalkeeperMain()));
                  }),
            ),
            Material(
                color: Color.fromRGBO(238, 203, 173, 1),
                child: IconButton(
                    icon: Icon(Icons.delete_outline),
                    iconSize: 35,
                    onPressed: () {
                      _showAlertForDelete(title, id);
                    }))
          ]),
        ));
  }

    Widget build(BuildContext context) {
      return Scaffold(
          backgroundColor: Color.fromRGBO(240, 248, 255, 1),
          appBar: AppBar(
              backgroundColor: Color.fromRGBO(255, 239, 219, 1),
              title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  '  $usernameWelcome',
                  style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Montserrat',
                      color: Color.fromRGBO(139, 139, 131, 0.8)),
                )
              ])),
          body: Column(children: <Widget>[
            Expanded(
                child: new ListView.builder(
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      return displayIt(_sessions[index].day, _sessions[index].id);
                    })),
            Align(
                alignment: Alignment(0.9, 0.9),
                child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Color.fromRGBO(255, 239, 219, 1),
                    child: IconButton(
                      onPressed: () {
                        _displayDialog(context);
                      },
                      icon: Icon(Icons.add),
                      iconSize: 48,
                      color: Color.fromRGBO(139, 139, 131, 0.8),
                    )))
          ]),
        );
  }
}
