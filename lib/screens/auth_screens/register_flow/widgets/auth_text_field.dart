import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final IconData? icon;
  final Color primaryColor;
  final String fontFamily;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? suffixIcon;
  final bool obscureText;
  final int? maxLength;
  final String? hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.primaryColor,
    required this.fontFamily,
    required this.keyboardType,
    required this.textInputAction,
    this.focusNode,
    this.icon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLength,
    this.hintText,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = 14.0;
    final fillColor = Colors.white;
    final hintColor = Colors.black.withValues(alpha: 0.45);

    OutlineInputBorder buildBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      cursorColor: primaryColor,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        color: const Color(0xff1a1a1a),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: hintColor,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: hintColor,
          fontSize: 13,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: fontFamily,
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: icon == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                child: Icon(icon, color: primaryColor, size: 22),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: buildBorder(Colors.black.withValues(alpha: 0.08), 1),
        enabledBorder: buildBorder(Colors.black.withValues(alpha: 0.08), 1),
        focusedBorder: buildBorder(primaryColor, 1.6),
        errorBorder: buildBorder(Colors.redAccent.shade200, 1),
        focusedErrorBorder: buildBorder(Colors.redAccent, 1.6),
        errorStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
