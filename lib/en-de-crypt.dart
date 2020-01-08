import 'dart:io';
import "dart:math";
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import "dart:convert";
import "package:pointycastle/export.dart" as pointycastle;
import "package:asn1lib/asn1lib.dart";

//生成公钥和私钥
pointycastle.AsymmetricKeyPair<pointycastle.RSAPublicKey,
    pointycastle.RSAPrivateKey> generateRSAkeyPair({int bitLength = 2048}) {
  // Create an RSA key generator and initialize it
  final secureRandom = pointycastle.FortunaRandom();

  final seedSource = Random.secure();
  final seeds = <int>[];
  for (int i = 0; i < 32; i++) {
    seeds.add(seedSource.nextInt(255));
  }
  secureRandom.seed(pointycastle.KeyParameter(Uint8List.fromList(seeds)));

  final keyGen = pointycastle.RSAKeyGenerator()
    ..init(pointycastle.ParametersWithRandom(
        pointycastle.RSAKeyGeneratorParameters(
            BigInt.parse('65537'), bitLength, 64),
        secureRandom));

  // Use the generator

  final pair = keyGen.generateKeyPair();

  // Cast the generated key pair into the RSA key types

  final myPublic = pair.publicKey as pointycastle.RSAPublicKey;
  final myPrivate = pair.privateKey as pointycastle.RSAPrivateKey;

  return pointycastle.AsymmetricKeyPair<pointycastle.RSAPublicKey,
      pointycastle.RSAPrivateKey>(myPublic, myPrivate);
}

//rsa加密
String rsaEncrypt(pointycastle.RSAPublicKey publickey, String plainText) {
  final encrypter = Encrypter(RSA(publicKey: publickey));
  final encrypted = encrypter.encrypt(plainText);
  return encrypted.base64;
}

//rsa解密
String rsaDecrypt(pointycastle.RSAPrivateKey privatekey, String encryptedText) {
  final encrypter = Encrypter(RSA(privateKey: privatekey));
  final decrypted = encrypter.decrypt(Encrypted(base64Decode(encryptedText)));
  return decrypted; // Lorem ipsum dolor sit amet, consectetur adipiscing elit
}

//rsa签名
String rsaSign(pointycastle.RSAPrivateKey privatekey, String plainText) {
  final signer =
      Signer(RSASigner(RSASignDigest.SHA256, privateKey: privatekey));
  return signer.sign(plainText).base64;
}

//rsa验证签名
bool rsaVerify(
    pointycastle.RSAPublicKey publickey, String plainText, String signText) {
  final signer = Signer(RSASigner(RSASignDigest.SHA256, publicKey: publickey));
  return signer.verify64(plainText, signText);
}

//aes加密
String aesEncrypt(String plainText, String keyBase64) {
  final key = Key.fromBase64(keyBase64);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  //print(encrypted.base64);
  return encrypted.base64;
}

//aes解密
String aesDecrypt(String encryptedText, String keyBase64) {
  final key = Key.fromBase64(keyBase64);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final encrypted = Encrypted(base64Decode(encryptedText));
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  //print(decrypted);
  return decrypted;
}

//zlib压缩
String zlibEncode(String plainText) {
  ZLibCodec zlib = ZLibCodec();
  List<int> charCodes = zlib.encode(plainText.codeUnits);
  return String.fromCharCodes(charCodes);
}

//zlib解压
String zlibDecode(String codes) {
  ZLibCodec zlib = ZLibCodec();
  List<int> charCodes = zlib.decode(codes.codeUnits);
  return String.fromCharCodes(charCodes);
}

