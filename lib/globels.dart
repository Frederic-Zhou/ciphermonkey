import 'package:ciphermonkey/model.dart';
import 'package:flutter/material.dart';

import 'tabviews/contactView.dart';
import 'tabviews/decryptView.dart';
import 'tabviews/encryptView.dart';
import 'tabviews/mindView.dart';

ContactView contactView = ContactView();
EncryptView encryptView = EncryptView();
DecryptView decryptView = DecryptView();
MindView mindView = MindView();
List<Widget> tabViews = [contactView, encryptView, decryptView, mindView];
CMKey currentPublicKey = CMKey();
