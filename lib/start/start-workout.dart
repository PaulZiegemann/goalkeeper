import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_goalkeeper/database/database-helper.dart';
import 'package:real_goalkeeper/main/goalkeeper-main.dart';
import 'package:real_goalkeeper/models/workout.dart';
import 'package:real_goalkeeper/settings/workout-overview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutStart extends StatefulWidget {
  WorkoutStart({Key key}) : super(key: key);
  @override
  _WorkoutStartState createState() => _WorkoutStartState();
}

class _WorkoutStartState extends State<WorkoutStart> {
  final _formKey = GlobalKey<FormState>();
  DatabaseHelper _dbHelper;
  DateTime now = new DateTime.now();
  String formatDate(DateTime date) => new DateFormat("MMMM EEEE d Hm").format(date);
  Workout _exercise = Workout();
  String currentWk;
  bool s = false;
  var sets = 1;
  var currentSet;
  var reps = '';
  var currentRep;
  var weights = '';
  var currentWeight;
  int setCount = 1;

  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _getCurrentWorkout();
  }

  Future<void> _increaseSets() async {
    if (sets < 10) {
      setState(() {
        sets = sets + 1;
      });
    }
  }

  _getCurrentWorkout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => currentWk = prefs.getString('currentWk'));
    print(currentWk);
  }

  Future<void> _addFinishRepToString(var fRep) async {
    reps = StringUtils.addCharAtPosition(reps, ',$fRep', reps.length);
  }

  Future<void> _addFinishWeightToString(var fWeight) async {
    weights = StringUtils.addCharAtPosition(weights, ',$fWeight', weights.length);
  }

  Future<void> _saveWorkout() async {
    _addToList();
  }

  void _addToList() async {
    _exercise.reps = reps;
    _exercise.sets = (sets - 1).toString();
    _exercise.weight = weights;
    _exercise.date = formatDate(now);
    await _dbHelper.insertWorkout(currentWk, _exercise);
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _increaseSets();
      });
      form.reset();
    }
  }

  String numberValidator(String value) {
    if(value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if(n == null) {
      return '"$value" is not a valid number';
    }
    return null;
  }


  _form() => Container(
      color: Color.fromRGBO(255, 239, 219, 1),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Weight'),
                onSaved: (val) => _addFinishWeightToString(val),
                validator: numberValidator,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Reps'),
                onSaved: (val) => _addFinishRepToString(val),
                validator: numberValidator,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: RaisedButton(
                  onPressed: () => _onSubmit(),
                  child: Text('Submit'),
                  color: Color.fromRGBO(238, 203, 173, 1),
                  textColor: Color.fromRGBO(0, 0, 0, 0.8),
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                      color: Color.fromRGBO(238, 203, 173, 1),
                      textColor: Color.fromRGBO(0, 0, 0, 0.8),
                      child: Text('Finish!'),
                      onPressed: () async {
                        await _saveWorkout();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WorkoutOverview()));
                      }))
            ],
          )));

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GoalkeeperMain()));
          return Future.value(true);
        },
        child: Scaffold(
            backgroundColor: Color.fromRGBO(238, 203, 173, 1),
            appBar: AppBar(
                backgroundColor: Color.fromRGBO(255, 239, 219, 1),
                title:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                    '  $currentWk',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Montserrat',
                        color: Color.fromRGBO(0, 0, 0, 0.8)),
                  ),
                ])),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                        color: Color.fromRGBO(238, 203, 173, 1),
                        child: Text(
                          'Current Set. $sets',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(0, 0, 0, 0.8),
                            backgroundColor: Color.fromRGBO(238, 203, 173, 1),
                          ),
                        ))),
                _form()
              ],
            ))));
  }
}
