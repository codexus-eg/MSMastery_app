import 'package:flutter/material.dart';

import '../network/local/shared_pref_helper.dart';

class AppColors {
  static Color appPrimaryColor = SharedPrefHelper.getData('isPurple') ?? false
      ? appPurblePrimaryColor
      : appBluePrimaryColor;
  static Color appSecondaryColor = SharedPrefHelper.getData('isPurple') ?? false
      ? appPurbleSecondaryColor
      : appBlueSecondaryColor;

  static const Color appBluePrimaryColor = Color(0xffA05000);

  static const Color appBlueSecondaryColor = Color(0xffA05000);

  static const Color appPurblePrimaryColor = Color(0xff10666A);
  static const Color appPurbleSecondaryColor = Color(0xff10666A);

  //  Colors.indigo;  or=> (0xff335ef7 ==>  #335ef7)

  static const darkBorder = Color(0xff303030);
  static const lightBborder = Color(0xffdddddd);

  static const darkBgColor = Color(0xff131313);
  static const lightBgColor = Color(0xffeeeeee);
}
