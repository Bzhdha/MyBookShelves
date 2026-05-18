import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../db/app_db.dart';

class AutoSuggestMissingVolumes extends StatelessWidget{
final List<({SeriesData series,List<int> gaps})> data;
const AutoSuggestMissingVolumes({super.key,required this.data});

@override Widget build(BuildContext c){
if(data.isEmpty)return const SizedBox.shrink();
final shown=data.take(5).toList();
return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Padding(padding:const EdgeInsets.fromLTRB(16,20,16,10),child:Row(children:[
    const Icon(Icons.auto_fix_high,color:Colors.amber,size:16),
    const SizedBox(width:8),
    Text('LACUNES DÉTECTÉES',style:tMono(9,c:Colors.amber,ls:3)),
    const Spacer(),
    Text('${data.length} série${data.length>1?"s":""}',style:tMono(9,ls:1)),
  ])),
  ...shown.map((e)=>_card(e)),
]);}

Widget _card(({SeriesData series,List<int> gaps}) e){
  final name=e.series.name;final gaps=e.gaps;
  return Container(
    margin:const EdgeInsets.fromLTRB(16,0,16,10),
    decoration:BoxDecoration(color:kPanelBg,border:Border.all(color:const Color(0xFF3A2800),width:1.5)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Padding(padding:const EdgeInsets.fromLTRB(12,10,12,6),child:Row(children:[
        Expanded(child:Text(name,style:tBebas(18),maxLines:1,overflow:TextOverflow.ellipsis)),
        Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:2),color:Colors.amber.shade800,
          child:Text('${gaps.length} lacune${gaps.length>1?"s":""}',style:tBebas(13,c:kInk))),
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(12,0,12,10),child:Wrap(spacing:8,runSpacing:8,
        children:gaps.map((t)=>_chip(name,t)).toList())),
    ]));
}

Widget _chip(String name,int t)=>Container(
  padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
  decoration:BoxDecoration(color:kInk,border:Border.all(color:const Color(0xFF3A2800),width:1)),
  child:Row(mainAxisSize:MainAxisSize.min,children:[
    Text('T.$t  ',style:tBebas(14,c:kPaper)),
    _btn('LBC',kYellow,()=>_lbc('$name tome $t')),
    const SizedBox(width:4),
    _btn('Vinted',const Color(0xFF00A86B),()=>_vtd('$name tome $t')),
  ]));

Widget _btn(String label,Color color,VoidCallback onTap)=>InkWell(onTap:onTap,child:Container(
  padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
  color:color,child:Text(label,style:tBebas(11,c:kInk))));

void _lbc(String q)async{await launchUrl(Uri.parse('https://www.leboncoin.fr/recherche?text=${Uri.encodeComponent(q)}&category=27'),mode:LaunchMode.externalApplication);}
void _vtd(String q)async{await launchUrl(Uri.parse('https://www.vinted.fr/catalog?search_text=${Uri.encodeComponent(q)}'),mode:LaunchMode.externalApplication);}
}
