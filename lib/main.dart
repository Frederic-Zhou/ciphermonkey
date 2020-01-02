import 'package:flutter/material.dart';
import 'tabviews/contactView.dart';
import 'tabviews/decryptView.dart';
import 'tabviews/encryptView.dart';
import 'tabviews/mindView.dart';

void main() => runApp(MyApp());

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  text: "密联人",
                ),
                Tab(
                  text: "解密",
                ),
                Tab(
                  text: "加密",
                ),
                Tab(
                  text: "我的",
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [ContactView(), DecryptView(), EncryptView(), MindView()],
          ) // This trailing comma makes auto-formatting nicer for build methods.
          ),
    );
  }
}
