import 'package:flutter/material.dart';
import 'package:ciphermonkey/model.dart';

class MindView extends StatefulWidget {
  MindView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MindViewState createState() => _MindViewState();
}

class _MindViewState extends State<MindView> {
  final _formKey = GlobalKey<FormState>();
  bool hasKey = false;
  @override
  void initState() {
    super.initState();
    Future<List<CMKey>> keysFuture =
        DB.queryKeys(id: "", name: "", addtime: "", type: "private");

    keysFuture.then((keys) {
      setState(() {
        hasKey = keys.length > 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Offstage(
                  offstage: hasKey,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Your nickname',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your nickname.';
                      }
                      return null;
                    },
                  )),
              Offstage(
                  offstage: hasKey,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Your password',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter password to encrypt privatekey';
                      }
                      return null;
                    },
                  )),
              Offstage(
                  offstage: hasKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState.validate()) {
                          // Process data.
                        }
                      },
                      child: Text('Create Public Key & Private Key'),
                    ),
                  )),
              Offstage(offstage: !hasKey, child: Text('Public Key:')),
              Offstage(
                  offstage: !hasKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {},
                      child: Text('Send Publick Key to your contacts'),
                    ),
                  )),
            ],
          ),
        ));
  }
}
