import 'package:flutter/material.dart';
import 'myHomePage.dart';
import 'model.dart';

void main() async {
  //初始化数据库
  DB.openDB();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '密联本',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '密联本'),
      debugShowCheckedModeBanner: false,
    );
  }
}
