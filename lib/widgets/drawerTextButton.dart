import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BuildDrawerButton extends StatelessWidget {
  String text;
  IconData icon;
  Color textColor;
  Color iconColor;

  VoidCallback onTop;
  FontWeight fontW;
  BuildDrawerButton({
    super.key,
    required this.text,
    required this.icon,
    required this.textColor,
    required this.iconColor,
    required this.onTop,
    required this.fontW,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    //double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
        onPressed: onTop,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //SizedBox(width: 10),
            Icon(
              icon,
              color: iconColor,
              size: fontW == FontWeight.bold ? height / 40 : height / 50,
            ),
            SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(color: textColor, fontWeight: fontW),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
