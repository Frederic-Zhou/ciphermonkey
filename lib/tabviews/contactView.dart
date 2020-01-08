import 'package:flutter/material.dart';
import 'package:ciphermonkey/model.dart';

class ContactView extends StatefulWidget {
  ContactView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  List<CMKey> pubkeys = [];
  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    Future<List<CMKey>> pubkeyFuture = DB.queryKeys(type: "public");

    pubkeyFuture.then((keys) {
      pubkeys = keys;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      itemCount: pubkeys.length,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            "${pubkeys[index].name}",
            style: Theme.of(context).textTheme.title,
          ),
          subtitle: Text("${pubkeys[index].id}"),
          leading: Text("${(index + 1).toString()}"),
          onTap: () {
            DB.currentPublicKey = pubkeys[index];
            DefaultTabController.of(context).animateTo(1);
          },
        );
      },
    );
  }
}
