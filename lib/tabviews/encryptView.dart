import 'package:flutter/material.dart';

class EncryptView extends StatefulWidget {
  EncryptView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EncryptViewState createState() => _EncryptViewState();
}

class _EncryptViewState extends State<EncryptView> {
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
