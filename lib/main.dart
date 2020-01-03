import 'package:flutter/material.dart';
import 'myHomePage.dart';
import 'model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.openDB();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Contact'),
      debugShowCheckedModeBanner: false,
    );
  }
}
