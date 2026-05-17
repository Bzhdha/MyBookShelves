import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../db/app_db.dart';
import '../books/ui/book_detail_page.dart';
import 'series_completion_suggestions.dart';

class SeriesPage extends StatefulWidget{const SeriesPage({super.key});@override State<SeriesPage> createState()=>_SPState();}
class _SPState extends State<SeriesPage>{
List<SeriesData> _series=[];Map<String,List<Book>> _books={};String _q='';
List<({SeriesData series,int owned,List<int> missing})> _suggestions=[];
final _sc=TextEditingController();

@override void initState(){super.initState();_sc.addListener((){if(mounted)setState((){_q=_sc.text.trim();});});_load();}
@override void dispose(){_sc.dispose();super.dispose();}

Future<void> _load()async{
  final db=context.read<AppDb>();
  final all=await db.getAllSeries();
  final m=<String,List<Book>>{};
  for(final s in all){final books=await db.getBooksBySeries(s.id);books.sort((a,b)=>(a.volumeNumber??9999).compareTo(b.volumeNumber??9999));m[s.id]=books;}
  final sg=await db.getSeriesCompletionSuggestions();
  if(mounted)setState((){_series=all;_books=m;_suggestions=sg;});}

@override Widget build(BuildContext c)=>Scaffold(
  backgroundColor:kInk,
  appBar:AppBar(backgroundColor:kYellow,elevation:0,title:Text('Séries',style:tBebas(28,c:kInk,ls:2)),iconTheme:const IconThemeData(color:kInk)),
  body:Column(children:[
    _searchBar(),
    Expanded(child:RefreshIndicator(color:kYellow,backgroundColor:kInk,onRefresh:_load,child:_list())),
  ]));

Widget _searchBar()=>Container(
  color:kPanelBg,padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),
  child:TextField(controller:_sc,style:tMono(13,c:kPaper,ls:0.5),
    decoration:InputDecoration(
      hintText:'Rechercher une série…',hintStyle:tMono(13,c:kMuted),
      prefixIcon:const Icon(Icons.search,color:kMuted,size:18),
      isDense:true,contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:10),
      enabledBorder:OutlineInputBorder(borderSide:const BorderSide(color:kBorder),borderRadius:BorderRadius.circular(4)),
      focusedBorder:OutlineInputBorder(borderSide:const BorderSide(color:kYellow),borderRadius:BorderRadius.circular(4)),
      suffixIcon:_q.isNotEmpty?IconButton(icon:const Icon(Icons.clear,color:kMuted,size:16),onPressed:_sc.clear,padding:EdgeInsets.zero,constraints:const BoxConstraints(minWidth:32,minHeight:32)):null)));

Widget _list(){
  final f=_q.isEmpty?_series:_series.where((s)=>s.name.toLowerCase().contains(_q.toLowerCase())).toList();
  final showSug=_q.isEmpty&&_suggestions.isNotEmpty;
  if(f.isEmpty&&!showSug)return ListView(physics:const AlwaysScrollableScrollPhysics(),children:[Padding(padding:const EdgeInsets.only(top:80),child:Center(child:Text(_q.isEmpty?'Aucune série':'Aucun résultat',style:tBebas(18,c:kMuted))))]);
  return ListView.builder(
    physics:const AlwaysScrollableScrollPhysics(),
    itemCount:(showSug?1:0)+(f.isEmpty?0:f.length*2-1),
    itemBuilder:(c,i){
      if(showSug){
        if(i==0)return SeriesCompletionSuggestions(data:_suggestions);
        i--;
      }
      final idx=i~/2;
      if(i.isOdd)return const Divider(color:kBorder,height:1);
      return _tile(c,f[idx]);
    });}

Widget _tile(BuildContext c,SeriesData s){
  final books=_books[s.id]??[];
  final owned=books.map((b)=>b.volumeNumber).whereType<int>().toSet();
  final exp=s.expectedVolumes;
  final missing=exp!=null&&exp>0?[for(int i=1;i<=exp;i++) if(!owned.contains(i)) i]:<int>[];
  return ExpansionTile(
    backgroundColor:kPanelBg,collapsedBackgroundColor:kInk,
    tilePadding:const EdgeInsets.fromLTRB(16,4,16,4),
    childrenPadding:EdgeInsets.zero,
    title:Row(children:[Expanded(child:Text(s.name,style:tBebas(20),maxLines:1,overflow:TextOverflow.ellipsis)),if(missing.isNotEmpty)Container(margin:const EdgeInsets.only(left:8),padding:const EdgeInsets.symmetric(horizontal:8,vertical:2),color:kRed,child:Text('${missing.length}✗',style:tBebas(13,c:kPaper)))]),
    subtitle:_prog(books.length,exp,missing.length),
    children:[
      if(missing.isNotEmpty)_missingSection(s.name,missing),
      if(books.isNotEmpty)_ownedSection(c,books),
      _mktRow(s.name),
    ]);}

