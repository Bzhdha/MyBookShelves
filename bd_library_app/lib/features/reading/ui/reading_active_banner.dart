import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../domain/reading_session_store.dart';
import 'end_reading_session_sheet.dart';

class ReadingActiveBanner extends StatelessWidget{
const ReadingActiveBanner({super.key});
@override Widget build(BuildContext c){
return Consumer<ReadingSessionStore>(builder:(c,store,_){
if(!store.hasActiveSession)return const SizedBox.shrink();
final title=store.activeBook?.title??'Livre';
return Container(
color:kYellow,
padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),
child:Row(children:[
const Icon(Icons.auto_stories,color:kInk,size:18),
const SizedBox(width:10),
Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
Text('SÉANCE EN COURS',style:tMono(9,c:kInk,ls:2)),
Text(title,style:tBebas(18,c:kInk,ls:1),maxLines:1,overflow:TextOverflow.ellipsis),
])),
GestureDetector(
behavior:HitTestBehavior.opaque,
onTap:()=>showEndReadingSessionSheet(c),
child:Container(
padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
decoration:const BoxDecoration(color:kInk,boxShadow:[BoxShadow(color:Color(0x4D000000),offset:Offset(2,2))]),
child:Text('TERMINER',style:tBebas(14,c:kYellow,ls:2)),
)),
]));
});}}
