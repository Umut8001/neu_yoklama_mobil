import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BuildTextFormField extends StatefulWidget {
  final Color color, iconColor;
  final double width;
  final String text;
  final IconData icon;
  final bool suffix;
  final TextEditingController controller;
  final TextInputType inputtype;
  Function? onChanged;
  var validator;
  bool isDark;
  BuildTextFormField({
    super.key,
    required this.color,
    required this.width,
    required this.text,
    required this.iconColor,
    required this.icon,
    required this.suffix,
    required this.controller,
    required this.isDark,
    required this.inputtype,
    required this.validator,

    this.onChanged,
  });

  @override
  State<BuildTextFormField> createState() => _BuildTextFormField();
}

class _BuildTextFormField extends State<BuildTextFormField> {
  bool _passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    //bool isDark = widget.isDark;
    return SizedBox(
      width: widget.width,

      child: TextFormField(
        onChanged: (value) {
          widget.onChanged;
        },
        keyboardType: widget.inputtype,
        validator: widget.validator,

        controller: widget.controller,
        obscureText: widget.suffix ? _passwordVisible : false,
        cursorColor: widget.color,
        style: TextStyle(color: widget.color),
        decoration: InputDecoration(
          labelText: widget.text,
          labelStyle: TextStyle(color: widget.color),

          prefixIcon: Icon(
            widget.icon,
            color: widget.iconColor,
            /*color: isDark
                ? DarkColors.okulHesapInputText
                : LightColors.okulHesapInputText,*/
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade100, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          suffixIcon: widget.suffix
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: widget.iconColor,
                    /*color: isDark
                        ? DarkColors.okulHesapInputText
                        : LightColors.okulHesapInputText,*/
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
