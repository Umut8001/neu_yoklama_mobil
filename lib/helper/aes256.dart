import 'package:encrypt/encrypt.dart' as encrypt;

class AESHelper {
  // Key: 32 karakter (256 bit)
  static final _key = encrypt.Key.fromUtf8('NecmettinErbakanUniversitesi4242');

  // IV: 16 karakter (128 bit) SABİT OLMALI
  // fromLength(16) yerine fromUtf8 kullanıyoruz ki her iki cihazda da aynı olsun
  static final _iv = encrypt.IV.fromUtf8('16karakterlik_IV');

  static String encryptText(String plainText) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedText) {
    try {
      final cleanText = encryptedText.trim();

      final encrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.cbc),
      );

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(cleanText),
        iv: _iv,
      );

      return decrypted;
    } catch (e) {
      print("Çözme Hatası: $e");
      return "HATA: Veri çözülemedi";
    }
  }
}
