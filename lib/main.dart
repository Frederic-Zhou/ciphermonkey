import 'package:flutter/material.dart';
import 'model.dart';
import 'tabviews/contactView.dart';
import 'tabviews/decryptView.dart';
import 'tabviews/encryptView.dart';
import 'tabviews/mindView.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await DB.openDB();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cipher Monkey',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '🙈 Cipher Monkey V1 🙊'),
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
  List<Widget> tabViews = [];
  List<Widget> tabBars = [];

  @override
  void initState() {
    super.initState();
    DB.openDB().then((onValue) {
      setState(() {
        tabViews = [ContactView(), EncryptView(), DecryptView(), MindView()];
        tabBars = [
          Tab(
            text: "🕵🏻‍♂️ Contact",
          ),
          Tab(
            text: "📝 Encrypt",
          ),
          Tab(
            text: "🔐 Decrypt",
          ),
          Tab(
            text: "🔑 Mind",
          )
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabViews.length,
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            bottom: TabBar(
              isScrollable: true,
              tabs: tabBars,
            ),
          ),
          body: TabBarView(
            children: tabViews,
          )),
    );
  }
}
