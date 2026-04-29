import 'dart:io';
import 'package:flutter/material.dart';
import '../../db/app_db.dart';

class BookCarousel extends StatelessWidget{
final String title;final List<Book> books;final void Function(Book) onTap;final Widget? trailing;
const BookCarousel({super.key,required this.title,required this.books,required this.onTap,this.trailing});
@override Widget build(BuildContext c){
if(books.isEmpty)return const SizedBox.shrink();
return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),child:Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold))),if(trailing!=null)trailing!])),
SizedBox(height:180,child:ListView.builder(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),itemCount:books.length,itemBuilder:(c,i){
final b=books[i];final cp=b.coverLocalPath;final hasC=cp!=null&&cp.isNotEmpty;
return GestureDetector(onTap:()=>onTap(b),child:Container(width:120,margin:const EdgeInsets.symmetric(horizontal:4),child:Column(children:[
ClipRRect(borderRadius:BorderRadius.circular(8),child:SizedBox(height:140,width:100,child:hasC?Image.file(File(cp),fit:BoxFit.cover,errorBuilder:(_,__,___)=>_ph()):_ph())),
const SizedBox(height:4),Text(b.title,maxLines:2,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:const TextStyle(fontSize:12))
])));}))
]);
}
static Widget _ph()=>Container(color:Colors.grey.shade300,child:const Center(child:Icon(Icons.menu_book,size:32)));
}

class BookCard extends StatelessWidget{
final Book book;final String? subtitle;final void Function() onTap;
const BookCard({super.key,required this.book,this.subtitle,required this.onTap});
@override Widget build(BuildContext c){
final cp=book.coverLocalPath;final hasC=cp!=null&&cp.isNotEmpty;
return GestureDetector(onTap:onTap,child:Card(margin:const EdgeInsets.symmetric(horizontal:16,vertical:8),child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
ClipRRect(borderRadius:BorderRadius.circular(8),child:SizedBox(height:100,width:70,child:hasC?Image.file(File(cp),fit:BoxFit.cover,errorBuilder:(_,__,___)=>BookCarousel._ph()):BookCarousel._ph())),
const SizedBox(width:16),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Text(book.title,style:const TextStyle(fontSize:16,fontWeight:FontWeight.bold),maxLines:2,overflow:TextOverflow.ellipsis),
if(subtitle!=null)...[const SizedBox(height:4),Text(subtitle!,style:TextStyle(fontSize:13,color:Colors.grey.shade600))]
]))]))));
}
}
