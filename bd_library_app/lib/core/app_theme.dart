import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kInk=Color(0xFF0D0D0D);
const kPaper=Color(0xFFF5F0E8);
const kYellow=Color(0xFFF5C800);
const kRed=Color(0xFFE02020);
const kBlue=Color(0xFF1A3A8F);
const kMuted=Color(0xFF8A8070);
const kPanelBg=Color(0xFF1A1610);
const kBorder=Color(0xFF2A2520);

TextStyle tBebas(double sz,{Color c=kPaper,double ls=2})=>GoogleFonts.bebasNeue(fontSize:sz,color:c,letterSpacing:ls);
TextStyle tMono(double sz,{Color c=kMuted,double ls=1,FontWeight fw=FontWeight.w400})=>GoogleFonts.spaceMono(fontSize:sz,color:c,letterSpacing:ls,fontWeight:fw);
TextStyle tSerif(double sz,{Color c=kPaper,bool italic=false,FontWeight fw=FontWeight.w400})=>GoogleFonts.crimsonPro(fontSize:sz,color:c,fontStyle:italic?FontStyle.italic:FontStyle.normal,fontWeight:fw);

ThemeData buildBdTheme()=>ThemeData(
  useMaterial3:true,
  colorScheme:const ColorScheme.dark(primary:kYellow,onPrimary:kInk,secondary:kRed,surface:kInk,onSurface:kPaper,tertiary:kBlue),
  scaffoldBackgroundColor:kInk,
  appBarTheme:AppBarTheme(
    backgroundColor:kYellow,foregroundColor:kInk,elevation:0,
    titleTextStyle:GoogleFonts.bebasNeue(fontSize:28,color:kInk,letterSpacing:2),
    iconTheme:const IconThemeData(color:kInk),
  ),
  drawerTheme:const DrawerThemeData(backgroundColor:kPaper),
  tabBarTheme:TabBarThemeData(
    labelColor:kYellow,unselectedLabelColor:kMuted,indicatorColor:kYellow,
    labelStyle:GoogleFonts.bebasNeue(fontSize:14,letterSpacing:2),
    unselectedLabelStyle:GoogleFonts.bebasNeue(fontSize:14,letterSpacing:2),
  ),
  cardTheme:const CardThemeData(color:kPanelBg,elevation:0,margin:EdgeInsets.zero,shape:RoundedRectangleBorder()),
  floatingActionButtonTheme:FloatingActionButtonThemeData(
    backgroundColor:kYellow,foregroundColor:kInk,elevation:0,
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.zero,side:const BorderSide(color:kInk,width:3)),
  ),
  listTileTheme:const ListTileThemeData(textColor:kInk,iconColor:kBlue,tileColor:kPaper),
  dividerColor:const Color(0xFFE0D8C8),
  iconTheme:const IconThemeData(color:kPaper),
  inputDecorationTheme:InputDecorationTheme(
    filled:true,fillColor:kInk,border:InputBorder.none,
    hintStyle:GoogleFonts.spaceMono(fontSize:13,color:const Color(0xFF666666)),
  ),
  progressIndicatorTheme:const ProgressIndicatorThemeData(color:kYellow),
  snackBarTheme:SnackBarThemeData(
    backgroundColor:kPanelBg,contentTextStyle:GoogleFonts.spaceMono(fontSize:12,color:kPaper),
    shape:const RoundedRectangleBorder(),elevation:0,
  ),
  textTheme:TextTheme(
    displayLarge:tBebas(48),displayMedium:tBebas(36),displaySmall:tBebas(28),
    headlineLarge:tBebas(24),headlineMedium:tBebas(20),headlineSmall:tBebas(18),
    titleLarge:tBebas(18),titleMedium:tSerif(16,fw:FontWeight.w600),titleSmall:tSerif(14,fw:FontWeight.w600),
    bodyLarge:tSerif(16),bodyMedium:tSerif(14),bodySmall:tSerif(13,italic:true),
    labelLarge:tMono(12,c:kPaper),labelMedium:tMono(10),labelSmall:tMono(9,ls:3),
  ),
);
