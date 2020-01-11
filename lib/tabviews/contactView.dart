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
      if (keys.length == 0) {
        DefaultTabController.of(context).animateTo(3);
      }
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("ID:${pubkeys[index].id.toUpperCase()}",
                    style: TextStyle(fontSize: 12)),
                Text(
                    "FP:${md5String(combinPublicKey(pubkeys[index].id, pubkeys[index].name, pubkeys[index].value)).toUpperCase()}",
                    style: TextStyle(fontSize: 12)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey,
              ),
              onPressed: () {
                //DB.delKey(pubkeys[index].id);
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Are Sure DELETE ??'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('It will be DELETE FOREVER!!!'),
                            Text(
                                'if the key is yourself, the private key will be delete also.'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            'SURE',
                          ),
                          onPressed: () {
                            DB.delKey(pubkeys[index].id);
                            DB.delKey(pubkeys[index].id + ".private");
                            Navigator.of(context).pop();
                            refresh();
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
            onTap: () {},
          );
        },
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Future<ClipboardData> clipboard = Clipboard.getData("text/plain");

          clipboard.then((clipboard) async {
            try {
              List<String> contact = discombinPublicKey(clipboard.text);

              await DB.addKey(CMKey(
                  id: contact[0],
                  name: contact[1],
                  value: contact[2],
                  type: "public",
                  addtime: DateTime.now().toIso8601String()));

              refresh();
              Toast.show("Add Successed!!", context,
                  duration: Toast.LENGTH_LONG,
                  gravity: Toast.CENTER,
                  backgroundColor: Colors.blueGrey);
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
