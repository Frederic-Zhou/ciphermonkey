import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static Database instance;

  static Future openDB() async {
    instance = await openDatabase(
        join(await getDatabasesPath(), 'ciphermonkey.db'),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
        "CREATE TABLE keys(id TEXT PRIMARY KEY, name TEXT, value TEXT, addtime TEXT, type TEXT)",
      );
    });
  }

  //获取键列表
  static Future<List<CMKey>> getKeys() async {
    final List<Map<String, dynamic>> maps = await instance.query('keys');
    return List.generate(maps.length, (i) {
      return CMKey(
        id: maps[i]['id'],
        name: maps[i]['name'],
        value: maps[i]['value'],
        addtime: maps[i]['addtime'],
        type: maps[i]['type'],
      );
    });
  }

  //查询键列表
  static Future<List<CMKey>> queryKeys(
      String id, String name, String addtime, String type) async {
    List<String> whereList = [];
    List<String> whereArgList = [];
    if (id != "") {
      whereList.add("id=?");
      whereArgList.add(id);
    }
    if (name != "") {
      whereList.add("name=?");
      whereArgList.add(name);
    }
    if (addtime != "") {
      whereList.add("addtime=?");
      whereArgList.add(addtime);
    }
    if (type != "") {
      whereList.add("type=?");
      whereArgList.add(type);
    }

    final List<Map<String, dynamic>> maps = await instance.query('keys',
        where: whereList.join(" OR "), whereArgs: whereArgList);
    return List.generate(maps.length, (i) {
      return CMKey(
        id: maps[i]['id'],
        name: maps[i]['name'],
        value: maps[i]['value'],
        addtime: maps[i]['addtime'],
        type: maps[i]['type'],
      );
    });
  }

  //添加键
  static Future<void> addKey(CMKey key) async {
    await instance.insert(
      'keys',
      key.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //修改键
  static Future<void> modKey(CMKey key) async {
    await instance.update(
      'keys',
      key.toMap(),
      where: "id = ?",
      whereArgs: [key.id],
    );
  }

  //删除键
  static Future<void> delKey(String id) async {
    await instance.delete(
      'keys',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  //关闭数据库
  static closeDB() async {
    await instance.close();
  }
}

class CMKey {
  final String id;
  final String name;
  final String value;
  final String addtime;
  final String type;

  CMKey({this.id, this.name, this.value, this.addtime, this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'addtime': addtime,
      'type': type
    };
  }

  @override
  String toString() {
    return 'key{id: $id, name: $name, value: $value, addtime:$addtime, type:$type}';
  }
}
