import 'package:flutter/material.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/config/theme/dark_colors.dart';
import 'package:webinar/config/theme/light_colors.dart';


/// Main Color
Color green77() => isLightMode() ? lightGreen77() : darkGreen6B();
Color green91() => isLightMode() ? lightGreen91() : darkGreenA5();
Color blue64() => isLightMode() ? lightBlue64() : darkBlueA6();
LinearGradient get greenGradint => LinearGradient(
  colors: [
    green77(),
    green91()
  ],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter
);

Color get whiteFF_26 => isLightMode() ? Colors.white : darkGrey26;

// use in drawer background color
Color get green63 => isLightMode() ? lightGreen63 : darkGreen56;

// grey Shade
Color get grey33 => isLightMode() ? lightGrey33 : darkGreyE5;
Color get grey3A => isLightMode() ? lightGrey3A : darkGreyF6;
Color get grey5E => isLightMode() ? lightGrey5E : darkGreyA3;
Color get greyD0 => isLightMode() ? lightGreyD0 : darkGrey45;
Color get greyB2 => isLightMode() ? lightGreyB2 : darkGrey48;
// Color get greyA5 => isLightMode() ? lightGreyA5 : darkGrey4A;
Color get greyA5 => isLightMode() ? lightGreyA5 : Colors.white;
Color get greyCF => isLightMode() ? lightGreyCF : darkGrey3A;
Color get greyE7 => isLightMode() ? lightGreyE7 : darkGrey12;
Color get greyF8 => isLightMode() ? lightGreyF8 : darkGrey1A;
Color get greyFA => isLightMode() ? lightGreyFA : darkGrey26;

Color get backgroundColor => isLightMode() ? lightGreyFA : darkGrey1A;

LinearGradient greyGradint = LinearGradient(
  colors: [
    Colors.black.withOpacity(.8),
    Colors.black.withOpacity(0),
  ],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter
);



// Semantics
Color get red49 => isLightMode() ? lightRed49 : darkRed6B;
Color get yellow29 => isLightMode() ? lightYellow29 : darkYellow00;
Color get orange50 => isLightMode() ? lightOrange50 : darkOrange3C;



// Semantics
Color get green50 => isLightMode() ? lightGreen50 : darkGreen3F;
Color get green4B => isLightMode() ? lightGreen4B : darkGreen3C;
Color get green9D => isLightMode() ? lightGreen9D : darkGreen8A;

Color get cyan50 => isLightMode() ? lightCyan50 : darkCyan8A;
Color get blueFE => isLightMode() ? lightBlueFE : darkBlueE8;
Color get blueA4 => isLightMode() ? lightBlueA4 : darkBlue7F;
Color get yellow4C => isLightMode() ? lightYellow4C : darkYellow2C;


Color get textColorGrey33 => isLightMode() ? grey33 : Colors.white;

// Shadow
BoxShadow boxShadow(Color color,{int blur=20,int y=8,int x=0}){

  // bool isBlack(Color color, {int tolerance = 10}) {
  //   return color.r <= tolerance &&
  //         color.g <= tolerance &&
  //         color.b <= tolerance;
  // }

  return BoxShadow(
    // color: isBlack(color) ? Colors.white.withOpacity(color.a) : color,
    color: color,
    blurRadius: blur.toDouble(),
    offset: Offset(x.toDouble(), y.toDouble())
  );
}