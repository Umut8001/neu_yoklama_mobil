import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AttendanceTable extends StatelessWidget {
  final List<Map<String, dynamic>> tumDersler;
  const AttendanceTable({super.key, required this.tumDersler});

  List<Map<String, dynamic>> _tekilDersler() {
    final Map<String, Map<String, dynamic>> tekil = {};
    for (var ders in tumDersler) {
      String kod = ders['dersKodu'] ?? '';
      if (!tekil.containsKey(kod)) {
        tekil[kod] = ders;
      }
    }
    return tekil.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final dersler = _tekilDersler();

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
              'attendance_status_title'.tr(), // "Devamsızlık Durumu"
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: width / 25,
              ),
            ),
            SizedBox(height: height / 50),
            const Divider(),
            Expanded(
              child: dersler.isEmpty
                  ? Center(
                      child: Text(
                        'no_registered_courses'
                            .tr(), // "Kayıtlı dersiniz bulunmamaktadır."
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: dersler.map((ders) {
                          int toplam = ders['toplamAcilanOturum'] ?? 0;
                          int katilindi = ders['katilinanOturum'] ?? 0;
                          int katilmadi = ders['katilmadigiOturum'] ?? 0;
                          double oran = toplam > 0 ? katilindi / toplam : 0;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(15, 5, 50, 87),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color.fromARGB(40, 5, 50, 87),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ders['dersAd'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: width / 28,
                                          color: const Color.fromARGB(
                                            255,
                                            5,
                                            50,
                                            87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ders['dersKodu'] ?? '',
                                      style: TextStyle(
                                        fontSize: width / 35,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _bilgiKutusu(
                                      'total_count'.tr(), // "Toplam"
                                      toplam.toString(),
                                      Colors.blue,
                                      width,
                                    ),
                                    _bilgiKutusu(
                                      'attended_count'.tr(), // "Katıldı"
                                      katilindi.toString(),
                                      Colors.green,
                                      width,
                                    ),
                                    _bilgiKutusu(
                                      'absent_count'.tr(), // "Katılmadı"
                                      katilmadi.toString(),
                                      Colors.red,
                                      width,
                                    ),
                                    _bilgiKutusu(
                                      'percentage_label'.tr(), // "%"
                                      '%${(oran * 100).toStringAsFixed(0)}',
                                      oran >= 0.7 ? Colors.green : Colors.red,
                                      width,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: oran,
                                    minHeight: 8,
                                    backgroundColor: Colors.red.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      oran >= 0.7 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bilgiKutusu(String baslik, String deger, Color renk, double width) {
    return Column(
      children: [
        Text(
          deger,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: width / 22,
            color: renk,
          ),
        ),
        Text(
          baslik,
          style: TextStyle(fontSize: width / 38, color: Colors.grey),
        ),
      ],
    );
  }
}