Widget _prog(int n,int? exp,int miss){
  if(exp==null||exp<=0)return Text('$n tome${n>1?"s":""}',style:tMono(11,c:kMuted));
  final pct=(n/exp).clamp(0.0,1.0);
  return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const SizedBox(height:4),
    ClipRRect(borderRadius:BorderRadius.circular(2),child:LinearProgressIndicator(value:pct,backgroundColor:kBorder,color:miss>0?Colors.orange:Colors.green,minHeight:5)),
    const SizedBox(height:3),
    Text('$n / $exp tome${exp>1?"s":""}${miss>0?" · $miss manquant${miss>1?"s":""}":""}',style:tMono(10,c:kMuted)),
  ]);}

Widget _missingSection(String name,List<int> missing)=>Container(
  color:const Color(0xFF1A1008),
  padding:const EdgeInsets.fromLTRB(16,10,16,14),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('TOMES MANQUANTS',style:tMono(9,c:kRed,ls:3)),
    const SizedBox(height:10),
    Wrap(spacing:8,runSpacing:8,children:missing.map((t)=>_missingChip(name,t)).toList()),
  ]));

Widget _missingChip(String name,int t)=>Container(
  padding:const EdgeInsets.all(10),
  decoration:BoxDecoration(color:kInk,border:Border.all(color:const Color(0xFF553322),width:1.5)),
  child:Column(mainAxisSize:MainAxisSize.min,children:[
    Text('Tome $t',style:tBebas(16,c:kPaper)),
    const SizedBox(height:8),
    Row(mainAxisSize:MainAxisSize.min,children:[
      _mktChip('LBC',kYellow,()=>_lbc('$name tome $t')),
      const SizedBox(width:6),
      _mktChip('Vinted',const Color(0xFF00A86B),()=>_vtd('$name tome $t')),
    ]),
  ]));

Widget _mktChip(String label,Color color,VoidCallback onTap)=>InkWell(onTap:onTap,child:Container(
  padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),
  color:color,child:Text(label,style:tBebas(13,c:kInk))));

Widget _ownedSection(BuildContext c,List<Book> books)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  const Divider(color:kBorder,height:1),
  Padding(padding:const EdgeInsets.fromLTRB(16,10,16,6),child:Text('TOMES POSSÉDÉS',style:tMono(9,c:kMuted,ls:3))),
  ...books.map((b)=>ListTile(
    dense:true,contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:0),
    leading:Container(width:32,height:32,color:kPanelBg,alignment:Alignment.center,child:b.volumeNumber!=null?Text('${b.volumeNumber}',style:tBebas(16,c:kYellow)):const Icon(Icons.menu_book,color:kMuted,size:16)),
    title:Text(b.title.isEmpty?'Sans titre':b.title,style:tBebas(16),maxLines:1,overflow:TextOverflow.ellipsis),
    subtitle:b.authors.isNotEmpty?Text(b.authors,style:tMono(10,c:kMuted),maxLines:1,overflow:TextOverflow.ellipsis):null,
    trailing:const Icon(Icons.chevron_right,color:kMuted,size:18),
    onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>BookDetailPage(bookId:b.id))),
  )),
  const SizedBox(height:6),
]);

Widget _mktRow(String name)=>Padding(
  padding:const EdgeInsets.fromLTRB(16,10,16,14),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('CHERCHER LA SÉRIE SUR',style:tMono(9,c:kMuted,ls:3)),
    const SizedBox(height:8),
    Row(children:[
      Expanded(child:_bigBtn('Leboncoin',kYellow,()=>_lbc(name))),
      const SizedBox(width:10),
      Expanded(child:_bigBtn('Vinted',const Color(0xFF00A86B),()=>_vtd(name))),
    ]),
  ]));

Widget _bigBtn(String label,Color color,VoidCallback onTap)=>InkWell(onTap:onTap,child:Container(
  padding:const EdgeInsets.symmetric(vertical:10),
  decoration:BoxDecoration(color:color,border:Border.all(color:kBorder,width:2)),
  alignment:Alignment.center,
  child:Text(label,style:tBebas(16,c:kInk))));

void _lbc(String q)async{await launchUrl(Uri.parse('https://www.leboncoin.fr/recherche?text=${Uri.encodeComponent(q)}&category=27'),mode:LaunchMode.externalApplication);}
void _vtd(String q)async{await launchUrl(Uri.parse('https://www.vinted.fr/catalog?search_text=${Uri.encodeComponent(q)}'),mode:LaunchMode.externalApplication);}
}
