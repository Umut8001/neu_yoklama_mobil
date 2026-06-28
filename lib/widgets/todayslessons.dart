import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class Todayslessons extends StatelessWidget {
  String lsName, lsTime, lsTeacher, lsClassroom;
  Todayslessons({
    super.key,
    required this.lsName,
    required this.lsTeacher,
    required this.lsTime,
    required this.lsClassroom,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    //double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Expanded(
        child: Container(
          padding: EdgeInsets.all(20),
          //height: height / 6.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(220, 5, 50, 87),
            border: Border.all(color: Colors.white54),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    lsName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,

                      fontSize: height / 64,
                    ),
                    softWrap: true,
                  ),
                  Spacer(flex: 2),
                  Row(
                    children: [
                      Icon(Icons.watch_later_outlined, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        lsTime,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,

                          fontSize: height / 70,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person_2_outlined, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    lsTeacher,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,

                      fontSize: height / 70,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    lsClassroom,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,

                      fontSize: height / 70,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
