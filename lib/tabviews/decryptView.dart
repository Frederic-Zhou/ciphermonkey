import 'package:flutter/material.dart';

class DecryptView extends StatefulWidget {
  DecryptView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DecryptViewState createState() => _DecryptViewState();
}

class _DecryptViewState extends State<DecryptView> {
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //    DefaultTabController.of(context).animateTo(0);
    return Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[],
          ),
        ));
  }
}
