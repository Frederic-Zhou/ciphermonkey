import 'dart:convert';

import 'package:ciphermonkey/en-de-crypt.dart';
import 'package:flutter/material.dart';
import 'package:ciphermonkey/model.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class EncryptView extends StatefulWidget {
  EncryptView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EncryptViewState createState() => new _EncryptViewState();
}

class _EncryptViewState extends State<EncryptView> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final plainTextController = TextEditingController();

  int maxLine = 2;
  String finalEncryptedReport = "";
  CMKey dropdownValue;
  List<DropdownMenuItem> keyList = new List();
  @override
  void initState() {
    super.initState();
    try {
      getKeyListData();
    } catch (e) {
      print("get key list error.");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getKeyListData() {
    Future<List<CMKey>> pubkeysF = DB.queryKeys(type: "public");
    pubkeysF.then((pubkeys) {
      pubkeys.forEach((pubkey) {
        if (!mounted) return;
        setState(() {
          DropdownMenuItem dropdownMenuItem = new DropdownMenuItem(
            child: new Text("${pubkey.name}\n${pubkey.id.toUpperCase()}"),
            value: pubkey,
          );
          keyList.add(dropdownMenuItem);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      //controller: controller,
      child: Form(
          key: _formKey,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new DropdownButton(
                    value: dropdownValue,
                    icon: Icon(
                      Icons.person_add,
                      color: Colors.blue,
                    ),
                    iconSize: 24,
                    elevation: 24,
                    style: TextStyle(color: Colors.blue),
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: keyList),
                TextFormField(
                  controller: plainTextController,
                  decoration: const InputDecoration(
                    hintText: 'Text to encrypt',
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return 'Enter some text';
                    }
                    return null;
                  },
                  maxLines: maxLine,
                  keyboardType: TextInputType.multiline,
                  onChanged: (text) {
                    setState(() {
                      maxLine = text.split("\n").length > 2
                          ? text.split("\n").length
                          : 2;
                    });
                  },
                ),
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
                  child: Text('Encrypt', style: TextStyle(color: Colors.white)),
                  color: Colors.blue,
                  onPressed: () async {
                    if (dropdownValue.id == null) {
                      Toast.show("Select A contact first!", context,
                          duration: Toast.LENGTH_LONG,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.red);
                      return;
                    }

                    if (_formKey.currentState.validate()) {
                      //开始加密
                      final String plainText = plainTextController.text;
                      final String password = passwordController.text;
                      //1.组合报文并2.压缩内容
                      //final String reportText = zlibEncode(plainText);
                      final String reportText = plainText;

                      //3.签名
                      //3.1 生成指纹hash
                      final String fingerHash = sha256String(reportText);
                      //3.2 从数据库得到私钥
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

                      //从pem格式转换成私钥对象
                      final privatekey = parsePrivateKeyFromPem(privatekeyPem);
                      //3.3 获得签名
                      final sign = rsaSign(privatekey, fingerHash);

                      //4 生成随机密钥
                      final secretKey = secureRandom64(32);
                      //5 用密钥加密报文
                      final encryptedText = aesEncrypt(reportText, secretKey);
                      //6 加密密钥
                      final encryptedKey = rsaEncrypt(
                          parsePublicKeyFromPem(dropdownValue.value),
                          secretKey);
                      //7 组合报文，编码成base64
                      finalEncryptedReport = base64Encode(
                          "$encryptedKey;$sign;$encryptedText".codeUnits);

                      setState(() {});
                    }
                  },
                ),
                Divider(
                  thickness: 2,
                  color: Colors.green,
                ),
                RaisedButton(
                  child: Text('Copy Encrypted Text ⬇️ to Clipboard',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.green,
                  onPressed: () {
                    if (finalEncryptedReport.length > 0) {
                      Future<void> clipboard = Clipboard.setData(
                          ClipboardData(text: finalEncryptedReport));

                      clipboard.then((noValue) {
                        Toast.show("Copy to Clipboard Successed!!", context,
                            duration: Toast.LENGTH_LONG,
                            gravity: Toast.CENTER,
                            backgroundColor: Colors.blueGrey);
                      });
                    } else {
                      Toast.show("Encrypt first", context,
                          duration: Toast.LENGTH_LONG,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.red);
                    }

                    setState(() {});
                  },
                ),
                Text(
                  "🙈 Encrypted Text 🙈",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                Divider(
                  thickness: 0,
                  color: Colors.grey,
                ),
                Text(
                  "$finalEncryptedReport",
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  maxLines: 5,
                  overflow: TextOverflow.fade,
                )
              ],
            ),
          )),
    );
  }
}
