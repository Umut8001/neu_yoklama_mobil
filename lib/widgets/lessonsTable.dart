import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_yoklama_mobil/widgets/todayslessons.dart';

class Lessonstable extends StatefulWidget {
  final List<Map<String, dynamic>> tumDersler;
  const Lessonstable({super.key, required this.tumDersler});

  @override
  State<Lessonstable> createState() => _LessonstableState();
}

class _LessonstableState extends State<Lessonstable> {
  int seciliGun = 1;
  late List<List<Map<String, dynamic>>> bugunkuDersler;

  // Günlerin JSON anahtarlarını bir listede tutuyoruz
  final List<String> gunAnahtarlari = [
    'monday_short',
    'tuesday_short',
    'wednesday_short',
    'thursday_short',
    'friday_short',
    'saturday_short',
    'sunday_short',
  ];

  @override
  void initState() {
    bugunkuDersler = dersleriGunlereGoreDuzenle(widget.tumDersler);
    super.initState();
  }

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'course_schedule_title'.tr(), // "Ders Programı"
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: width / 25,
              ),
            ),
            SizedBox(height: height / 50),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: width / 20),
                  // Günleri döngü ile dil dosyasına göre oluşturuyoruz
                  ...List.generate(7, (index) {
                    int gunNo = index + 1;
                    return Padding(
                      padding: EdgeInsets.only(right: width / 50),
                      child: gunler(
                        gunNo,
                        gunAnahtarlari[index].tr(), // Pazartesi, Mon, vb.
                        width,
                        height,
                        () => setState(() => seciliGun = gunNo),
                      ),
                    );
                  }),
                  SizedBox(width: width / 20),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: bugunkuDersler[seciliGun - 1].isEmpty
                  ? Center(
                      child: Text(
                        'no_lessons_on_day'
                            .tr(), // "Seçtiğiniz gün dersiniz bulunmamaktadır!"
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: bugunkuDersler[seciliGun - 1].map((ders) {
                          return Todayslessons(
                            lsName: ders['dersAd'] ?? "",
                            lsTeacher:
                                ders['ogretmenAd'] ?? ders['ogretmenId'] ?? "",
                            lsTime: _saatiFormatla(ders['saat']),
                            lsClassroom: ders['dersSinif'] ?? "",
                          );
                        }).toList(),
                      ),
                    ),
            ),
            SizedBox(height: height / 50),
          ],
        ),
      ),
    );
  }

  Widget gunler(int i, String gun, double w, double h, VoidCallback fonk) {
    return GestureDetector(
      onTap: fonk,
      child: Container(
        width: w / 4,
        height: h / 20,
        decoration: BoxDecoration(
          color: seciliGun == i
              ? const Color.fromARGB(220, 5, 50, 87)
              : const Color.fromARGB(255, 0, 161, 201),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color.fromARGB(220, 5, 50, 87)),
        ),
        child: Center(
          child: Text(
            gun,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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

    // Eğer saat aralığı tanımlı değilse "9. saat" formatını dile göre döndürür
    return saatler[saat] ??
        'hour_suffix'.tr(namedArgs: {'saat': saat.toString()});
  }

  List<List<Map<String, dynamic>>> dersleriGunlereGoreDuzenle(
    List<Map<String, dynamic>> tumDersler,
  ) {
    List<List<Map<String, dynamic>>> gunlerListesi = List.generate(
      7,
      (_) => [],
    );
    for (var ders in tumDersler) {
      int gun = ders['gun'] ?? 0;
      if (gun >= 1 && gun <= 7) {
        gunlerListesi[gun - 1].add(ders);
      }
    }
    return gunlerListesi;
  }
}
