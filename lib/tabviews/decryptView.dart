import 'package:flutter/material.dart';

class DecryptView extends StatefulWidget {
  DecryptView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DecryptViewState createState() => _DecryptViewState();
}

class _DecryptViewState extends State<DecryptView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      itemCount: 10,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        final item = index.toString() + "item";

        return ListTile(
          title: Text(
            item,
            style: Theme.of(context).textTheme.headline,
          ),
        );
      },
    );
  }
}
