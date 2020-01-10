import 'package:flutter/material.dart';
import 'package:ciphermonkey/model.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import 'package:ciphermonkey/en-de-crypt.dart';

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
      //print(keys.length);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ListView.builder(
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
            subtitle: Text(
                "ID: ${pubkeys[index].id.toUpperCase()}\nMD5: ${md5String(pubkeys[index].value).toUpperCase()}"),
            leading: Text("${(index + 1).toString()}"),
            onTap: () {},
          );
        },
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Future<ClipboardData> clipboard = Clipboard.getData("text/plain");

          clipboard.then((clipboard) {
            try {
              List<String> contact = discombinPublicKey(clipboard.text);

              DB.addKey(CMKey(
                  id: contact[0],
                  name: contact[1],
                  value: contact[2],
                  type: "public",
                  addtime: DateTime.now().toIso8601String()));

              refresh();
              Toast.show("Add Successed!!", context,
                  duration: Toast.LENGTH_LONG,
                  gravity: Toast.CENTER,
                  backgroundColor: Colors.grey);
            } catch (e) {
              Toast.show("Add Fail!!", context,
                  duration: Toast.LENGTH_LONG,
                  gravity: Toast.CENTER,
                  backgroundColor: Colors.red);
            }
          });
        },
        label: Text('Add From Clipboard'),
        icon: Icon(Icons.add_circle),
        backgroundColor: Colors.green,
      ),
    );
  }
}
