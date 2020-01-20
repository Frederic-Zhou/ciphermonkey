import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:CipherMonkey/model.dart';
import 'package:CipherMonkey/en-de-crypt.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class MindView extends StatefulWidget {
  MindView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MindViewState createState() => _MindViewState();
}

class _MindViewState extends State<MindView> {
  final _formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();

  String pubkeyString = "";
  String pubID = "";
  String pubNickname = "";
  bool hasKey = false;
  bool loading = true;
  @override
  void initState() {
    super.initState();

    refresh();
  }

  void refresh() {
    Future<List<CMKey>> prikeyFuture = DB.queryKeys(type: "private");

    prikeyFuture.then((prikeys) {
      hasKey = prikeys.length > 0;
      if (hasKey) {
        Future<List<CMKey>> pubkeyFuture = DB.queryKeys(
            id: prikeys[0].id.substring(0, prikeys[0].id.indexOf(".")),
            type: "public");

        pubkeyFuture.then((pubkeys) {
          if (pubkeys.length > 0) {
            pubkeyString = pubkeys[0].value;
            pubID = pubkeys[0].id;
            pubNickname = pubkeys[0].name;
            setState(() {});
          }
        });
      }
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
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: nicknameController,
                        decoration: const InputDecoration(
                            hintText: 'Your nickname',
                            contentPadding: EdgeInsets.all(10.0),
                            fillColor: Colors.amberAccent,
                            filled: true,
                            border: OutlineInputBorder()),
                        validator: (value) {
                          Pattern pattern = r'^[a-zA-Z0-9_]{2,20}$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(value.trim())) {
                            return 'Enter your nickname(a-z and 0-9)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                            hintText: 'Your password',
                            contentPadding: EdgeInsets.all(10.0),
                            fillColor: Colors.amberAccent,
                            filled: true,
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        validator: (value) {
                          Pattern pattern = r'^.{6,20}$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(value.trim())) {
                            return 'Please enter password to encrypt privatekey, (6~20 chats)';
                          }

                          return null;
                        },
                      ),
                      RaisedButton(
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.

                          if (_formKey.currentState.validate() && !hasKey) {
                            // 生成 pubkey和prikey.

                            Future(() {
                              hasKey = true;
                            }).then((_) {
                              createKey();
                            });
                          }
                        },
                        child: Text('Create Public Key & Private Key',
                            style: TextStyle(color: Colors.white)),
                        color: Colors.blue,
                      ),
                    ],
                  )),
              Offstage(
                  offstage: !hasKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "NAME: $pubNickname",
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      Text("ID: ${pubID.toUpperCase()}",
                          style:
                              TextStyle(fontSize: 14, color: Colors.blueGrey)),
                      Text(
                          "FP: ${md5String(combinPublicKey(pubID, pubNickname, pubkeyString)).toUpperCase()}",
                          style:
                              TextStyle(fontSize: 14, color: Colors.blueGrey)),
                      Text(
                        "🔑 PUBLIC KEY 🔑",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Divider(
                        thickness: 0,
                        color: Colors.grey,
                      ),
                      Text(
                        "${combinPublicKey(pubID, pubNickname, pubkeyString)}",
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                        maxLines: 5,
                        overflow: TextOverflow.fade,
                      ),
                      RaisedButton(
                        onPressed: () {
                          String pubTxt =
                              combinPublicKey(pubID, pubNickname, pubkeyString);

                          Future<void> clipboard =
                              Clipboard.setData(ClipboardData(text: pubTxt));

                          clipboard.then((noValue) {
                            Toast.show("Copy to Clipboard Successed!!", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.CENTER,
                                backgroundColor: Colors.blueGrey);
                          });
                        },
                        child: Text('Copy public key to Clipboard',
                            style: TextStyle(color: Colors.white)),
                        color: Colors.green,
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }

  void createKey() {
    var pair = generateRSAkeyPair();
    String pubkey = encodePublicKeyToPem(pair.publicKey);
    String prikey = encodePrivateKeyToPem(pair.privateKey);

    String id = md5String(pubkey + prikey + DateTime.now().toIso8601String());

    String name = nicknameController.text.trim();

    CMKey pubCMkey = CMKey(
        id: id,
        name: name,
        remark: 'Yourself',
        addtime: DateTime.now().toIso8601String(),
        type: "public",
        value: pubkey);
    CMKey priCMkey = CMKey(
        id: "$id.private",
        name: name,
        addtime: DateTime.now().toIso8601String(),
        type: "private",
        value: aesEncrypt(prikey,
            base64Encode(md5String(passwordController.text).codeUnits)));

    DB.addKey(pubCMkey);
    DB.addKey(priCMkey);
    refresh();
  }
}
