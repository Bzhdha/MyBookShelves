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

class _StatusList extends StatelessWidget{
const _StatusList({required this.status});
final int status;

@override Widget build(BuildContext c){
final repo=c.read<ReadingRepository>();
return FutureBuilder<List<(Book,ReadingProgressRow)>>(
future:repo.booksWithProgressForStatus(status),
builder:(c,s){
if(!s.hasData)return const Center(child:CircularProgressIndicator(color:kYellow));
final items=s.data!;
if(items.isEmpty)return Center(child:Text('Aucun livre (${readingStatusLabel(status)})',style:tBebas(16,c:kMuted),textAlign:TextAlign.center));
return ListView.builder(
itemCount:items.length,
itemBuilder:(c,i){
final b=items[i].$1;
return InkWell(
onTap:()=>Navigator.push<void>(c,MaterialPageRoute(builder:(_)=>BookDetailPage(bookId:b.id))),
child:Container(
padding:const EdgeInsets.symmetric(horizontal:16,vertical:14),
decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:kBorder))),
child:Row(children:[
Container(
width:30,height:30,
alignment:Alignment.center,
child:Text('${i+1}'.padLeft(2,'0'),style:tBebas(20,c:kBorder,ls:0)),
),
const SizedBox(width:14),
Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Text(b.title.isEmpty?'Sans titre':b.title,style:tBebas(20),maxLines:2,overflow:TextOverflow.ellipsis),
if(b.authors.trim().isNotEmpty)Text(b.authors,style:tSerif(13,c:kMuted,italic:true)),
])),
const Icon(Icons.chevron_right,color:kMuted,size:18),
])));});});}}
