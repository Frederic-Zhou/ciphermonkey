import 'package:flutter/material.dart';
import 'myHomePage.dart';
import 'model.dart';
import 'en-de-crypt.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keystr = secureRandom64(32);
  print("keystr: " + keystr);
  String encrypted = aesEncrypt("Hello world", keystr);
  String decrypted = aesDecrypt(encrypted, keystr);

  String zlibStr = zlibEncode("Hello world!!");
  String plantStr = zlibDecode(zlibStr);

  final pair = generateRSAkeyPair();
  print(encodePublicKeyToPem(pair.publicKey));

  print("encrypted: " + encrypted);
  print("decrypted: " + decrypted);

  print("sha256: " + sha256String("hello"));

  print("zlibStr: " + zlibStr);

  print("plantStr: " + plantStr);

  await DB.openDB();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Contact'),
      debugShowCheckedModeBanner: false,
    );
  }
}
