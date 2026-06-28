import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_device/safe_device.dart';
import 'package:qr_yoklama_mobil/pages/novBarPages/nb_home_page.dart';
import 'package:qr_yoklama_mobil/pages/novBarPages/nb_profile.dart';
import 'package:qr_yoklama_mobil/pages/novBarPages/nb_qr_scanner_page.dart';
import 'package:qr_yoklama_mobil/pages/sign_in_page.dart';

class HomePage extends StatefulWidget {
  final String userUID;
  final String son_giris_tarihi;
  const HomePage({
    super.key,
    required this.userUID,
    required this.son_giris_tarihi,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;
  DocumentSnapshot? userDoc;
  bool isLoading = true;
  late StreamSubscription _mockLocationSub;
  int dersHaftasi = 1;
  String bolumIsim = '';
  List<Map<String, dynamic>> bugunkuDersler = [];
  final List<Map<String, dynamic>> tumDersler = [];
  bool _isDialogShowing = false;
  bool _isChecking = false; // Eş zamanlı kontrol engelleyici

  @override
  void initState() {
    super.initState();
    _requestLocationPermission().then((_) {
      _checkMockLocationPeriodic();
    });
    initData();
  }

  @override
  void dispose() {
    _mockLocationSub.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _checkMockLocationPeriodic() {
    // İlk açılışta hemen kontrol et
    _checkMockLocation();
    // Sonra her 2 saniyede bir kontrol et
    _mockLocationSub = Stream.periodic(const Duration(seconds: 2)).listen((
      _,
    ) async {
      await _checkMockLocation();
    });
  }

  Future<void> _checkMockLocation() async {
    // Dialog açıksa veya zaten kontrol yapılıyorsa geç
    if (_isDialogShowing || _isChecking) return;
    _isChecking = true;

    try {
      // --- Kontrol 1: SafeDevice ---
      final bool safeDeviceMock = await SafeDevice.isMockLocation;

      // --- Kontrol 2: Geolocator isMocked ---
      bool geolocatorMock = false;
      try {
        final LocationPermission permission =
            await Geolocator.checkPermission();
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
          geolocatorMock = position.isMocked;
          debugPrint(
            'SafeDevice: $safeDeviceMock | Geolocator isMocked: $geolocatorMock',
          );
        }
      } catch (e) {
        debugPrint('Geolocator kontrol hatası: $e');
      }

      // İkisinden biri bile true dönerse sahte konum var demektir
      if ((safeDeviceMock || geolocatorMock) && mounted) {
        _showMockLocationDialog();
      }
    } catch (e) {
      debugPrint('Mock konum kontrol hatası: $e');
    } finally {
      _isChecking = false;
    }
  }

  void _showMockLocationDialog() {
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Güvenlik Uyarısı'),
        content: const Text(
          'Sahte konum (Mock Location) uygulaması tespit edildi. '
          'Güvenlik nedeniyle oturumunuz kapatılacak.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isDialogShowing = false;
              Navigator.of(ctx).pop();
              signOut();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    ).then((_) => _isDialogShowing = false);
  }

  Future<void> initData() async {
    setState(() => isLoading = true);
    try {
      DocumentSnapshot? doc = await getUserDoc(widget.userUID);

      if (doc != null && doc.exists) {
        setState(() {
          userDoc = doc;
        });
        await getHafta();
        await getOgrDersData(mevcutHafta: dersHaftasi);
        await getBolumIsim();
      }
    } catch (e) {
      debugPrint('InitData Hatası: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<DocumentSnapshot?> getUserDoc(String uid) async {
    try {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
    } catch (e) {
      debugPrint("UserDoc Hatası: $e");
      return null;
    }
  }

  Future<void> getHafta() async {
    final doc = await FirebaseFirestore.instance.doc('Fakulteler/100').get();
    DateTime baslangic = (doc.get('donem_baslangic') as Timestamp).toDate();
    dersHaftasi = kacinciHaftadayiz(baslangic);
  }

  Future<void> getBolumIsim() async {
    try {
      final doc = await FirebaseFirestore.instance
          .doc('Fakulteler/100/Bolumler/011')
          .get();
      if (mounted) {
        setState(() {
          bolumIsim = doc['bolum_isim'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("BolumIsim Hatası: $e");
    }
  }

  Future<void> getOgrDersData({required int mevcutHafta}) async {
    if (userDoc == null) return;

    int bugun = DateTime.now().weekday;
    List<dynamic> aldigiDersler = userDoc!.get('dersler') ?? [];
    List<Map<String, dynamic>> geciciListe = [];

    for (String dersKodu in aldigiDersler) {
      try {
        DocumentSnapshot dersDoc = await FirebaseFirestore.instance
            .collection('Fakulteler')
            .doc(userDoc!['fakulte_id'])
            .collection('Bolumler')
            .doc(userDoc!['bolum_id'])
            .collection('Dersler')
            .doc(dersKodu)
            .get();

        if (!dersDoc.exists) continue;

        final data = dersDoc.data() as Map<String, dynamic>;
        List<dynamic> takvim = data['ders_takvimi'] ?? [];

        String ogretmenAd = '';
        String ogretmenId = data['ogretmen_id'] ?? '';
        if (ogretmenId.isNotEmpty) {
          try {
            DocumentSnapshot ogretmenDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(ogretmenId)
                .get();
            if (ogretmenDoc.exists) {
              ogretmenAd = '${ogretmenDoc['isim']} ${ogretmenDoc['soyisim']}';
            }
          } catch (e) {
            debugPrint("Öğretmen Hatası: $e");
          }
        }

        int toplamAcilanOturum = 0;
        int katilinanOturum = 0;
        try {
          QuerySnapshot oturumlar = await FirebaseFirestore.instance
              .collection('Fakulteler')
              .doc(userDoc!['fakulte_id'])
              .collection('Bolumler')
              .doc(userDoc!['bolum_id'])
              .collection('Dersler')
              .doc(dersKodu)
              .collection('Acilan_Yoklama_Oturumlari')
              .get();

          for (var haftaDoc in oturumlar.docs) {
            final haftaData = haftaDoc.data() as Map<String, dynamic>;
            haftaData.forEach((key, value) {
              if (key.endsWith('_KatilanlarId') && value is List) {
                toplamAcilanOturum++;
                if (value.contains(userDoc!.id)) {
                  katilinanOturum++;
                }
              }
            });
          }
        } catch (e) {
          debugPrint("Devamsızlık Hatası ($dersKodu): $e");
        }

        double devamsizlikOrani = (data['devamsizlik_orani'] ?? 0.30)
            .toDouble();
        int haftalikDersSaati = data['haftalik_ders_saati'] ?? 0;
        int toplamOlasiSaat = haftalikDersSaati * mevcutHafta;
        int devamsizlikLimiti = (toplamOlasiSaat * devamsizlikOrani).floor();
        int katilmadigiSaat = toplamOlasiSaat - katilinanOturum;
        bool kalirMi = katilmadigiSaat > devamsizlikLimiti;

        Map<String, dynamic> dersBilgisi = {
          'dersKodu': dersKodu,
          'dersAd': data['ders_ad'] ?? '',
          'dersSinif': data['ders_sinif'] ?? '',
          'fakulteId': userDoc!['fakulte_id'] ?? '',
          'bolumId': userDoc!['bolum_id'] ?? '',
          'haftalikDersSaati': haftalikDersSaati,
          'islenenDersSaati': data['islenen_ders_saati'] ?? 0,
          'ogretmenId': ogretmenId,
          'ogretmenAd': ogretmenAd,
          'sezon': data['sezon'] ?? '',
          'yil': data['yil'] ?? '',
          'ogrenciListesi': data['ogrenci_listesi'] ?? {},
          'toplamAcilanOturum': toplamAcilanOturum,
          'katilinanOturum': katilinanOturum,
          'katilmadigiOturum': toplamAcilanOturum - katilinanOturum,
          'devamsizlikOrani': devamsizlikOrani,
          'toplamOlasiSaat': toplamOlasiSaat,
          'devamsizlikLimiti': devamsizlikLimiti,
          'katilmadigiSaat': katilmadigiSaat,
          'kalirMi': kalirMi,
        };

        for (var dersSaati in takvim) {
          Map<String, dynamic> kayit = {
            ...dersBilgisi,
            'saat': dersSaati['saat'],
            'gun': dersSaati['gun'],
          };
          tumDersler.add(kayit);
          if (dersSaati['gun'] == bugun) {
            geciciListe.add(kayit);
          }
        }
      } catch (e) {
        debugPrint("Ders Detay Hatası ($dersKodu): $e");
      }
    }

    if (mounted) {
      setState(() {
        bugunkuDersler = geciciListe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 0, 161, 201),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final List<Widget> kTabPages = [
      NbHomePage(
        userDoc: userDoc,
        son_giris_tarihi: widget.son_giris_tarihi,
        bugunkuDersler: bugunkuDersler,
        tumDersler: tumDersler,
      ),
      NbQrScannerPage(
        ogrenciUID: widget.userUID,
        userDoc: userDoc,
        hafta: dersHaftasi,
      ),
      NbProfile(userDoc: userDoc, bolumIsim: bolumIsim),
    ];

    return Scaffold(
      body: kTabPages[_currentTabIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    double width = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 161, 201)),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          iconSize: width / 15,
          backgroundColor: const Color.fromARGB(255, 5, 50, 87),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _currentTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentTabIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: 'nav_home'.tr(),
            ),
            BottomNavigationBarItem(icon: _buildQrIcon(), label: 'nav_qr'.tr()),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_2_outlined),
              label: 'nav_profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.circular(15),
        color: Colors.green.shade900,
      ),
      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  int kacinciHaftadayiz(DateTime baslangicTarihi) {
    DateTime bugun = DateTime.now();
    int fark = bugun.difference(baslangicTarihi).inDays;
    int hafta = (fark / 7).floor() + 1;
    if (hafta < 1) return 1;
    if (hafta > 14) return 14;
    return hafta;
  }
}
