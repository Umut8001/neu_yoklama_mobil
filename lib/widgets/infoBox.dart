import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class HPInfoBox extends StatelessWidget {
  IconData icon;
  String? title, subtitle;
  Color iconBGColor;
  bool column;
  VoidCallback fonksiyon;
  HPInfoBox({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBGColor,
    required this.column,
    required this.fonksiyon,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Expanded(
      child: GestureDetector(
        onTap: fonksiyon,
        child: Container(
          margin: EdgeInsets.all(2),
          //padding: EdgeInsets.all(10),
          width: width / 2.4,
          height: column ? width / 2.4 : width / 4,
          decoration: BoxDecoration(
            color: const Color.fromARGB(220, 5, 50, 87),
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: iconBGColor,
                ),
                margin: EdgeInsets.only(top: 12, bottom: 8),
                padding: EdgeInsets.all(1),
                child: Icon(icon, color: Colors.white),
              ),
              Divider(color: Colors.white38, endIndent: 10, indent: 10),

              Text(
                title ?? '',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,

                  fontSize: height / 48,
                ),
                softWrap: true,
              ),
              Spacer(),
              column
                  ? Text(
                      subtitle ?? '',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,

                        fontSize: height / 40,
                      ),
                      softWrap: true,
                    )
                  : SizedBox(),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
