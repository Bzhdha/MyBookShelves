import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../db/app_db.dart';

class SeriesCompletionSuggestions extends StatelessWidget{
final List<({SeriesData series,int owned,List<int> missing})> data;
const SeriesCompletionSuggestions({super.key,required this.data});

@override Widget build(BuildContext c){
if(data.isEmpty)return const SizedBox.shrink();
final shown=data.take(5).toList();
return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Padding(padding:const EdgeInsets.fromLTRB(16,20,16,10),child:Row(children:[
    const Icon(Icons.trending_up,color:Colors.green,size:16),
    const SizedBox(width:8),
    Text('PRESQUE COMPLETS',style:tMono(9,c:Colors.green,ls:3)),
    const Spacer(),
    Text('${data.length} série${data.length>1?"s":""}',style:tMono(9,ls:1)),
  ])),
  ...shown.map((e)=>_card(e)),
]);}

Widget _card(({SeriesData series,int owned,List<int> missing}) e){
  final exp=e.series.expectedVolumes!;final pct=e.owned/exp;
  final next=e.missing.first;final name=e.series.name;
  return Container(
    margin:const EdgeInsets.fromLTRB(16,0,16,10),
    decoration:BoxDecoration(color:kPanelBg,border:Border.all(color:const Color(0xFF1A3A1A),width:1.5)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Padding(padding:const EdgeInsets.fromLTRB(12,10,12,6),child:Row(children:[
        Expanded(child:Text(name,style:tBebas(18),maxLines:1,overflow:TextOverflow.ellipsis)),
        Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:2),color:Colors.green.shade800,
          child:Text('${(pct*100).round()}%',style:tBebas(13,c:kPaper))),
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(12,0,12,4),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        ClipRRect(borderRadius:BorderRadius.circular(2),child:LinearProgressIndicator(value:pct,backgroundColor:kBorder,color:Colors.green,minHeight:4)),
        const SizedBox(height:3),
        Text('${e.owned} / $exp tome${exp>1?"s":""}  ·  ${e.missing.length} manquant${e.missing.length>1?"s":""}',style:tMono(10)),
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(12,6,12,10),child:Row(children:[
        Text('Prochain : ',style:tMono(10)),
        Container(margin:const EdgeInsets.only(right:10),padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),color:const Color(0xFF2A2A0A),
          child:Text('T.$next',style:tBebas(14,c:kYellow))),
        _btn('LBC',kYellow,()=>_lbc('$name tome $next')),
        const SizedBox(width:4),
        _btn('Vinted',const Color(0xFF00A86B),()=>_vtd('$name tome $next')),
      ])),
    ]));
}

Widget _btn(String label,Color color,VoidCallback onTap)=>InkWell(onTap:onTap,child:Container(
  padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
  color:color,child:Text(label,style:tBebas(11,c:kInk))));

void _lbc(String q)async{await launchUrl(Uri.parse('https://www.leboncoin.fr/recherche?text=${Uri.encodeComponent(q)}&category=27'),mode:LaunchMode.externalApplication);}
void _vtd(String q)async{await launchUrl(Uri.parse('https://www.vinted.fr/catalog?search_text=${Uri.encodeComponent(q)}'),mode:LaunchMode.externalApplication);}
}
