
class Session {

  static const colTbl = 'Session';
  static const colId = 'id';
  static const colName = 'session';

  Session({this.id, this.day});

  int id;
  String day;

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{colName: day};
    if (id != null) map[colId] = id;
    return map;
  }

  Session.fromMap(Map<String, dynamic> map){
    id= map[colId];
    day = map[colName];
  }

}