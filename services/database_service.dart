import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/emergency_contact.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'emergency_contacts';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'emergency_safety.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertContact(EmergencyContact contact) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      
      final result = await db.insert(
        _tableName,
        {
          'name': contact.name,
          'phone_number': contact.phoneNumber,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('Contact inserted with ID: $result');
      return result;
    } catch (e) {
      print('Error inserting contact: $e');
      rethrow;
    }
  }

  Future<List<EmergencyContact>> getAllContacts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'name ASC',
      );
      
      return List.generate(maps.length, (i) {
        return EmergencyContact.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting all contacts: $e');
      return [];
    }
  }

  Future<EmergencyContact?> getContactById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return EmergencyContact.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting contact by ID: $e');
      return null;
    }
  }

  Future<int> updateContact(EmergencyContact contact) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      
      final result = await db.update(
        _tableName,
        {
          'name': contact.name,
          'phone_number': contact.phoneNumber,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [contact.id],
      );
      
      print('Contact updated. Rows affected: $result');
      return result;
    } catch (e) {
      print('Error updating contact: $e');
      rethrow;
    }
  }

  Future<int> deleteContact(int id) async {
    try {
      final db = await database;
      
      final result = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('Contact deleted. Rows affected: $result');
      return result;
    } catch (e) {
      print('Error deleting contact: $e');
      rethrow;
    }
  }

  Future<int> deleteAllContacts() async {
    try {
      final db = await database;
      
      final result = await db.delete(_tableName);
      
      print('All contacts deleted. Rows affected: $result');
      return result;
    } catch (e) {
      print('Error deleting all contacts: $e');
      rethrow;
    }
  }

  Future<int> getContactCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting contact count: $e');
      return 0;
    }
  }

  Future<bool> contactExists(String phoneNumber) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'phone_number = ?',
        whereArgs: [phoneNumber],
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking if contact exists: $e');
      return false;
    }
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
