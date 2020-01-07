import 'package:flutter/material.dart';
import 'tabviews/contactView.dart';
import 'tabviews/decryptView.dart';
import 'tabviews/encryptView.dart';
import 'tabviews/mindView.dart';

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
            children: [ContactView(), EncryptView(), DecryptView(), MindView()],
          ) // This trailing comma makes auto-formatting nicer for build methods.
          ),
    );
  }
}
