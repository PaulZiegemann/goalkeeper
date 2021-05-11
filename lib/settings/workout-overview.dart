import 'package:flutter/material.dart';
import 'package:real_goalkeeper/database/database-helper.dart';
import 'package:real_goalkeeper/main/goalkeeper-main.dart';
import 'package:real_goalkeeper/models/overview.dart';
import 'package:real_goalkeeper/start/start-workout.dart';
import 'package:real_goalkeeper/statistics/statistics-wk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutOverview extends StatefulWidget {
  @override
  _WorkoutOverviewState createState() => _WorkoutOverviewState();
}

class _WorkoutOverviewState extends State<WorkoutOverview> {
  DatabaseHelper _dbHelper;
  Overview _overview = Overview();
  List<Overview> _overviews = [];
  String currentSession;
  String currentWorkout;
  String newWorkout;

  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _getCurrentSession();
    _refreshOverview();
    _setOverviewCurrentSession();
  }

  _setOverviewCurrentSession() async {
    _overview.session = currentSession;
  }

  _getCurrentSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => currentSession = prefs.getString('currentSession'));
  }

  _getCurrentWorkout(String wk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentWk', wk);
  }

  _refreshOverview() async {
    _overviews = [];
    List<Overview> x = await _dbHelper.fetchOverview();
    for (int i = 0; i < x.length; i++) {
      if (x[i].session == currentSession) {
        setState(() {
          _overviews.add(x[i]);
        });
      }
    }
  }

  _checkIfTablesIsCreated(String t) async{
    bool s = false;
    List<String> _wkList = await _dbHelper.getAllWorkouts();
    for(int i = 0; i < _wkList.length; i++){
      if(_wkList[i] == t){
        s=true;
      }
    }
    if(s == false) {
      _dbHelper.createWorkout(t);
    }
  }

  Future<void> _setWorkoutForSession(Overview overview) async {
    overview.session = currentSession;
    await _dbHelper.insertOverview(overview);
    setState(() {
      _refreshOverview();
    });
  }

  Future<void> _showAlertForDelete(String session) async {
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
                    await _dbHelper.deleteAllWorkouts(session);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WorkoutOverview()));
                  }),
              FlatButton(
                  child: Text('No, do not delete this session'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WorkoutOverview()));
                  })
            ],
          );
        });
  }

  Widget displayIt(String title) {
    return Center(
        child: Card(
            color: Color.fromRGBO(238, 203, 173, 1),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              //padding: EdgeInsets.symmetric(horizontal: 20),
              //color: Color.fromRGBO(238, 203, 173, 1),
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                title: Text(title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(139, 139, 131, 0.8),
                      backgroundColor: Color.fromRGBO(238, 203, 173, 1),
                    )),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Material(
                  color: Color.fromRGBO(238, 203, 173, 1),
                  child: IconButton(
                      icon: Icon(Icons.assessment),
                      iconSize: 35,
                      onPressed: () {
                        _getCurrentWorkout(title);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Statistics()));
                      }),
                ),                  Material(
                    color: Color.fromRGBO(238, 203, 173, 1),
                    child: IconButton(
                        icon: Icon(Icons.delete),
                        iconSize: 35,
                        onPressed: () async {
                          await _showAlertForDelete(title);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WorkoutOverview()));
                        }),
                  )
                ]),
              ),
              FlatButton(
                  color: Color.fromRGBO(255, 218, 185, 1),
                  child: Text('Start!'),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 184),
                  onPressed: () async {
                    _getCurrentWorkout(title);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WorkoutStart()));
                  }),
            ])));
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Name of your exercise'),
            content: TextFormField(
                decoration: InputDecoration(
                  hintText: 'exercise',
                ),
                onChanged: (val) async =>
                    setState(() => _overview.workout = val)),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Create'),
                  onPressed: () async {
                    setState(() {
                      _setWorkoutForSession(_overview);
                    });
                    _checkIfTablesIsCreated(_overview.workout);
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Color.fromRGBO(240, 248, 255, 1),
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 239, 219, 1),
          title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(
              '  Plan your $currentSession',
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Montserrat',
                  color: Color.fromRGBO(139, 139, 131, 0.8)),
            )
          ])),
      body: Center(
          child: Column(children: <Widget>[
        Expanded(
            child: new ListView.builder(
                itemCount: _overviews.length,
                itemBuilder: (context, index) {
                  return displayIt(_overviews[index].workout);
                })),
        Align(
            child: RaisedButton(
              child: Text('Add an exercise!'),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 160),
              onPressed: () {
                _displayDialog(context);
              },
            ),
            alignment: Alignment(0, 0.8))
      ])),
    ));
  }
}