//sha256
String sha256String(String plainText) {
  var bytes = utf8.encode(plainText);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

String md5String(String plainText) {
  return md5.convert(utf8.encode(plainText)).toString();
}

//random string
String secureRandom64(int length) {
  return SecureRandom(length).base64;
}

//PEM <==> key =============================================
String encodePublicKeyToPem(pointycastle.RSAPublicKey publicKey) {
  var algorithmSeq = new ASN1Sequence();
  var algorithmAsn1Obj = new ASN1Object.fromBytes(Uint8List.fromList(
      [0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
  var paramsAsn1Obj = new ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(algorithmAsn1Obj);
  algorithmSeq.add(paramsAsn1Obj);

  var publicKeySeq = new ASN1Sequence();
  publicKeySeq.add(ASN1Integer(publicKey.modulus));
  publicKeySeq.add(ASN1Integer(publicKey.exponent));
  var publicKeySeqBitString =
      new ASN1BitString(Uint8List.fromList(publicKeySeq.encodedBytes));

  var topLevelSeq = new ASN1Sequence();
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqBitString);
  var dataBase64 = base64.encode(topLevelSeq.encodedBytes);

  return """-----BEGIN PUBLIC KEY-----\r\n$dataBase64\r\n-----END PUBLIC KEY-----""";
}

String encodePrivateKeyToPem(pointycastle.RSAPrivateKey privateKey) {
  var version = ASN1Integer(BigInt.from(0));

  var algorithmSeq = new ASN1Sequence();
  var algorithmAsn1Obj = new ASN1Object.fromBytes(Uint8List.fromList(
      [0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
  var paramsAsn1Obj = new ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(algorithmAsn1Obj);
  algorithmSeq.add(paramsAsn1Obj);

  var privateKeySeq = new ASN1Sequence();
  var modulus = ASN1Integer(privateKey.n);
  var publicExponent = ASN1Integer(BigInt.parse('65537'));
  var privateExponent = ASN1Integer(privateKey.d);
  var p = ASN1Integer(privateKey.p);
  var q = ASN1Integer(privateKey.q);
  var dP = privateKey.d % (privateKey.p - BigInt.from(1));
  var exp1 = ASN1Integer(dP);
  var dQ = privateKey.d % (privateKey.q - BigInt.from(1));
  var exp2 = ASN1Integer(dQ);
  var iQ = privateKey.q.modInverse(privateKey.p);
  var co = ASN1Integer(iQ);

  privateKeySeq.add(version);
  privateKeySeq.add(modulus);
  privateKeySeq.add(publicExponent);
  privateKeySeq.add(privateExponent);
  privateKeySeq.add(p);
  privateKeySeq.add(q);
  privateKeySeq.add(exp1);
  privateKeySeq.add(exp2);
  privateKeySeq.add(co);
  var publicKeySeqOctetString =
      new ASN1OctetString(Uint8List.fromList(privateKeySeq.encodedBytes));

  var topLevelSeq = new ASN1Sequence();
  topLevelSeq.add(version);
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqOctetString);
  var dataBase64 = base64.encode(topLevelSeq.encodedBytes);

  return """-----BEGIN PRIVATE KEY-----\r\n$dataBase64\r\n-----END PRIVATE KEY-----""";
}

pointycastle.RSAPublicKey parsePublicKeyFromPem(pemString) {
  List<int> publicKeyDER = decodePEM(pemString);
  var asn1Parser = new ASN1Parser(publicKeyDER);
  var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  var publicKeyBitString = topLevelSeq.elements[1];

  var publicKeyAsn = new ASN1Parser(publicKeyBitString.contentBytes());
  ASN1Sequence publicKeySeq = publicKeyAsn.nextObject();
  var modulus = publicKeySeq.elements[0] as ASN1Integer;
  var exponent = publicKeySeq.elements[1] as ASN1Integer;

  pointycastle.RSAPublicKey rsaPublicKey = pointycastle.RSAPublicKey(
      modulus.valueAsBigInteger, exponent.valueAsBigInteger);

  return rsaPublicKey;
}

pointycastle.RSAPrivateKey parsePrivateKeyFromPem(pemString) {
  List<int> privateKeyDER = decodePEM(pemString);
  var asn1Parser = new ASN1Parser(privateKeyDER);
  var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  // var version = topLevelSeq.elements[0];
  // var algorithm = topLevelSeq.elements[1];
  var privateKey = topLevelSeq.elements[2];

  asn1Parser = new ASN1Parser(privateKey.contentBytes());
  var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

  //version = pkSeq.elements[0];
  var modulus = pkSeq.elements[1] as ASN1Integer;
  //var publicExponent = pkSeq.elements[2] as ASN1Integer;
  var privateExponent = pkSeq.elements[3] as ASN1Integer;
  var p = pkSeq.elements[4] as ASN1Integer;
  var q = pkSeq.elements[5] as ASN1Integer;
  // var exp1 = pkSeq.elements[6] as ASN1Integer;
  // var exp2 = pkSeq.elements[7] as ASN1Integer;
  // var co = pkSeq.elements[8] as ASN1Integer;

  pointycastle.RSAPrivateKey rsaPrivateKey = pointycastle.RSAPrivateKey(
      modulus.valueAsBigInteger,
      privateExponent.valueAsBigInteger,
      p.valueAsBigInteger,
      q.valueAsBigInteger);

  return rsaPrivateKey;
}

List<int> decodePEM(String pem) {
  var startsWith = [
    "-----BEGIN PUBLIC KEY-----",
    "-----BEGIN PRIVATE KEY-----",
    "-----BEGIN PGP PUBLIC KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n",
    "-----BEGIN PGP PRIVATE KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n",
  ];
  var endsWith = [
    "-----END PUBLIC KEY-----",
    "-----END PRIVATE KEY-----",
    "-----END PGP PUBLIC KEY BLOCK-----",
    "-----END PGP PRIVATE KEY BLOCK-----",
  ];
  bool isOpenPgp = pem.indexOf('BEGIN PGP') != -1;

  for (var s in startsWith) {
    if (pem.startsWith(s)) {
      pem = pem.substring(s.length);
    }
  }

  for (var s in endsWith) {
    if (pem.endsWith(s)) {
      pem = pem.substring(0, pem.length - s.length);
    }
  }

  if (isOpenPgp) {
    var index = pem.indexOf('\r\n');
    pem = pem.substring(0, index);
  }

  pem = pem.replaceAll('\n', '');
  pem = pem.replaceAll('\r', '');

  return base64.decode(pem);
}

String combinPublicKey(String id, String name, String publicKeyPem) {
  return base64Encode("$id;$name;$publicKeyPem".codeUnits);
}

List<String> discombinPublicKey(String publicText) {
  return String.fromCharCodes(base64Decode(publicText)).split(";");
}
