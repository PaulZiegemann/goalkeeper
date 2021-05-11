import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:real_goalkeeper/database/database-helper.dart';
import 'package:real_goalkeeper/main/goalkeeper-main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash.dart';

bool usernameSet;

void main() => runApp(new IntroUserInput());

class IntroUserInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      color: Color.fromRGBO(238, 203, 173, 1),
      home: new Splash(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  DatabaseHelper _dbHelper;
  String username = '';

  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
  }

  _saveUser(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Username', username);
  }

  _addSessionCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('SessionCount', 0);
  }

  _goToGKMain(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoalkeeperMain()),
    );
  }

  _createEmptyOverview() async{
    await _dbHelper.createOverviewTable();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 239, 219, 1),
          title: Center(
              child: Text(
                "Goalkeeper - Enter your name",
                style: TextStyle(
                    fontSize: 23,
                    fontFamily: 'Montserrat',
                    color: Color.fromRGBO(139, 139, 131, 0.8)),
              ))),
      body: Container(
          alignment: Alignment.center,
          child: TextFormField(
            /*onChanged: (String val)*/
              onChanged: (val) async => setState(() => username = val),
              validator: (val) =>
              (val.length == 0 ? 'This field is required' : null),
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'GoalKeeper will call you like that from now on',
                icon: Icon(Icons.face),
              ))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(238, 203, 173, 1),
        child: Icon(Icons.check),
        onPressed: () async {
          await _saveUser(username);
          await _addSessionCount();
          await _createEmptyOverview();
          _goToGKMain(context);
        },
      ),
    );
  }
}