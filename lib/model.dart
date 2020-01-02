import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static Future<Database> instance;

  static void openDB() async {
    // Open the database and store the reference.
    instance = openDatabase(
      join(await getDatabasesPath(), 'ciphermonkey.db'),
      onCreate: (db, version) {
        print("create db\n");
        return db.execute(
          "CREATE TABLE keys(id TEXT PRIMARY KEY, name TEXT, key TEXT, type TEXT)",
        );
      },
      version: 1,
    );
  }
}

class PublicKey {
  final String id;
  final String name;
  final String key;

  PublicKey({this.id, this.name, this.key});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'key': key,
    };
  }

  @override
  String toString() {
    return 'publickey{id: $id, name: $name, key: $key}';
  }
}

class PrivateKey {
  final String id;
  final String name;
  final String key;

  PrivateKey({this.id, this.name, this.key});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'key': key,
    };
  }

  @override
  String toString() {
    return 'privatekey{id: $id, name: $name, key: $key}';
  }
}
