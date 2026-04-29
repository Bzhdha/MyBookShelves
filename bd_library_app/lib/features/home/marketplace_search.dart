import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../db/app_db.dart';

class MarketplaceSearch extends StatefulWidget{
final List<Book> books;
const MarketplaceSearch({super.key,required this.books});
@override State<MarketplaceSearch> createState()=>_MSState();
}
class _MSState extends State<MarketplaceSearch>{
final _c=TextEditingController();
@override void dispose(){_c.dispose();super.dispose();}
@override Widget build(BuildContext c){
return Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
const Text('Recherche Leboncoin',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
const SizedBox(height:8),
Row(children:[Expanded(child:TextField(controller:_c,decoration:InputDecoration(hintText:'Titre ou auteur...',border:OutlineInputBorder(borderRadius:BorderRadius.circular(8)),isDense:true,contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:10)))),
const SizedBox(width:8),ElevatedButton(onPressed:_go,child:const Text('Chercher'))])
]));
}
void _go()async{final q=_c.text.trim();if(q.isEmpty)return;final u=Uri.parse('https://www.leboncoin.fr/recherche?text=${Uri.encodeComponent(q)}&category=27');await launchUrl(u,mode:LaunchMode.externalApplication);}
}

Future<void> searchBookOnLeboncoin(Book b)async{
final q='${b.title} ${b.authors}'.trim();final u=Uri.parse('https://www.leboncoin.fr/recherche?text=${Uri.encodeComponent(q)}&category=27');
await launchUrl(u,mode:LaunchMode.externalApplication);
}
