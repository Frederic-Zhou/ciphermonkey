import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class DecryptView extends StatefulWidget {
  DecryptView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DecryptViewState createState() => _DecryptViewState();
}

class _DecryptViewState extends State<DecryptView> {
  final _formKey = GlobalKey<FormState>();

  String plainText = "";
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
            children: <Widget>[
              RaisedButton(
                child: Text('Decrypt From Clipboard',
                    style: TextStyle(color: Colors.white)),
                color: Colors.blue,
                onPressed: () async {
                  ClipboardData clipboard =
                      await Clipboard.getData("text/plain");

                  print(clipboard.text);
                  setState(() {});
                },
              ),
              RaisedButton(
                child: Text('Copy Plain Text to Clipboard',
                    style: TextStyle(color: Colors.white)),
                color: Colors.green,
                onPressed: () {
                  if (plainText.length > 0) {
                    Future<void> clipboard =
                        Clipboard.setData(ClipboardData(text: plainText));

                    clipboard.then((noValue) {
                      Toast.show("Copy to Clipboard Successed!!", context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                    });
                  } else {
                    Toast.show("Decrypt first", context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                  }
                  setState(() {});
                },
              ),
              Text("Plain Text:$plainText")
            ],
          ),
        ));
  }
}
