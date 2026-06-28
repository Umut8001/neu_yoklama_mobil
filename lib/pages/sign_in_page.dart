import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_yoklama_mobil/helper/deviceHelper.dart';
import 'package:qr_yoklama_mobil/pages/home_page.dart';
import 'package:qr_yoklama_mobil/widgets/elevatedButton.dart';
import 'package:qr_yoklama_mobil/widgets/textFormField.dart';
import 'package:safe_device/safe_device.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController ogrNoController;
  late final TextEditingController tekSifreController;

  //final String _siteKey = "6Lejk2ssAAAAAJ2wjhqDqR1T3n6B03Q5JGDIPC_0";
  //final String _secretKey = "6Lejk2ssAAAAACCdObIpUQRmPJhU_6_-7NM8GSo5";

  // late RecaptchaV2Controller recaptchaV2Controller;

  bool rememberMe = false;
  String? currentDeviceId;

  @override
  void initState() {
    super.initState();
    //recaptchaV2Controller = RecaptchaV2Controller();
    _loadDeviceId();
    ogrNoController = TextEditingController();
    tekSifreController = TextEditingController();

    _loadRememberMe();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 161, 201),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,

          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: AlignmentGeometry.topCenter,
              image: AssetImage("assets/images/arkaPlanLogo.png"),
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(20),

                  width: width,
                  height: height * 0.73,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 5, 50, 87),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'app_title'.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            fontSize: height / 50,
                          ),
                          softWrap: true,
                        ),
                        SizedBox(height: height / 70),
                        Text(
                          'sign_in_sub_title'.tr(),
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                            letterSpacing: 2.0,
                            fontSize: height / 60,
                          ),
                          softWrap: true,
                        ),

                        // SizedBox(height: height / 70),
                        //Divider(height: 2, indent: 50, endIndent: 50),
                        SizedBox(height: height / 20),
                        BuildTextFormField(
                          color: Colors.white,
                          width: width * 0.8,
                          text: 'student_no_label'.tr(),
                          icon: Icons.person_2_outlined,
                          suffix: false,
                          controller: ogrNoController,
                          isDark: false,
                          inputtype: TextInputType.text,
                          validator: null,
                          iconColor: Colors.white,
                        ),
                        SizedBox(height: height / 30),
                        BuildTextFormField(
                          color: Colors.white,
                          width: width * 0.8,
                          text: 'password_label'.tr(),
                          icon: Icons.password_outlined,
                          suffix: true,
                          controller: tekSifreController,
                          isDark: false,
                          inputtype: TextInputType.text,
                          validator: null,
                          iconColor: Colors.white,
                        ),
                        SizedBox(height: height / 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'remember_me'.tr(),
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                                letterSpacing: 2.0,
                                fontSize: height / 55,
                              ),
                            ),
                            SizedBox(width: width * 0.4),
                            Checkbox(
                              side: BorderSide(color: Colors.white),
                              activeColor: Colors.green,
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value!;
                                });
                                //_saveRememberMeData(rememberMe);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: height / 60),

                        //SizedBox(height: height / 50),
                        BuildButton(
                          color: Colors.green.shade900,
                          onTop: () {
                            String? tekSifre = tekSifreController.text;
                            String? numara = ogrNoController.text;
                            signIn(numara, tekSifre);
                          },
                          width: width * 0.8,
                          text: 'sign_in_button'.tr(),
                          height: height / 20,
                          icon: Icons.double_arrow_outlined,
                          styleColor: Colors.white,
                          column: false,
                        ),
                        SizedBox(height: height / 60),
                        //SizedBox(height: height / 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  context.setLocale(const Locale('tr')),
                              child: Text(
                                'Türkçe',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.setLocale(const Locale('en')),
                              child: Text(
                                'English',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height / 100),
                        //Divider(height: 2, indent: 50, endIndent: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signIn(String numara, String password) async {
    bool isJailBroken = await SafeDevice.isJailBroken;
    bool isRealDevice = await SafeDevice.isRealDevice;
    bool isMockLocation = await SafeDevice.isMockLocation;

    if (isJailBroken == true ||
        (!isRealDevice) == true ||
        isMockLocation == true) {
      print('security_breach_error'.tr());
      return;
    }
    String email = "$numara@erbakan.edu.tr";

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        String role = data['rol'] ?? '';

        String son_giris_tarihi = userDoc.get('son_giris_tarihi') != null
            ? (userDoc.get('son_giris_tarihi') as Timestamp).toDate().toString()
            : 'loglogin_history_empty'.tr();

        if (!mounted) return;

        if (role == 'ogrenci') {
          String deviceId = data['deviceId'] ?? '-1';

          if (deviceId == '-1') {
            ogrenciCihazIdGuncelle(uid, currentDeviceId ?? '');
            sonGirisTarihiniGuncelle(uid);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomePage(userUID: uid, son_giris_tarihi: son_giris_tarihi),
              ),
            );
          } else if (deviceId == currentDeviceId) {
            sonGirisTarihiniGuncelle(uid);
            _saveRememberMe();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomePage(userUID: uid, son_giris_tarihi: son_giris_tarihi),
              ),
            );
          } else {
            debugPrint('device_mismatch_error'.tr());
            _showError('device_mismatch_error'.tr());
          }
        } else if (role == 'ogretmen') {}
      } else {
        print('user_not_found_error'.tr());
        _showError('user_not_found_error'.tr());
      }
    } on FirebaseAuthException catch (e) {
      print("Auth Hatası: ${e.code} - ${e.message}");
    } catch (e) {
      print("Beklenmedik Hata: $e");
    }
  }

  Future<void> _loadDeviceId() async {
    String id = await DeviceHelper.getUniqueId();
    if (mounted) {
      setState(() {
        currentDeviceId = id;
      });
      print("Cihaz ID yüklendi: $currentDeviceId");
    }
  }

  Future<void> ogrenciCihazIdGuncelle(
    String ogrenciUid,
    String yeniDeviceId,
  ) async {
    try {
      // Öğrencinin Users koleksiyonundaki döküman referansı
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(ogrenciUid);

      // set + merge:true kullanımı:
      // Field yoksa ekler, varsa üzerine yazar.
      // Diğer field'lara (isim, soyisim vs.) zarar vermez.
      await userRef.set({'deviceId': yeniDeviceId}, SetOptions(merge: true));

      print("✅ Cihaz ID başarıyla güncellendi/eklendi.");
    } catch (e) {
      print("❌ Cihaz ID güncellenirken hata oluştu: $e");
      // Hata durumunda kullanıcıya bilgi verebilirsin
    }
  }

  Future<void> sonGirisTarihiniGuncelle(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'son_giris_tarihi':
            FieldValue.serverTimestamp(), // Sunucu saatini kullanır
      });
      print("Giriş tarihi güncellendi.");
    } catch (e) {
      print("Tarih güncellenirken hata: $e");
    }
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('remember_me') ?? false;
      if (rememberMe) {
        ogrNoController.text = prefs.getString('no') ?? '';
        tekSifreController.text = prefs.getString('tek_sifre') ?? '';
      }
    });
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('no', ogrNoController.text);
      await prefs.setString('tek_sifre', tekSifreController.text);
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('no');
      await prefs.remove('tek_sifre');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 5, 50, 87),
        title: Text(
          'location_error_title'.tr(),
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        content: Text(
          msg,
          style: TextStyle(color: Colors.white60),
          softWrap: true,
        ),
      ),
    );
  }
}
