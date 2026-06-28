import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_yoklama_mobil/widgets/elevatedButton.dart';

class SuccessDialog extends StatefulWidget {
  final String dersKodu;
  final int haftaNo;
  final List<String> dersSaatleri;

  const SuccessDialog({
    super.key,
    required this.dersKodu,
    required this.dersSaatleri,
    required this.haftaNo,
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  Map<int, String> gunler = {
    1: 'Pazartesi',
    2: 'Salı',
    3: 'Çarşamba',
    4: 'Perşembe',
    5: 'Cuma',
    6: 'Cumartesi',
    7: 'Pazar',
  };
  List<int> saatler = [];
  int gun = 1;

  @override
  void initState() {
    super.initState();
    for (var element in widget.dersSaatleri) {
      // split işleminin güvenliği için basit bir kontrol eklenebilir
      var parts = element.split('-');
      if (parts.length >= 2) {
        gun = int.parse(parts[1]);
        saatler.add(int.parse(parts[0]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent, // Arka planı şeffaf yapıyoruz
      insetPadding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
      ), // Kenar boşlukları
      child: Container(
        height: height * 0.7, // Yüksekliği biraz azalttım dialog için ideal
        width: width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Biraz daha yumuşak köşeler
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
          children: [
            Gif(
              image: const AssetImage('assets/images/onay-ezgif.com-speed.gif'),
              width: 200, // Dialog içinde 300 biraz büyük kaçabilir, 200 ideal
              height: 200,
              autostart: Autostart.once,
              placeholder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 20),
            Text(
              'Derse Katılımınız Sağlanmıştır.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: height / 45,
              ),
            ),
            const Spacer(),
            _infoText('${widget.haftaNo}. hafta ${gunler[gun]} günü', height),
            const SizedBox(height: 8),
            _infoText('Ders Kodu: ${widget.dersKodu}', height),
            const SizedBox(height: 8),
            _infoText(
              'Ders Saatleri: ${saatler.join(", ")}',
              height,
            ), // toString yerine join daha şık
            const Spacer(flex: 2),
            BuildButton(
              color: Colors.green.shade900,
              onTop: () {
                Navigator.pop(context);
              },
              width: width * 0.7,
              text: 'Tamam',
              height: height / 18,
              icon: null,
              styleColor: Colors.white,
              column: false,
            ),
          ],
        ),
      ),
    );
  }

  // Ortak text stili için yardımcı widget
  Widget _infoText(String text, double screenHeight) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        color: Colors.black87,
        fontSize: screenHeight / 52,
      ),
    );
  }
}
