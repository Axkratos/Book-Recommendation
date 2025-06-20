import 'package:encrypt/encrypt.dart' as encrypt;

class TokenEncryptor {
  static final _key = encrypt.Key.fromUtf8(
    '12345678901234567890123456789012',
  ); // exactly 32 chars
  static final _iv = encrypt.IV.fromLength(16);

  static String encryptToken(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptToken(String encryptedText) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return '';
    }
  }
}
