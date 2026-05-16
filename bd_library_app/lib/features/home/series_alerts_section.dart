import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../db/app_db.dart';

class SeriesAlertsSection extends StatelessWidget{
final List<(SeriesData,List<int>)> data;
const SeriesAlertsSection({super.key,required this.data});
@override Widget build(BuildContext c){
if(data.isEmpty)return const SizedBox.shrink();
return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Padding(padding:const EdgeInsets.fromLTRB(16,16,16,10),child:Row(children:[
    const Icon(Icons.notification_important,color:Colors.orange,size:16),
    const SizedBox(width:8),
    Text('TOMES MANQUANTS',style:tMono(9,c:Colors.orange,ls:3)),
  ])),
  ...data.map((e){
    final s=e.$1;final m=e.$2;
    return Container(
      margin:const EdgeInsets.fromLTRB(16,0,16,10),
      decoration:BoxDecoration(color:kPanelBg,border:Border.all(color:const Color(0xFF553322),width:1.5)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Padding(padding:const EdgeInsets.fromLTRB(12,10,12,6),child:Row(children:[
          Expanded(child:Text(s.name,style:tBebas(18),maxLines:1,overflow:TextOverflow.ellipsis)),
          Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:2),color:kRed,child:Text('${m.length}✗',style:tBebas(13,c:kPaper))),
        ])),
        Padding(padding:const EdgeInsets.fromLTRB(12,0,12,10),child:Wrap(spacing:6,runSpacing:6,children:m.map((t)=>_chip(s.name,t)).toList())),
      ]));
  }),
]);}

Widget _chip(String name,int t)=>Container(
  padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
  decoration:BoxDecoration(color:kInk,border:Border.all(color:kBorder,width:1)),
  child:Row(mainAxisSize:MainAxisSize.min,children:[
    Text('T.$t  ',style:tBebas(14,c:kPaper)),
    _mktBtn('LBC',kYellow,()=>_lbc('$name tome $t')),
    const SizedBox(width:4),
    _mktBtn('Vinted',const Color(0xFF00A86B),()=>_vtd('$name tome $t')),
  ]));

Widget _mktBtn(String label,Color color,VoidCallback onTap)=>InkWell(onTap:onTap,child:Container(
  padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
  color:color,child:Text(label,style:tBebas(11,c:kInk))));

void _lbc(String q)async{await launchUrl(Uri.parse('https://www.leboncoin.fr/recherche?text=${Uri.encodeComponent(q)}&category=27'),mode:LaunchMode.externalApplication);}
void _vtd(String q)async{await launchUrl(Uri.parse('https://www.vinted.fr/catalog?search_text=${Uri.encodeComponent(q)}'),mode:LaunchMode.externalApplication);}
}
