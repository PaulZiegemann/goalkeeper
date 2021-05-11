
class Workout {
  static const colId = 'id';
  static const colName = 'name';
  static const colRep = 'reps';
  static const colWeight = 'weight';
  static const colDate = 'date';
  static const colSet = 'sets';

  Workout({this.id, this.name, this.sets, this.reps, this.weight, this.date});

  int id;
  String name;
  String sets;
  String weight;
  String reps;
  String date;

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{colName: name, colSet: sets, colWeight: weight, colRep: reps, colDate: date};
    if (id != null) map[colId] = id;
    return map;
  }

  Workout.fromMap(Map<String, dynamic> map){
    id= map[colId];
    name = map[colName];
    sets = map[colSet];
    weight = map[colWeight];
    reps = map[colRep];
    date = map[colDate];
  }

}