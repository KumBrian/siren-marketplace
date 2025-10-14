import 'dart:ui';

import 'package:siren_marketplace/core/types/enum.dart';

class AppColors {
  //SIREN BLUE
  static const blue100 = Color(0XFFE5F4FF);
  static const blue300 = Color(0XFFB1DBFC);
  static const blue400 = Color(0XFF71B2E5);
  static const blue500 = Color(0XFF3A8AC9);
  static const blue600 = Color(0XFF096DBB);
  static const blue700 = Color(0XFF075796);
  static const blue800 = Color(0XFF073B60);
  static const blue850 = Color(0XFF042B4A);
  static const blue900 = Color(0XFF08253B);

  //SIREN SHELL
  static const shell100 = Color(0XFFFFF7EB);
  static const shell300 = Color(0XFFFFDEAE);
  static const shell400 = Color(0XFFFDB64A);
  static const shellOrange = Color(0XFFFF9800);
  static const shell600 = Color(0XFFA36104);
  static const shell700 = Color(0XFF663C00);
  static const shell900 = Color(0XFF2B1800);

  //SIREN WHITE
  static const white100 = Color(0XFFFFFFFF);

  //SIREN FAIL
  static const fail100 = Color(0XFFFEE8E6);
  static const fail500 = Color(0XFFE70909);
  static const fail700 = Color(0XFF620404);

  //SIREN SUCCESS
  static const success100 = Color(0XFFEBFFE8);
  static const success500 = Color(0XFF138101);
  static const success700 = Color(0XFF093D00);

  //SIREN WARNING
  static const warning100 = Color(0XFFFFF2E5);
  static const warning500 = Color(0XFFFFCC00);
  static const warning700 = Color(0XFF332900);

  //SIREN GRAY
  static const gray25 = Color(0XFFFAFAFA);
  static const gray50 = Color(0XFFF2F2F2);
  static const gray100 = Color(0XFFE6E6E6);
  static const gray200 = Color(0XFFCCCCCC);
  static const gray300 = Color(0XFFB8C3CC);
  static const gray500 = Color(0XFF808080);
  static const gray650 = Color(0XFF595959);
  static const gray750 = Color(0XFF404040);
  static const gray900 = Color(0XFF191919);

  //SIREN TEXTS
  static const textBlue = Color(0XFF042B4A);
  static const textGray = Color(0XFF72868D);
  static const textWhite = Color(0XFFFFFFFF);

  static Color getStatusColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.pending:
        return AppColors.shellOrange;
      case OfferStatus.accepted:
        return AppColors.blue400;
      case OfferStatus.completed:
        return AppColors.textGray;
      case OfferStatus.rejected:
        return AppColors.fail500;
      case OfferStatus.countered:
        return AppColors.textGray;
    }
  }
}
