import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Container(
        height: height * 0.7,
        width: width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'about_us'.tr(), // "Hakkında"
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: width / 25,
              ),
            ),
            SizedBox(height: height / 80),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: height / 60),
                          Container(
                            width: width / 5,
                            height: width / 5,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 0, 161, 201),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: width / 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: height / 60),
                          Text(
                            'about_app_description'
                                .tr(), // "QR Kod Tabanlı Akıllı Yoklama Sistemi"
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width / 28,
                              color: const Color.fromARGB(255, 5, 50, 87),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'university_name'
                                .tr(), // "Necmettin Erbakan Üniversitesi"
                            style: TextStyle(
                              fontSize: width / 35,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: height / 60),
                        ],
                      ),
                    ),
                    _bolum(
                      'project_info_title'.tr(), // "Proje Hakkında"
                      Icons.info_outline,
                      'project_description'.tr(), // Uzun açıklama metni
                      width,
                    ),
                    _bolum(
                      'developer_title'.tr(), // "Geliştirici"
                      Icons.person_outline,
                      'developer_info'
                          .tr(), // "Umut Sadıkoğlu\n23100011059\nBilgisayar Mühendisliği"
                      width,
                    ),
                    _bolum(
                      'advisor_title'.tr(), // "Danışman"
                      Icons.school_outlined,
                      'advisor_name'.tr(), // "Prof. Dr. Mehmet HACIBEYOĞLU"
                      width,
                    ),
                    _bolum(
                      'technologies_title'.tr(), // "Teknolojiler"
                      Icons.code_outlined,
                      'technologies_list'.tr(), // Flutter, Firebase vb.
                      width,
                    ),
                    _bolum(
                      'version_title'.tr(), // "Versiyon"
                      Icons.new_releases_outlined,
                      'version_info'.tr(), // "v1.0.0 · Şubat 2026"
                      width,
                    ),
                    SizedBox(height: height / 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bolum(String baslik, IconData ikon, String icerik, double width) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(15, 5, 50, 87),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(40, 5, 50, 87)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ikon,
            color: const Color.fromARGB(255, 0, 161, 201),
            size: width / 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width / 30,
                    color: const Color.fromARGB(255, 5, 50, 87),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  icerik,
                  style: TextStyle(fontSize: width / 35, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
