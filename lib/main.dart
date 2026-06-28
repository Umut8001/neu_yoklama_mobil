import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_yoklama_mobil/pages/sign_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Easy Localization'ı başlatıyoruz
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      // Desteklenen diller
      supportedLocales: const [Locale('tr'), Locale('en'), Locale('ar')],
      // Çeviri dosyalarının yolu (assets/translations/tr.json gibi)
      path: 'assets/translations',
      // Eğer bir dil bulunamazsa varsayılan olarak ne kullanılsın?
      fallbackLocale: const Locale('tr'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEÜ QR YOKLAMA',
      // Dil ayarlarını context üzerinden otomatik alması için:
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      home: const SignInPage(),
    );
  }
}
