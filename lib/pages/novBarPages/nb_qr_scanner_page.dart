import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_yoklama_mobil/helper/aes256.dart';
import 'package:qr_yoklama_mobil/pages/errorPage.dart';
import 'package:qr_yoklama_mobil/pages/successPage.dart';
import 'package:qr_yoklama_mobil/widgets/elevatedButton.dart';
import 'package:qr_yoklama_mobil/widgets/textFormField.dart';

// ignore: must_be_immutable
class NbQrScannerPage extends StatefulWidget {
  String ogrenciUID;
  DocumentSnapshot? userDoc;
  int hafta;
  NbQrScannerPage({
    super.key,
    required this.ogrenciUID,
    required this.userDoc,
    required this.hafta,
  });

  @override
  State<NbQrScannerPage> createState() => _NbQrScannerPageState();
}

class _NbQrScannerPageState extends State<NbQrScannerPage> {
  String scannedData = "";
  late TextEditingController qrController;
  late MobileScannerController scannerController;
  double _currentZoom = 0.0;
  double lat = 0, lon = 0;
  @override
  void initState() {
    qrController = TextEditingController();
    scannerController = MobileScannerController();
    qrController.text = scannedData;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 161, 201),
            image: DecorationImage(
              alignment: AlignmentGeometry.topCenter,
              image: AssetImage("assets/images/arkaPlanLogo.png"),
            ),
          ),
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              SizedBox(height: height / 14),
              Text(
                'scan_qr_title'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,

                  fontSize: height / 48,
                ),
                softWrap: true,
              ),
              Text(
                'scan_qr_sub_title'.tr(),
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  letterSpacing: 2.0,
                  fontSize: height / 60,
                ),
                softWrap: true,
              ),
              SizedBox(height: height / 300),
              Divider(endIndent: width / 20, indent: width / 20),
              SizedBox(height: height / 50),

              Container(
                width: width * 0.9,
                height: height * 0.6,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromARGB(255, 5, 50, 87),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(18),
                        child: MobileScanner(
                          controller: scannerController,
                          onDetect: (barcodeCapture) {
                            final List<Barcode> barcodes =
                                barcodeCapture.barcodes;
                            for (final barcode in barcodes) {
                              setState(() {
                                scannedData =
                                    barcode.rawValue ?? 'no_data_found'.tr();
                                qrController.text = scannedData;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: height / 100),
                    BuildTextFormField(
                      color: Colors.white,
                      width: width * 0.8,
                      text: 'qr_code_label'.tr(),
                      iconColor: Colors.white,
                      icon: Icons.qr_code_rounded,
                      suffix: false,
                      controller: qrController,
                      isDark: false,
                      inputtype: TextInputType.multiline,
                      validator: null,
                    ),
                    SizedBox(height: height / 100),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Slider(
                padding: EdgeInsets.symmetric(horizontal: 50),
                thumbColor: Colors.green,
                allowedInteraction: SliderInteraction.tapAndSlide,
                activeColor: Colors.green.shade100,
                value: _currentZoom,
                onChanged: (value) {
                  setState(() {
                    _currentZoom = value;
                    scannerController.setZoomScale(
                      value,
                    ); // Kameraya zoom komutu gönderir
                  });
                },
              ),
              SizedBox(height: 8),
              SizedBox(
                height: height / 15,
                child: Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            scannedData = 'not_scanned_yet'.tr();
                            qrController.clear();
                          });
                        },
                        color: Colors.white,
                        iconSize: width / 15,
                        icon: Icon(Icons.delete_outline_sharp),
                      ),
                      BuildButton(
                        color: Colors.green,
                        onTop: () async {
                          // async eklendi
                          String sifresizQr;
                          String dersKodu = '';
                          List<String> dersSaatleri = [];
                          String hafta;
                          int dersHaftasi;

                          String okunanQr = qrController.text.trim();

                          // 1. Boş kontrolü
                          if (okunanQr.isEmpty) {
                            print('qr_empty_error'.tr());
                            return;
                          }

                          String? tamSifreliMetin;

                          try {
                            // 2. Kısa kod (8 karakter) durumu
                            if (okunanQr.length == 8) {
                              // await ekleyerek Future'ın tamamlanmasını bekliyoruz
                              tamSifreliMetin =
                                  await tumDersleriTaraVeUzunQrBul(
                                    fakulteId: widget.userDoc!['fakulte_id'],
                                    bolumId: widget.userDoc!['bolum_id'],
                                    ogrenciDersIdleri: List<String>.from(
                                      widget.userDoc!['dersler'] ?? [],
                                    ),
                                    haftaNo: widget.hafta,
                                    girilenKisaKod: okunanQr,
                                  );

                              if (tamSifreliMetin == null) {
                                print('invalid_code_error'.tr());
                                return;
                              }
                            }
                            // 3. Uzun QR (10+ karakter) durumu
                            else if (okunanQr.length >= 10) {
                              tamSifreliMetin = okunanQr;
                            } else {
                              print('invalid_length_error'.tr());
                              return;
                            }

                            // 4. Şifre Çözme İşlemi (Ortak)
                            sifresizQr = AESHelper.decryptText(tamSifreliMetin);

                            // Veri parçalama
                            List<String> temp = sifresizQr.split("|");
                            if (temp.length < 3) {
                              print('format_error'.tr());
                              return;
                            }

                            dersKodu = temp[0];
                            dersSaatleri = temp[1].split(",");
                            hafta = temp[2];
                            dersHaftasi = int.parse(hafta.split("h")[1]);
                            lat = double.parse(temp[3]);
                            lon = double.parse(temp[4]);

                            print("--- İşlem Başlatılıyor ---");
                            print(
                              "Ders: $dersKodu, Hafta: $dersHaftasi, Saatler: $dersSaatleri, Latitude: $lat, Longtitude: $lon",
                            );

                            checkLocationAndVerify(
                              dersKodu,
                              dersHaftasi,
                              dersSaatleri,
                            );
                          } catch (e) {
                            print("Error: $e");
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return ErrorDialog(
                                  error: 'unexpected_error'.tr(
                                    namedArgs: {'error': e.toString()},
                                  ),
                                  dersKodu: dersKodu,
                                  haftaNo: widget.hafta,
                                  dersSaatleri: dersSaatleri,
                                );
                              },
                            );
                          }
                        },
                        width: width / 2,
                        text: 'confirm_code_button'.tr(),
                        height: height,
                        icon: Icons.arrow_forward_rounded,
                        styleColor: Colors.white,
                        column: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> yoklamayaKatilDirectly({
    required String fakulteId,
    required String bolumId,
    required String dersKodu,
    required int haftaNo,
    required List<String> dersSaatleri,
    required String ogrenciUID,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('Fakulteler')
          .doc(fakulteId)
          .collection('Bolumler')
          .doc(bolumId)
          .collection('Dersler')
          .doc(dersKodu)
          .collection('Acilan_Yoklama_Oturumlari')
          .doc('hafta_$haftaNo');

      Map<String, dynamic> updates = {};

      for (String saat in dersSaatleri) {
        updates['${saat}_KatilanlarId'] = FieldValue.arrayUnion([ogrenciUID]);
      }

      await docRef.update(updates);

      print("✅ Liste başarıyla güncellendi!");
    } catch (e) {
      print("❌ Güncelleme hatası: $e");
    }
  }

  Future<String?> tumDersleriTaraVeUzunQrBul({
    required String fakulteId,
    required String bolumId,
    required List<String> ogrenciDersIdleri,
    required int haftaNo,
    required String girilenKisaKod,
  }) async {
    try {
      // Tüm ders sorgularını paralel olarak başlatıyoruz
      final taramaListesi = ogrenciDersIdleri.map((dersId) async {
        final doc = await FirebaseFirestore.instance
            .collection('Fakulteler')
            .doc(fakulteId)
            .collection('Bolumler')
            .doc(bolumId)
            .collection('Dersler')
            .doc(dersId)
            .collection('Acilan_Yoklama_Oturumlari')
            .doc('hafta_$haftaNo')
            .get();

        if (doc.exists && doc.data()?['kisaQr'] == girilenKisaKod) {
          return doc.data()?['QR'] as String?;
        }
        return null;
      }).toList();

      final sonuclar = await Future.wait(taramaListesi);

      return sonuclar.firstWhere((res) => res != null, orElse: () => null);
    } catch (e) {
      print("Tarama hatası: $e");
      return null;
    }
  }

  Future<void> checkLocationAndVerify(
    String dersKodu,
    int dersHaftasi,
    List<String> dersSaatleri,
  ) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position userPosition = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    double userLat = userPosition.latitude;
    double userLon = userPosition.longitude;

    double distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLon,
      lat,
      lon,
    );

    // 5. 100 metre mesafe kontrolü ve Onaylama
    if (distanceInMeters <= 200) {
      print(
        "Onaylandı: Hedef bölgedesiniz. Mesafe: ${distanceInMeters.toStringAsFixed(2)} metre",
      );
      // 5. Veritabanına Yazma
      await yoklamayaKatilDirectly(
        fakulteId: widget.userDoc!['fakulte_id'],
        bolumId: widget.userDoc!['bolum_id'],
        dersKodu: dersKodu,
        haftaNo: dersHaftasi,
        dersSaatleri: dersSaatleri,
        ogrenciUID: widget.ogrenciUID,
      );

      print("✅ Yoklama işlemi başarıyla tamamlandı.");
      setState(() {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SuccessDialog(
              dersKodu: dersKodu,
              haftaNo: dersHaftasi,
              dersSaatleri: dersSaatleri,
            );
          },
        );
      });
    } else {
      print(
        'out_of_range_error'.tr(
          namedArgs: {'mesafe': distanceInMeters.toStringAsFixed(2)},
        ),
      );
      _showError(
        'out_of_range_error'.tr(
          namedArgs: {'mesafe': distanceInMeters.toStringAsFixed(2)},
        ),
      );
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
