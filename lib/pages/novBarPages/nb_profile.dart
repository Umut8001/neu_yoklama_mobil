import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_yoklama_mobil/pages/sign_in_page.dart';
import 'package:qr_yoklama_mobil/widgets/aboutPage.dart';
import 'package:qr_yoklama_mobil/widgets/languageSelection.dart';

// ignore: must_be_immutable
class NbProfile extends StatefulWidget {
  DocumentSnapshot? userDoc;
  String bolumIsim;
  NbProfile({super.key, required this.userDoc, required this.bolumIsim});

  @override
  State<NbProfile> createState() => _NbProfileState();
}

class _NbProfileState extends State<NbProfile> {
  @override
  Widget build(BuildContext context) {
    //double height = MediaQuery.of(context).size.height;
    //double width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 0, 161, 201),
        image: DecorationImage(
          alignment: AlignmentGeometry.topCenter,
          image: AssetImage("assets/images/arkaPlanLogo.png"),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Profil Bölümü
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFF4A90E2),
                        child: Icon(Icons.person, size: 50),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${widget.userDoc?['isim']} ${widget.userDoc?['soyisim']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'student_no_display'.tr(
                      namedArgs: {
                        'no': widget.userDoc?['ogr_no']?.toString() ?? "",
                      },
                    ),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Bölüm Kartı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'academic_section'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color.fromARGB(220, 5, 50, 87),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: Colors.white),
                  const SizedBox(width: 15),
                  Text(
                    'department_label'.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.bolumIsim}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Uygulama Ayarları
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'app_section'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...[
                  {
                    'icon': Icons.location_on,
                    'title': 'location_permissions'.tr(),
                    'fonk': () async {
                      await openAppSettings();
                    },
                  },
                  {
                    'icon': Icons.language_outlined,
                    'title': 'language_selection'.tr(),
                    'fonk': () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (context) => LanguageSelectionPage(),
                        );
                      });
                    },
                  },
                  {
                    'icon': Icons.info,
                    'title': 'about_us'.tr(),
                    'fonk': () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (_) => const AboutPage(),
                        );
                      });
                    },
                  },
                ]
                .map(
                  (item) => GestureDetector(
                    onTap: item['fonk'] as VoidCallback,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(220, 5, 50, 87),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 40),
            // Çıkış Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () {
                  signOut();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'sign_out'.tr(),
                  style: TextStyle(
                    color: Color(0xFFEF5350),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInPage()),
      (Route<dynamic> route) => false,
    );
  }
}
