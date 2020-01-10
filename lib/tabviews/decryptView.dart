//TODO：验证签名
//在加密时，需要将发送人的信息发送过来。这样才能根据发送人验证签名
import 'dart:convert';

import 'package:ciphermonkey/en-de-crypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:ciphermonkey/model.dart';

class DecryptView extends StatefulWidget {
  DecryptView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DecryptViewState createState() => _DecryptViewState();
}

class _DecryptViewState extends State<DecryptView> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
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
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
                validator: (value) {
                  Pattern pattern = r'^.{6,20}$';
                  RegExp regex = new RegExp(pattern);
                  if (!regex.hasMatch(value.trim())) {
                    return 'Password is 6~20';
                  }
                  return null;
                },
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              RaisedButton(
                child: Text('Decrypt From Clipboard',
                    style: TextStyle(color: Colors.white)),
                color: Colors.blue,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    final String password = passwordController.text;
                    ClipboardData clipboard =
                        await Clipboard.getData("text/plain");
                    String encryptText;
                    try {
                      //1 base64解码
                      encryptText =
                          String.fromCharCodes(base64Decode(clipboard.text));
                    } catch (e) {
                      Toast.show("Clipboard Text Can't be Decrypt!!", context,
                          duration: Toast.LENGTH_LONG,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.red);
                      return;
                    }

                    final reportTextList = encryptText.split(";");
                    final encryptedKey = reportTextList[0];
                    final sign = reportTextList[1];
                    final encryptedText = reportTextList[2];

                    //2 解码密钥
                    final List<CMKey> prikeys =
                        await DB.queryKeys(type: "private");

                    if (prikeys.length != 1) {
                      Toast.show("PrivateKey error", context,
                          duration: Toast.LENGTH_LONG,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.red);
                      return;
                    }
                    //用密码解密私钥
                    var privatekeyPem;
                    try {
                      privatekeyPem = aesDecrypt(prikeys[0].value,
                          base64Encode(md5String(password).codeUnits));
                    } catch (e) {
                      Toast.show("Password is wrong!", context,
                          duration: Toast.LENGTH_LONG,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.red);
                      return;
                    }

                    try {
                      //从pem格式转换成私钥对象
                      final privatekey = parsePrivateKeyFromPem(privatekeyPem);
                      //得到密钥
                      final secretKey = rsaDecrypt(privatekey, encryptedKey);

                      //得到文本
                      final reportText = aesDecrypt(encryptedText, secretKey);
                      //解压文本并得到第4个文本节。
                      plainText = zlibDecode(reportText).split(";")[3];
                    } catch (e) {
                      Toast.show("Decrypt error!!", context,
                          duration: Toast.LENGTH_LONG,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.red);
                    }

                    //rsaVerify(publickey, sha256String(reportText), sign);

                    setState(() {});
                  }
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
                          duration: Toast.LENGTH_LONG,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.grey);
                    });
                  } else {
                    Toast.show("Decrypt first", context,
                        duration: Toast.LENGTH_LONG,
                        gravity: Toast.CENTER,
                        backgroundColor: Colors.red);
                  }
                  setState(() {});
                },
              ),
              Text("Plain Text:\n$plainText")
            ],
          ),
        ));
  }
}
