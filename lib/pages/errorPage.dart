import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_yoklama_mobil/widgets/elevatedButton.dart';

class ErrorDialog extends StatefulWidget {
  final String dersKodu;
  final int haftaNo;
  final List<String> dersSaatleri;
  final String error;

  const ErrorDialog({
    super.key,
    required this.dersKodu,
    required this.dersSaatleri,
    required this.haftaNo,
    required this.error,
  });

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  // Günleri JSON keylerine eşledik
  Map<int, String> gunler = {
    1: 'monday',
    2: 'tuesday',
    3: 'wednesday',
    4: 'thursday',
    5: 'friday',
    6: 'saturday',
    7: 'sunday',
  };
  List<int> saatler = [];
  int gun = 1;

  @override
  void initState() {
    super.initState();
    for (var element in widget.dersSaatleri) {
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
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Container(
        height: height * 0.65,
        width: width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/hata1.png', width: 200),
            const SizedBox(height: 10),
            Text(
              'attendance_failed'
                  .tr(), // JSON: Derse Katılımınız Başarısız Olmuştur.
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900,
                fontSize: height / 45,
              ),
            ),
            const Spacer(),

            // Gelen hata mesajı (Zaten tr() ile sarmalanmış halde gelecek)
            _infoText(widget.error, height),
            const SizedBox(height: 8),

            // Hafta ve Gün Bilgisi (Örn: 3. hafta Pazartesi günü)
            _infoText(
              'attendance_info_line'.tr(
                namedArgs: {
                  'hafta': widget.haftaNo.toString(),
                  'gun': gunler[gun]!.tr(), // Gün ismini de çevirdik
                },
              ),
              height,
            ),
            const SizedBox(height: 8),

            // Ders Kodu
            _infoText(
              'course_code_label'.tr(namedArgs: {'kod': widget.dersKodu}),
              height,
            ),
            const SizedBox(height: 8),

            // Ders Saatleri
            _infoText(
              'course_hours_label'.tr(
                namedArgs: {'saatler': saatler.join(", ")},
              ),
              height,
            ),
            const Spacer(flex: 2),

            BuildButton(
              color: Colors.grey.shade800,
              onTop: () {
                Navigator.pop(context);
              },
              width: width * 0.7,
              text: 'close_button'.tr(), // JSON: Kapat
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

  Widget _infoText(String text, double screenHeight) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        color: Colors.black54,
        fontSize: screenHeight / 52,
      ),
    );
  }
}
