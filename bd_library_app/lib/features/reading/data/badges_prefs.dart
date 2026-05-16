import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BadgesPrefs extends ChangeNotifier {
  static const _key='badges_bg';
  static const options=[
    (Color(0xFF0D0D0D),'Encre'),
    (Color(0xFF1A1610),'Sépia'),
    (Color(0xFF0A1628),'Marine'),
    (Color(0xFF120A1A),'Violet'),
    (Color(0xFF0A1A0A),'Forêt'),
  ];
  Color _bg=options[0].$1;
  Color get bg=>_bg;
  Future<void>load()async{
    final p=await SharedPreferences.getInstance();
    final idx=p.getInt(_key)??0;
    _bg=options[idx.clamp(0,options.length-1)].$1;
    notifyListeners();
  }
  Future<void>setBg(Color c)async{
    if(_bg==c)return;
    _bg=c;
    final idx=options.indexWhere((o)=>o.$1==c);
    if(idx>=0)(await SharedPreferences.getInstance()).setInt(_key,idx);
    notifyListeners();
  }
}
