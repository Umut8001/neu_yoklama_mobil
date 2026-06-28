import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final diller = [
      {'ad': 'Türkçe', 'locale': const Locale('tr'), 'bayrak': '🇹🇷'},
      {'ad': 'English', 'locale': const Locale('en'), 'bayrak': '🇬🇧'},
      {'ad': 'العربية', 'locale': const Locale('ar'), 'bayrak': '🇸🇦'},
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Container(
        width: width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
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
              'language_selection'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: width / 25,
              ),
            ),
            SizedBox(height: height / 50),
            Divider(),
            SizedBox(height: height / 80),
            ...diller.map((dil) {
              bool secili = context.locale == dil['locale'];
              return GestureDetector(
                onTap: () {
                  context.setLocale(dil['locale'] as Locale);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: secili
                        ? Color.fromARGB(40, 5, 50, 87)
                        : Color.fromARGB(15, 5, 50, 87),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: secili
                          ? Color.fromARGB(255, 5, 50, 87)
                          : Color.fromARGB(40, 5, 50, 87),
                      width: secili ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dil['bayrak'] as String,
                        style: TextStyle(fontSize: width / 15),
                      ),
                      SizedBox(width: 16),
                      Text(
                        dil['ad'] as String,
                        style: TextStyle(
                          fontSize: width / 25,
                          fontWeight: secili
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color.fromARGB(255, 5, 50, 87),
                        ),
                      ),
                      Spacer(),
                      if (secili)
                        Icon(
                          Icons.check_circle,
                          color: Color.fromARGB(255, 5, 50, 87),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: height / 80),
          ],
        ),
      ),
    );
  }
}
