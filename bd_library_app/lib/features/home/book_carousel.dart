import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../db/app_db.dart';

class _SnappyPageScrollPhysics extends PageScrollPhysics{
const _SnappyPageScrollPhysics({super.parent});
@override _SnappyPageScrollPhysics applyTo(ScrollPhysics? a)=>_SnappyPageScrollPhysics(parent:buildParent(a));
@override SpringDescription get spring=>const SpringDescription(mass:0.26,stiffness:380,damping:26);}

class BookCarousel extends StatefulWidget{
final String title;final List<Book> books;final void Function(Book) onTap;final Widget? trailing;
const BookCarousel({super.key,required this.title,required this.books,required this.onTap,this.trailing});
static Widget _ph()=>Container(color:kPanelBg,child:const Center(child:Icon(Icons.menu_book,size:32,color:kMuted)));
@override State<BookCarousel> createState()=>_BookCarouselState();}

class _BookCarouselState extends State<BookCarousel>{
static const int _inf=10000;
late final PageController _pc;
int get _n=>widget.books.length;
int get _vc=>_n<=1?_n:_n*_inf;
int get _iv=>_n<=1?0:_n*(_inf~/2);

@override void initState(){super.initState();_pc=PageController(viewportFraction:0.34,initialPage:_iv);}
@override void didUpdateWidget(BookCarousel o){super.didUpdateWidget(o);if(o.books.length!=widget.books.length&&_pc.hasClients){WidgetsBinding.instance.addPostFrameCallback((_){if(mounted&&_pc.hasClients)_pc.jumpToPage(_iv);});}}
@override void dispose(){_pc.dispose();super.dispose();}
int _idx(int page)=>_n==0?0:_n==1?0:((page%_n)+_n)%_n;
int _cur(double page)=>_idx(page.round())+1;

@override Widget build(BuildContext c){
if(widget.books.isEmpty)return const SizedBox.shrink();
return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),child:Row(children:[
Expanded(child:Text(widget.title.toUpperCase(),style:tBebas(18))),
if(widget.trailing!=null)widget.trailing!,
])),
SizedBox(height:200,child:Stack(alignment:Alignment.center,children:[
PageView.builder(
controller:_pc,physics:const _SnappyPageScrollPhysics(),padEnds:false,itemCount:_vc,
itemBuilder:(c,i){
final b=widget.books[_idx(i)];
return AnimatedBuilder(animation:_pc,builder:(c,child){
final pos=_pc.position;
final double page=!pos.hasContentDimensions?_pc.initialPage.toDouble():(_pc.page??_pc.initialPage.toDouble());
final delta=i-page;final rot=-delta*0.55;final scale=math.max(0.72,1-delta.abs()*0.18);
final opacity=0.38+(1-delta.abs().clamp(0.0,1.0))*0.62;
final m=Matrix4.identity()..setEntry(3,2,0.0022)..rotateY(rot);
return Transform(alignment:Alignment.center,transform:m,child:Transform.scale(scale:scale,child:Opacity(opacity:opacity.clamp(0.0,1.0),child:child)));
},child:GestureDetector(onTap:()=>widget.onTap(b),child:_tile(b)));
}),
IgnorePointer(child:AnimatedBuilder(animation:_pc,builder:(c,_){
final pos=_pc.position;
final double page=!pos.hasContentDimensions?_pc.initialPage.toDouble():(_pc.page??_pc.initialPage.toDouble());
return Container(
padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
decoration:BoxDecoration(color:kYellow,border:Border.all(color:kInk,width:2)),
child:Text('${_cur(page)} / $_n',style:tBebas(14,c:kInk,ls:1)));
})),
]))]);
}

Widget _tile(Book b){
final cp=b.coverLocalPath;final h=cp!=null&&cp.isNotEmpty;
return Padding(padding:const EdgeInsets.symmetric(horizontal:2),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
Container(width:100,height:140,decoration:const BoxDecoration(border:Border.fromBorderSide(BorderSide(color:kBorder,width:2))),
child:h?Image.file(File(cp),fit:BoxFit.cover,errorBuilder:(_,_,_)=>BookCarousel._ph()):BookCarousel._ph()),
const SizedBox(height:6),
Text(b.title,maxLines:2,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:tMono(10)),
]));}
}

class BookCard extends StatelessWidget{
final Book book;final String? subtitle;final void Function() onTap;
const BookCard({super.key,required this.book,this.subtitle,required this.onTap});

@override Widget build(BuildContext c){
final cp=book.coverLocalPath;final h=cp!=null&&cp.isNotEmpty;
return GestureDetector(onTap:onTap,child:Container(
margin:const EdgeInsets.symmetric(horizontal:16,vertical:8),
padding:const EdgeInsets.all(14),
decoration:const BoxDecoration(color:kPanelBg,border:Border.fromBorderSide(BorderSide(color:kBorder,width:3))),
child:Row(children:[
Container(width:70,height:100,decoration:const BoxDecoration(border:Border.fromBorderSide(BorderSide(color:kBorder,width:2))),
child:h?Image.file(File(cp),fit:BoxFit.cover,errorBuilder:(_,_,_)=>BookCarousel._ph()):BookCarousel._ph()),
const SizedBox(width:16),
Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Text(book.title,style:tBebas(20),maxLines:2,overflow:TextOverflow.ellipsis),
if(subtitle!=null)...[const SizedBox(height:6),Text(subtitle!,style:tSerif(13,c:kMuted,italic:true))],
])),
])));}
}
