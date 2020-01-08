import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ciphermonkey/model.dart';
import 'package:ciphermonkey/en-de-crypt.dart';
import 'package:uuid/uuid.dart';
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

  String pubkeyString = "-----";
  String pubID;
  String pubNickname;
  bool hasKey = false;
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
            name: "",
            addtime: "",
            type: "public");

        pubkeyFuture.then((pubkeys) {
          if (pubkeys.length > 0) {
            pubkeyString = pubkeys[0].value;
            pubID = pubkeys[0].id;
            pubNickname = pubkeys[0].name;
            setState(() {});
          }
        });
      } else {
        setState(() {});
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
                  child: TextFormField(
                    controller: nicknameController,
                    decoration: const InputDecoration(
                      hintText: 'Your nickname',
                    ),
                    validator: (value) {
                      Pattern pattern = r'^[a-zA-Z0-9]{2,20}$';
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(value.trim())) {
                        return 'Enter your nickname(a-z and 0-9)';
                      }
                      return null;
                    },
                  )),
              Offstage(
                  offstage: hasKey,
                  child: TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Your password',
                    ),
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
                          // 生成 pubkey和prikey.
                          var pair = generateRSAkeyPair();
                          String pubkey = encodePublicKeyToPem(pair.publicKey);
                          String prikey =
                              encodePrivateKeyToPem(pair.privateKey);
                          Uuid uuid = Uuid();
                          String id =
                              uuid.v5(Uuid.NAMESPACE_URL, "dawngrp.com");

                          String name = nicknameController.text.trim();

                          CMKey pubCMkey = CMKey(
                              id: id,
                              name: name,
                              addtime: DateTime.now().toIso8601String(),
                              type: "public",
                              value: pubkey);
                          CMKey priCMkey = CMKey(
                              id: "$id.private",
                              name: name,
                              addtime: DateTime.now().toIso8601String(),
                              type: "private",
                              value: aesEncrypt(
                                  prikey,
                                  base64Encode(
                                      md5String(passwordController.text)
                                          .codeUnits)));

                          DB.addKey(pubCMkey);
                          DB.addKey(priCMkey);
                          refresh();
                        }
                      },
                      child: Text('Create Public Key & Private Key'),
                    ),
                  )),
              Offstage(
                  offstage: !hasKey,
                  child:
                      Text(combinPublicKey(pubID, pubNickname, pubkeyString))),
              Offstage(
                  offstage: !hasKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        String pubTxt =
                            combinPublicKey(pubID, pubNickname, pubkeyString);

                        Future<void> clipboard =
                            Clipboard.setData(ClipboardData(text: pubTxt));

                        clipboard.then((noValue) {
                          Toast.show("Copy to Clipboard Successed!!", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.CENTER);
                        });
                      },
                      child: Text('Copy public key to Clipboard'),
                    ),
                  )),
            ],
          ),
        ));
  }
}
