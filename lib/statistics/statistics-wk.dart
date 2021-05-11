import 'package:flutter/material.dart';
import 'package:real_goalkeeper/database/database-helper.dart';
import 'package:real_goalkeeper/models/data.dart';
import 'package:real_goalkeeper/models/workout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:basic_utils/basic_utils.dart';

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  static const IconData accessibility_new_sharp = IconData(0xeb09, fontFamily: 'MaterialIcons');
  static const IconData account_circle_outlined = IconData(0xe010, fontFamily: 'MaterialIcons');
  static const IconData lunch_dining = IconData(0xe854, fontFamily: 'MaterialIcons');

  Widget barChart = Text("Loading ...");
  Widget PROverview = Text("Loading . . .");
  Workout _emptyWK = Workout();
  List<String> seperateDate0 = [];
  List<String> seperateDate1 = [];
  List<String> seperateDate2 = [];
  String sd1;
  String sd11;
  String sd2;
  String sd21;
  String sd3;
  String sd31;
  List<int> sets123 = [];
  int last3WorkoutSets;
  int set1;
  int set2;
  int set3;
  List<String> last3WorkoutDates = [];
  String date1;
  String date2;
  String date3;
  List<charts.Series<Data, String>> _seriesData;
  List<Workout> _workouts = [];
  List<Data> _data = [];
  String currentWk;
  DatabaseHelper _dbHelper;
  List<String> _reps = [];
  List<String> _weights = [];
  List<String> _dates = [];
  List<int> allW = [];
  List<int> allR = [];
  var newList = [];

  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _seriesData = List<charts.Series<Data, String>>();
    _getCurrentWorkout();
    _getAllWorkouts();
  }

  _getAllWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Workout> w =
        await _dbHelper.fetchWorkout(prefs.getString('currentWk'));
    setState(() {
      _setDefaultWk();
      _workouts = w;
    });
    _getAllReps();
    _getAllWeights();
    _addToList();
  }

  _setDefaultWk() {
    _emptyWK.id = 0;
    _emptyWK.name = 'empty';
    _emptyWK.sets = '1';
    _emptyWK.reps = ',0';
    _emptyWK.weight = ',0';
    _emptyWK.date = 'Nodate ... ... 0000';
  }

  _getCurrentWorkout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String w = prefs.getString('currentWk');
    setState(() {
      currentWk = w;
    });
  }

  _getAllReps() async {
    while (_workouts.length <= 2) {
      _workouts.add(_emptyWK);
    }
    for (int i = 0; i < _workouts.length; i++) {
      _dates.add(_workouts[i].date);
      if (i == _workouts.length - 1) {
        set1 = int.parse(_workouts[_workouts.length - 3].sets);
        sets123.add(set1);
        set2 = int.parse(_workouts[_workouts.length - 2].sets);
        sets123.add(set2);
        set3 = int.parse(_workouts[_workouts.length - 1].sets);
        sets123.add(set3);
        date1 = _workouts[_workouts.length - 3].date;
        last3WorkoutDates.add(date1);
        date2 = _workouts[_workouts.length - 2].date;
        last3WorkoutDates.add(date2);
        date3 = _workouts[_workouts.length - 1].date;
        last3WorkoutDates.add(date3);
        last3WorkoutSets = set1 + set2 + set3;
      }
    }
    String tmpR;
    for (int i = 0; i < _workouts.length; i++) {
      tmpR = _workouts[i].reps;
      int s = 0;
      int e = 1;
      while (e < tmpR.length) {
        if (tmpR[s] == ',') {
          if (tmpR[e] == ',' || e == tmpR.length - 1) {
            if (e == tmpR.length - 1) {
              e++;
            }
            int a = int.parse(tmpR.substring(s + 1, e));
            setState(() {
              allR.add(a);
              _reps.add(tmpR.substring(s + 1, e));
            });
            s = e;
          }
          e++;
        }
      }
    }
  }

  _getAllWeights() {
    String tmpW;
    for (int i = 0; i < _workouts.length; i++) {
      tmpW = _workouts[i].weight;
      int s = 0;
      int e = 1;
      while (e < tmpW.length) {
        if (tmpW[s] == ',') {
          if (tmpW[e] == ',' || e == tmpW.length - 1) {
            if (e == tmpW.length - 1) {
              e++;
            }
            int a = int.parse(tmpW.substring(s + 1, e));
            setState(() {
              allW.add(a);
              _weights.add(tmpW.substring(s + 1, e));
            });
            s = e;
          }
          e++;
        }
      }
    }
  }

  _addToList() {
    //newList = new List.from(allR)..addAll(allW);
    int j = 1;
    int k = 0;
    int wkSets = sets123[0];
    for (int i = ((allW.length) - (last3WorkoutSets)); i < allW.length; i++) {
      if (j <= wkSets) {
        _data.add(new Data(
            rep: allR[i],
            weight: allW[i],
            wXR: (allR[i] + allW[i]),
            cSet: j,
            date: last3WorkoutDates[k]));
        j++;
      }
      if ((j == wkSets + 1) && (i + 1 != allW.length)) {
        wkSets = sets123[k];
        j = 1;
        if(k != last3WorkoutDates.length-1) {
          k ++;
        }
      }
    }

    if (_data.length != 0) {
      seperateDate0 = (_data[0].date.split(new RegExp('\\s+')));
      seperateDate1 = (_data[(set1)].date.split(new RegExp('\\s+')));
      seperateDate2 = (_data[_data.length-1].date.split(new RegExp('\\s+')));
      sd1 = '   ${seperateDate0[0]} ${seperateDate0[2]}';
      sd2 = '   ${seperateDate1[0]} ${seperateDate1[2]}';
      sd3 = '   ${seperateDate2[0]} ${seperateDate2[2]}';
      sd11 = '   ${seperateDate0[1]} ${StringUtils.addCharAtPosition(
          seperateDate0[3], ':', 2)}';
      sd21 = '   ${seperateDate1[1]} ${StringUtils.addCharAtPosition(
          seperateDate1[3], ':', 2)}';
      sd31 = '   ${seperateDate2[1]} ${StringUtils.addCharAtPosition(
          seperateDate2[3], ':', 2)}';
    }

    if (_data.length == 0) {
      int i = 0;
      set1 = 3;
      set2 = 3;
      set3 = 3;
      while (i < 10) {
        _data.add(new Data(rep: 0, weight: 0, wXR: 0, cSet: 0, date: 'noDate'));
        i++;
      }
      sd1 = 'No Workout Records';
      sd2 = 'No Workout Records';
      sd3 = 'No Workout Records';
      sd11 = '';
      sd21 = '';
      sd31 = '';

    }

    setState(() {
      _seriesData.add(
        charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
          id: '${_data[0].date}',
          data: _data.sublist(0, (set1)),
          domainFn: (Data data, _) => 'Set. ${data.cSet}',
          measureFn: (Data data, _) => data.wXR,
        ),
      );
      _seriesData.add(
        charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff109618)),
          id: '${_data[(set1)].date}',
          data: _data.sublist((set1), (set1 + set2)),
          domainFn: (Data data, _) => 'Set. ${data.cSet}',
          measureFn: (Data data, _) => data.wXR,
        ),
      );
      _seriesData.add(
        charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xffff9900)),
          id: '${_data[_data.length-1].date}',
          data: _data.sublist(
            (set1 + set2),
          ),
          domainFn: (Data data, _) => 'Set. ${data.cSet}',
          measureFn: (Data data, _) => data.wXR,
        ),
      );
      barChart = Text("Loading ...");
      _displayChart();
      _prOverview();
    });
  }

  _prOverview(){
    PROverview = Padding(
        padding: EdgeInsets.all(8.0),
    child: Container(
    child: Center(
    child: Column(
    children: <Widget>[
    Container(
    padding: EdgeInsets.all(8.0),
    child: Text(
    'Comparing your personal best to your current Performance',
    textAlign: TextAlign.center,
    style: TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: Color.fromRGBO(0, 0, 0, 0.8),
    ),
    ),
    ),
    ],),),),);
  }


  _displayChart() {
    barChart = Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
              child: Text(
                'Comparing your performance for the last 3 $currentWk sessions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 0, 0, 0.8),
                ),
              ),
          ),
              Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                   Column(crossAxisAlignment: CrossAxisAlignment.center,
                       children: <Widget>[
                    const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: const DecoratedBox(
                        decoration:
                            const BoxDecoration(color: Color(0xff990099)),
                      ),
                    ),
                    Text('   $sd1',style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                    ),),
                    Text('   $sd11',style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                    ),),
                  ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: const DecoratedBox(
                        decoration:
                            const BoxDecoration(color: Color(0xff109618)),
                      ),
                    ),
                    Text('  $sd2',
                      style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                    ),),
                    Text('   $sd21',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.0,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                      ),),
                  ]),
                  Column(children: <Widget>[
                    const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: const DecoratedBox(
                        decoration:
                            const BoxDecoration(color: Color(0xffff9900)),
                      ),
                    ),
                    Text('   $sd3',style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                    ),),
                    Text('   $sd31',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.0,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                      ),),
                  ]),
                ],
              )),
              Expanded(
                child: charts.BarChart(
                  _seriesData,
                  barGroupingType: charts.BarGroupingType.grouped,
                  animate: true,
                  animationDuration: Duration(seconds: 5),
                  behaviors: [
                    new charts.ChartTitle('sets',
                        behaviorPosition: charts.BehaviorPosition.bottom,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea),
                    new charts.ChartTitle('Weight + Rep',
                        behaviorPosition: charts.BehaviorPosition.start,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea),
                  ],
                ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(238, 203, 173, 1),
          bottom: TabBar(
            indicatorColor: Color(0xff9962D0),
            tabs: [
              Tab(
                child: Icon(
                    accessibility_new_sharp),
              ),
              Tab(
                child: Icon(
                    account_circle_outlined),
              ),
              Tab(
                child: Icon(
                    lunch_dining),
              ),
            ],
          ),
          title: Text(
            'Performance - $currentWk',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(139, 139, 131, 0.8),
              backgroundColor: Color.fromRGBO(238, 203, 173, 1),
            ),
          ),
        ),
        body: TabBarView(children: [
          barChart,
          PROverview,
          Container(),
        ]),
      ),
    );
  }
}
