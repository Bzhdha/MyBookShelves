import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../db/app_db.dart';

class SeriesAlertsSection extends StatelessWidget{
final List<(SeriesData,List<int>)> data;
const SeriesAlertsSection({super.key,required this.data});
@override Widget build(BuildContext c){
if(data.isEmpty)return const SizedBox.shrink();
return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
const Padding(padding:EdgeInsets.fromLTRB(16,16,16,8),child:Row(children:[Icon(Icons.notification_important,color:Colors.orange),SizedBox(width:8),Text('Tomes manquants',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))])),
...data.map((e){final s=e.$1;final m=e.$2;
return ListTile(leading:const Icon(Icons.library_books),title:Text(s.name),subtitle:Text('Manquants: ${m.join(", ")}'),trailing:IconButton(icon:const Icon(Icons.search),onPressed:()=>_search(s.name,m.first)));})
]);
}
void _search(String n,int t)async{final q=Uri.encodeComponent('$n tome $t');final u=Uri.parse('https://www.leboncoin.fr/recherche?text=$q&category=27');await launchUrl(u,mode:LaunchMode.externalApplication);}
}
