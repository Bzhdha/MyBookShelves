import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../db/app_db.dart';
import '../data/reading_repository.dart';
import '../../books/ui/book_detail_page.dart';
import 'reading_formatters.dart';

class ReadingStatusPage extends StatefulWidget{
const ReadingStatusPage({super.key});
@override State<ReadingStatusPage> createState()=>_ReadingStatusPageState();}

class _ReadingStatusPageState extends State<ReadingStatusPage> with SingleTickerProviderStateMixin{
late TabController _tab;
@override void initState(){super.initState();_tab=TabController(length:3,vsync:this);}
@override void dispose(){_tab.dispose();super.dispose();}

@override Widget build(BuildContext c){
return Scaffold(
backgroundColor:kInk,
appBar:AppBar(
leading:IconButton(icon:const Icon(Icons.arrow_back),color:kInk,onPressed:()=>Navigator.pop(c)),
title:Text('Statuts de lecture',style:tBebas(24,c:kInk)),
backgroundColor:kYellow,elevation:0,
bottom:TabBar(
controller:_tab,
indicatorColor:kInk,indicatorWeight:3,
labelStyle:tBebas(14,c:kInk,ls:2),
unselectedLabelStyle:tBebas(14,c:kInk.withValues(alpha:0.4),ls:2),
labelColor:kInk,unselectedLabelColor:kInk.withValues(alpha:0.4),
tabs:const[Tab(text:'À lire'),Tab(text:'En cours'),Tab(text:'Terminé')],
)),
body:TabBarView(controller:_tab,children:const[
_StatusList(status:ReadingStatusValues.toRead),
_StatusList(status:ReadingStatusValues.inProgress),
_StatusList(status:ReadingStatusValues.finished),
]));
}}

Color _shelfCol(String hex){try{return Color(int.parse(hex.replaceFirst('#','0xFF')));}catch(_){return kYellow;}}

abstract class _VItem{Widget build(BuildContext c);}

class _RootHdr extends _VItem{
_RootHdr(this.s);final Shelf s;
@override Widget build(BuildContext c){
  final col=_shelfCol(s.color);
  return Container(
    color:col.withValues(alpha:0.12),
    padding:const EdgeInsets.fromLTRB(16,10,16,8),
    child:Row(children:[
      Container(width:3,height:18,color:col),
      const SizedBox(width:10),
      Expanded(child:Text(s.name.toUpperCase(),style:tBebas(17,c:kPaper,ls:3))),
    ]));
}}

class _SubHdr extends _VItem{
_SubHdr(this.s);final Shelf s;
@override Widget build(BuildContext c){
  final col=_shelfCol(s.color);
  return Container(
    color:kPanelBg,
    padding:const EdgeInsets.fromLTRB(28,7,16,5),
    child:Row(children:[
      Container(width:2,height:12,color:col.withValues(alpha:0.7)),
      const SizedBox(width:8),
      Text(s.name,style:tMono(10,c:col,ls:1)),
    ]));
}}

class _BookRow extends _VItem{
_BookRow(this.b,this.n);final Book b;final int n;
@override Widget build(BuildContext c){
  return InkWell(
    onTap:()=>Navigator.push<void>(c,MaterialPageRoute(builder:(_)=>BookDetailPage(bookId:b.id))),
    child:Container(
      padding:const EdgeInsets.symmetric(horizontal:16,vertical:14),
      decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:kBorder))),
      child:Row(children:[
        Container(width:30,height:30,alignment:Alignment.center,
          child:Text('$n'.padLeft(2,'0'),style:tBebas(20,c:kBorder,ls:0))),
        const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(b.title.isEmpty?'Sans titre':b.title,style:tBebas(20),maxLines:2,overflow:TextOverflow.ellipsis),
          if(b.authors.trim().isNotEmpty)Text(b.authors,style:tSerif(13,c:kMuted,italic:true)),
        ])),
        const Icon(Icons.chevron_right,color:kMuted,size:18),
      ])));
}}

class _StatusList extends StatelessWidget{
const _StatusList({required this.status});
final int status;

@override Widget build(BuildContext c){
  final repo=c.read<ReadingRepository>();
  return FutureBuilder<List<({Shelf? parent,Shelf shelf,List<(Book,ReadingProgressRow)>books})>>(
    future:repo.booksWithProgressForStatusByShelf(status),
    builder:(c,s){
      if(!s.hasData)return const Center(child:CircularProgressIndicator(color:kYellow));
      final secs=s.data!;
      if(secs.isEmpty)return Center(child:Text('Aucun livre (${readingStatusLabel(status)})',style:tBebas(16,c:kMuted),textAlign:TextAlign.center));
      final items=<_VItem>[];
      String? lastRootId;
      for(final sec in secs){
        if(sec.parent!=null){
          if(lastRootId!=sec.parent!.id){items.add(_RootHdr(sec.parent!));lastRootId=sec.parent!.id;}
          items.add(_SubHdr(sec.shelf));
        }else{
          items.add(_RootHdr(sec.shelf));
          lastRootId=sec.shelf.id;
        }
        for(int j=0;j<sec.books.length;j++)items.add(_BookRow(sec.books[j].$1,j+1));
      }
      return ListView.builder(
        itemCount:items.length,
        itemBuilder:(c,i)=>items[i].build(c));
    });
}}
