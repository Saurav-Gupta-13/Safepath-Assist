class Tcontact {
  int? _id;
  String? _number;
  String? _name;
  Tcontact(this._number, this._name);
  Tcontact.withid(this._id, this._number, this._name);
  //getters
  int get id => _id!;
  String get number => _number!;
  String get name => _name!;
  @override
  String toString() {
    return 'Contact: {id: $_id,name: $_name,number:$_number}';
  }

  //setters
  set number(String newNumber) => this._number = newNumber;
  set name(String newName) => this._name = newName;
  //convert a Contact object to a Map object
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = this._id;
    map['name'] = this._name;
    map['number'] = this._number;
    return map;
  }

  Tcontact.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._number = map['number'];
    this._name = map['name'];
  }
}
