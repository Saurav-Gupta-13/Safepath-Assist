import 'package:sqflite/sqflite.dart';
import 'package:safepath_assist/model/contactsm.dart';

class DatabaseHelper {
  String contactTable = 'contact_table';
  String colId = 'id';
  String colContactName = 'name';
  String colContactNumber = 'number';

  DatabaseHelper._createInstance();

  static DatabaseHelper? _databaseHelper;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }
  static Database? _database;
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String directoryPath = await getDatabasesPath();
    String dbLocation = directoryPath + 'contacts.db';
    var contactDatabase =
        await openDatabase(dbLocation, version: 1, onCreate: _createDbTable);
    return contactDatabase;
  }

  void _createDbTable(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $contactTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colContactName TEXT, $colContactNumber Text)');
  }

  Future<List<Map<String, dynamic>>> getContactMapList() async {
    Database db = await this.database;
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT * FROM $contactTable order by $colId ASC');
    return result;
  }

  Future<int> insertContact(Tcontact contact) async {
    Database db = await this.database;
    var result = await db.insert(contactTable, contact.toMap());
    // print(await db.query(contactTable));
    return result;
  }

  Future<int> updateContact(Tcontact contact) async {
    Database db = await this.database;
    var result = await db.update(contactTable, contact.toMap(),
        where: '$colId = ?', whereArgs: [contact.id]);
    return result;
  }

  Future<int> deleteContact(int id) async {
    Database db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $contactTable WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $contactTable');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  Future<List<Tcontact>> getContactList() async {
    var contactMapList =
        await getContactMapList(); // Get 'Map List' from database
    int count =
        contactMapList.length; // Count the number of map entries in db table

    List<Tcontact> contactList = <Tcontact>[];
    // For loop to create a 'Contact List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      contactList.add(Tcontact.fromMapObject(contactMapList[i]));
    }

    return contactList;
  }
}
