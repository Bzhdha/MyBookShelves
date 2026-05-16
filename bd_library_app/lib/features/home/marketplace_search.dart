import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../db/app_db.dart';

class MarketplaceSearch extends StatefulWidget{
final List<Book> books;
const MarketplaceSearch({super.key,required this.books});
@override State<MarketplaceSearch> createState()=>_MSState();
}
class _MSState extends State<MarketplaceSearch>{
final _c=TextEditingController();
@override void dispose(){_c.dispose();super.dispose();}
@override Widget build(BuildContext ctx)=>Padding(padding:const EdgeInsets.fromLTRB(16,16,16,0),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Text('CHERCHER EN OCCASION',style:tMono(9,c:kMuted,ls:3)),
  const SizedBox(height:10),
  TextField(controller:_c,style:tMono(13,c:kPaper,ls:0.5),
    decoration:InputDecoration(
      hintText:'Titre, série, auteur…',hintStyle:tMono(13,c:kMuted),
      prefixIcon:const Icon(Icons.search,color:kMuted,size:18),
      isDense:true,contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:10),
      enabledBorder:OutlineInputBorder(borderSide:const BorderSide(color:kBorder),borderRadius:BorderRadius.circular(4)),
      focusedBorder:OutlineInputBorder(borderSide:const BorderSide(color:kYellow),borderRadius:BorderRadius.circular(4)))),
  const SizedBox(height:10),
  Row(children:[
    Expanded(child:_btn('Leboncoin',kYellow,_goLbc)),
    const SizedBox(width:10),
    Expanded(child:_btn('Vinted',const Color(0xFF00A86B),_goVtd)),
  ]),
]));

Widget _btn(String label,Color color,VoidCallback onTap)=>InkWell(onTap:onTap,child:Container(
  padding:const EdgeInsets.symmetric(vertical:10),
  decoration:BoxDecoration(color:color,border:Border.all(color:kBorder,width:2),boxShadow:const [BoxShadow(color:Color(0x66000000),offset:Offset(3,3))]),
  alignment:Alignment.center,
  child:Text(label,style:tBebas(16,c:kInk))));

void _goLbc()async{final q=_c.text.trim();if(q.isEmpty)return;await launchUrl(Uri.parse('https://www.leboncoin.fr/recherche?text=${Uri.encodeComponent(q)}&category=27'),mode:LaunchMode.externalApplication);}
void _goVtd()async{final q=_c.text.trim();if(q.isEmpty)return;await launchUrl(Uri.parse('https://www.vinted.fr/catalog?search_text=${Uri.encodeComponent(q)}'),mode:LaunchMode.externalApplication);}
}

Future<void> searchBookOnLeboncoin(Book b)async{
  final q='${b.title} ${b.authors}'.trim();
  await launchUrl(Uri.parse('https://www.leboncoin.fr/recherche?text=${Uri.encodeComponent(q)}&category=27'),mode:LaunchMode.externalApplication);
}

Future<void> searchBookOnVinted(Book b)async{
  final q='${b.title} ${b.authors}'.trim();
  await launchUrl(Uri.parse('https://www.vinted.fr/catalog?search_text=${Uri.encodeComponent(q)}'),mode:LaunchMode.externalApplication);
}
