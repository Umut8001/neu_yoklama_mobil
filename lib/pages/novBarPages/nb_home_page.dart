import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_yoklama_mobil/widgets/attendanceTable.dart';
import 'package:qr_yoklama_mobil/widgets/infoBox.dart';
import 'package:qr_yoklama_mobil/widgets/lessonsTable.dart';
import 'package:qr_yoklama_mobil/widgets/todayslessons.dart';

// ignore: must_be_immutable
class NbHomePage extends StatefulWidget {
  DocumentSnapshot? userDoc;
  String son_giris_tarihi;
  List<Map<String, dynamic>> bugunkuDersler;
  List<Map<String, dynamic>> tumDersler;
  NbHomePage({
    super.key,
    required this.userDoc,
    required this.son_giris_tarihi,
    required this.bugunkuDersler,
    required this.tumDersler,
  });

  @override
  State<NbHomePage> createState() => _NbHomePageState();
}

class _NbHomePageState extends State<NbHomePage> {
  late double genelDevamOrani;
  late int kritikDersSayisi;
  late int kalinanDersSayisi;

  @override
  void initState() {
    super.initState();
    _istatistikleriHesapla();
  }

  void _istatistikleriHesapla() {
    if (widget.tumDersler.isEmpty) {
      genelDevamOrani = 0;
      kritikDersSayisi = 0;
      kalinanDersSayisi = 0;
      return;
    }

    final Map<String, Map<String, dynamic>> tekil = {};
    for (var ders in widget.tumDersler) {
      String kod = ders['dersKodu'] ?? '';
      if (!tekil.containsKey(kod)) tekil[kod] = ders;
    }
    final dersler = tekil.values.toList();

    int toplamAcilanOturum = 0;
    int toplamKatilim = 0;
    int kritik = 0;
    int kaldi = 0;

    for (var ders in dersler) {
      int acilanOturum = ders['toplamAcilanOturum'] ?? 0;
      int katildi = ders['katilinanOturum'] ?? 0;
      bool kalirMi = ders['kalirMi'] ?? false;

      toplamAcilanOturum += acilanOturum;
      toplamKatilim += katildi;

      if (kalirMi) {
        kaldi++;
      } else {
        int limit = ders['devamsizlikLimiti'] ?? 0;
        int katilmadi = ders['katilmadigiSaat'] ?? 0;
        if (limit > 0 && katilmadi >= (limit * 0.8).floor()) {
          kritik++;
        }
      }
    }

    genelDevamOrani = toplamAcilanOturum > 0
        ? (toplamKatilim / toplamAcilanOturum) * 100
        : 0;
    kritikDersSayisi = kritik;
    kalinanDersSayisi = kaldi;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 0, 161, 201),
        image: DecorationImage(
          alignment: AlignmentGeometry.topCenter,
          image: AssetImage("assets/images/arkaPlanLogo.png"),
        ),
      ),
      width: width,
      height: height,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height / 13),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    'welcome_back'.tr(),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      letterSpacing: 2.0,
                      fontSize: height / 60,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    'user_full_name'.tr(
                      namedArgs: {
                        'isim': widget.userDoc?.get('isim') ?? "",
                        'soyisim': widget.userDoc?.get('soyisim') ?? "",
                      },
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: height / 48,
                    ),
                    softWrap: true,
                  ),
                  Spacer(),
                  Column(
                    children: [
                      Text(
                        'last_login_label'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: height / 100,
                        ),
                        softWrap: true,
                      ),
                      Text(
                        widget.son_giris_tarihi,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          fontSize: height / 100,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
            SizedBox(height: height / 300),
            Divider(endIndent: width / 20, indent: width / 20),
            SizedBox(height: height / 300),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  HPInfoBox(
                    iconBGColor: Colors.green,
                    icon: Icons.rule_rounded,
                    title: 'attendance_rate'.tr(),
                    subtitle: '%${genelDevamOrani.toStringAsFixed(0)}',
                    column: true,
                    fonksiyon: () {},
                  ),
                  HPInfoBox(
                    iconBGColor: const Color.fromARGB(255, 171, 213, 235),
                    icon: Icons.import_contacts_rounded,
                    title: 'active_courses'.tr(),
                    subtitle: (widget.userDoc?.get('dersler') as List).length
                        .toString(),
                    column: true,
                    fonksiyon: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  HPInfoBox(
                    iconBGColor: Colors.yellow.shade800,
                    icon: Icons.assignment_late_outlined,
                    title: 'critical_courses'.tr(),
                    subtitle: kritikDersSayisi.toString(),
                    column: true,
                    fonksiyon: () {},
                  ),
                  HPInfoBox(
                    iconBGColor: Colors.redAccent,
                    icon: Icons.not_interested_rounded,
                    title: 'failed_courses'.tr(),
                    subtitle: kalinanDersSayisi.toString(),
                    column: true,
                    fonksiyon: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: height / 300),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Container(
                    color: Colors.white54,
                    height: 1,
                    width: width / 3.5,
                  ),
                  Spacer(),
                  Text(
                    'quick_actions'.tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: height / 52,
                    ),
                    softWrap: true,
                  ),
                  Spacer(),
                  Container(
                    color: Colors.white54,
                    height: 1,
                    width: width / 3.5,
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: height / 300),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  HPInfoBox(
                    iconBGColor: Colors.green.shade300,
                    icon: Icons.assessment_outlined,
                    title: 'attendance_report'.tr(),
                    subtitle: '-',
                    column: false,
                    fonksiyon: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AttendanceTable(tumDersler: widget.tumDersler),
                      );
                    },
                  ),
                  HPInfoBox(
                    iconBGColor: Colors.green.shade300,
                    icon: Icons.event_note_outlined,
                    title: 'course_schedule'.tr(),
                    subtitle: '-',
                    column: false,
                    fonksiyon: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            Lessonstable(tumDersler: widget.tumDersler),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: height / 300),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Container(
                    color: Colors.white54,
                    height: 1,
                    width: width / 3.5,
                  ),
                  Spacer(),
                  Text(
                    'daily_schedule'.tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: height / 52,
                    ),
                    softWrap: true,
                  ),
                  Spacer(),
                  Container(
                    color: Colors.white54,
                    height: 1,
                    width: width / 3.5,
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: height / 300),
            widget.bugunkuDersler.isEmpty
                ? Center(
                    child: Text(
                      'no_lessons_today'.tr(),
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Column(
                    children: widget.bugunkuDersler.map((ders) {
                      return Todayslessons(
                        lsName: ders['dersAd'],
                        lsTeacher: ders['ogretmenAd'] ?? ders['ogretmenId'],
                        lsTime: _saatiFormatla(ders['saat']),
                        lsClassroom: ders['dersSinif'],
                      );
                    }).toList(),
                  ),
            SizedBox(height: height / 10),
          ],
        ),
      ),
    );
  }

  String _saatiFormatla(int saat) {
    const saatler = {
      1: '09:00 - 09:45',
      2: '10:00 - 10:45',
      3: '11:00 - 11:45',
      4: '13:00 - 13:45',
      5: '14:00 - 14:45',
      6: '15:00 - 15:45',
      7: '16:00 - 16:45',
      8: '17:00 - 17:45',
      9: '18:00 - 18:45',
      10: '19:00 - 19:45',
    };

    return saatler[saat] ??
        'hour_suffix'.tr(namedArgs: {'saat': saat.toString()});
  }
}
