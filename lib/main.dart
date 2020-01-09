import 'package:flutter/material.dart';
import 'globels.dart';
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
      title: 'Cipher Monkey',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '🙈 Cipher Monkey 🙊'),
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
  void initState() {
    super.initState();

    setState(() {});
  }

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
              ],
            ),
          ),
          body: TabBarView(
            children: tabViews,
          )),
    );
  }
}
