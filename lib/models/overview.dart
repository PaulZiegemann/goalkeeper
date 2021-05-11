
class Overview{

  static const colTbl = 'Overview';
  static const colId = 'id';
  static const colSession = 'session';
  static const colWorkout = 'workout';

  Overview({this.id, this.session, this.workout});

  int id;
  String session;
  String workout;

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{colSession: session, colWorkout: workout};
    if (id != null) map[colId] = id;
    return map;
  }

  Overview.fromMap(Map<String, dynamic> map){
    id= map[colId];
    session = map[colSession];
    workout = map[colWorkout];
  }

}