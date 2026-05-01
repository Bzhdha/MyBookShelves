import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../db/app_db.dart';
import '../books/domain/book_service.dart';
import '../books/ui/book_detail_page.dart';
import '../books/ui/isbn_scanner_page.dart';
import '../reading/data/reading_repository.dart';
import '../reading/domain/reading_session_store.dart';
import '../reading/ui/reading_active_banner.dart';
import '../reading/ui/start_reading_session_page.dart';
import 'book_carousel.dart';
import 'series_alerts_section.dart';
import 'marketplace_search.dart';
import '../../core/speech_dictation.dart';
import '../import_export/data/library_transfer_service.dart';
import '../import_export/ui/import_review_page.dart';
import '../import_export/ui/imported_libraries_list_page.dart';
import '../users/ui/users_page.dart';
import '../books/ui/add_book_page.dart';
import '../shelves/ui/shelves_page.dart';
import '../reading/ui/reading_status_page.dart';
import '../reading/ui/reading_progress_page.dart';
import '../reading/ui/reading_goals_page.dart';
import '../reading/ui/reading_history_page.dart';
import '../reading/ui/reading_stats_page.dart';
import '../settings/data/app_lock_store.dart';
import '../settings/ui/api_key_page.dart';
import '../settings/ui/scan_settings_page.dart';
import '../logs/ui/logs_page.dart';

class NewHomePage extends StatefulWidget{
const NewHomePage({super.key});
@override State<NewHomePage> createState()=>_NHPState();
}
class _NHPState extends State<NewHomePage> with WidgetsBindingObserver{
final _sc=TextEditingController();String _sq='';final _sp=SpeechDictation();bool _sl=false;
Book? _lastRead;List<(Book,ReadingProgressRow)> _inProg=[];List<(SeriesData,List<int>)> _missing=[];
Map<Shelf,List<Book>> _shelves={};List<Book> _allBooks=[];List<Book> _unclassified=[];
Timer? _debounce;

@override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);
_sc.addListener(_onSearchChanged);_sp.initialize();
WidgetsBinding.instance.addPostFrameCallback((_){if(mounted){context.read<ReadingSessionStore>().load();_load();}});}
void _onSearchChanged(){_debounce?.cancel();_debounce=Timer(const Duration(milliseconds:400),(){if(mounted)setState((){_sq=_sc.text.trim();});});}
@override void dispose(){_debounce?.cancel();WidgetsBinding.instance.removeObserver(this);_sc.dispose();super.dispose();}
@override void didChangeAppLifecycleState(AppLifecycleState s){if(s==AppLifecycleState.resumed&&mounted){context.read<ReadingSessionStore>().load();_load();}}

Future<void> _load()async{
final rr=context.read<ReadingRepository>();final db=context.read<AppDb>();
final lr=await rr.lastFinishedBook();final ip=await rr.booksInProgress();final ms=await rr.seriesWithMissingVolumes();
final shelves=await db.getAllShelves();final sm=<Shelf,List<Book>>{};for(final s in shelves){sm[s]=await db.getBooksByShelf(s.id);}
final ab=await db.getAllBooks();final uc=await db.getUnclassifiedBooks();
if(mounted)setState((){_lastRead=lr;_inProg=ip;_missing=ms;_shelves=sm;_allBooks=ab;_unclassified=uc;});
}

Future<void> _voice()async{
if(_sl){await _sp.stop();if(mounted)setState((){_sl=false;});return;}
final ok=await _sp.initialize();if(!ok){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Micro indisponible')));return;}
if(mounted)setState((){_sl=true;});
await _sp.startListening(baseText:'',onText:(t){_sc.text=t;_sc.selection=TextSelection.collapsed(offset:_sc.text.length);});
if(mounted)setState((){_sl=false;});
}

@override Widget build(BuildContext c){
final bs=context.read<BookService>();
return Scaffold(appBar:AppBar(title:const Text('Bibliothèque BD')),drawer:_drawer(c),
body:_sq.isEmpty?_home(c):_search(c,bs),
floatingActionButton:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.end,children:[
FloatingActionButton.small(heroTag:'fab_read',tooltip:'Séance lecture',onPressed:(){Navigator.push(c,MaterialPageRoute(builder:(_)=>const StartReadingSessionPage()));},child:const Icon(Icons.auto_stories)),
const SizedBox(height:12),FloatingActionButton(heroTag:'fab_scan',onPressed:(){Navigator.push(c,MaterialPageRoute(builder:(_)=>const IsbnScannerPage()));},child:const Icon(Icons.qr_code_scanner))]));
}

Widget _home(BuildContext c){
return RefreshIndicator(onRefresh:_load,child:SingleChildScrollView(physics:const AlwaysScrollableScrollPhysics(),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
const ReadingActiveBanner(),_searchBar(),
if(_inProg.isNotEmpty)BookCarousel(title:'Reprendre la lecture',books:_inProg.map((e)=>e.$1).toList(),onTap:(b)=>_goBook(c,b)),
if(_lastRead!=null)Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Dernier livre lu',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),BookCard(book:_lastRead!,subtitle:'Terminé récemment',onTap:()=>_goBook(c,_lastRead!))])),
if(_unclassified.isNotEmpty)BookCarousel(title:'À classer',books:_unclassified,onTap:(b)=>_goBook(c,b),trailing:const Icon(Icons.inbox,size:16,color:Colors.orange)),
..._shelves.entries.where((e)=>e.value.isNotEmpty).map((e)=>BookCarousel(title:e.key.name,books:e.value,onTap:(b)=>_goBook(c,b),trailing:Container(width:12,height:12,decoration:BoxDecoration(color:_col(e.key.color),shape:BoxShape.circle)))),
SeriesAlertsSection(data:_missing),
MarketplaceSearch(books:_allBooks),
const SizedBox(height:100)
])));
}

Widget _search(BuildContext c,BookService bs){
return FutureBuilder<List<(Book,String?)>>(future:bs.searchBooksWithSeriesNames(_sq),builder:(c,s){
if(!s.hasData)return const Center(child:CircularProgressIndicator());
final items=s.data!;if(items.isEmpty)return const Center(child:Text('Aucun résultat'));
return ListView(children:[_searchBar(),...items.map((e){final b=e.$1;final sn=e.$2;
return ListTile(leading:_cov(b),title:Text(b.title),subtitle:sn!=null?Text(sn):null,onTap:()=>_goBook(c,b),trailing:IconButton(icon:const Icon(Icons.shopping_cart),onPressed:()=>searchBookOnLeboncoin(b)));})]);});
}

Widget _searchBar()=>Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),child:TextField(controller:_sc,decoration:InputDecoration(hintText:'Rechercher...',prefixIcon:const Icon(Icons.search),suffixIcon:Row(mainAxisSize:MainAxisSize.min,children:[IconButton(icon:Icon(_sl?Icons.mic:Icons.mic_none,color:_sl?Theme.of(context).colorScheme.primary:null),onPressed:_voice),if(_sq.isNotEmpty)IconButton(icon:const Icon(Icons.clear),onPressed:()=>_sc.clear())]),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)),filled:true)));

Widget _cov(Book b){final p=b.coverLocalPath;final h=p!=null&&p.isNotEmpty;return SizedBox(width:40,height:56,child:ClipRRect(borderRadius:BorderRadius.circular(4),child:h?Image.file(File(p),fit:BoxFit.cover,errorBuilder:(_,__,___)=>_ph()):_ph()));}
static Widget _ph()=>Container(color:Colors.grey.shade300,child:const Icon(Icons.menu_book,size:28));
Color _col(String hex){try{return Color(int.parse(hex.replaceFirst('#','0xff')));}catch(_){return Colors.blue;}}
void _goBook(BuildContext c,Book b)=>Navigator.push(c,MaterialPageRoute(builder:(_)=>BookDetailPage(bookId:b.id)));

Widget _drawer(BuildContext c)=>Drawer(child:ListView(padding:EdgeInsets.zero,children:[
const DrawerHeader(decoration:BoxDecoration(color:Colors.blue),child:Text('Bibliothèque BD',style:TextStyle(color:Colors.white,fontSize:24))),
ListTile(leading:const Icon(Icons.upload),title:const Text('Importer JSON'),onTap:()async{Navigator.pop(c);final db=c.read<AppDb>();final t=LibraryTransferService(db);try{final f=await t.pickJsonFile();if(f==null||!c.mounted)return;final p=await t.buildImportPlanFromJson(f);if(!c.mounted)return;await Navigator.push<void>(c,MaterialPageRoute(builder:(_)=>ImportReviewPage(plan:p,onApply:(p)async{await t.applyImportPlanFromJson(p);})));_load();}catch(e){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('Erreur: $e')));}}),
ListTile(leading:const Icon(Icons.download),title:const Text('Exporter JSON'),onTap:()async{Navigator.pop(c);final db=c.read<AppDb>();final t=LibraryTransferService(db);try{await t.shareExportJson();}catch(e){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('Erreur: $e')));}}),
ListTile(leading:const Icon(Icons.people_outline),title:const Text('Bibliothèques importées'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ImportedLibrariesListPage()));}),
ListTile(leading:const Icon(Icons.group),title:const Text('Membres'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const UsersPage()));}),
ListTile(leading:const Icon(Icons.add),title:const Text('Ajouter livre'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const AddBookPage()));}),
ListTile(leading:const Icon(Icons.menu_book),title:const Text('Étagères'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ShelvesPage()));}),
ExpansionTile(leading:const Icon(Icons.auto_stories),title:const Text('Suivi lecture'),children:[
ListTile(leading:const Icon(Icons.play_circle_outline),title:const Text('Séance'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const StartReadingSessionPage()));}),
ListTile(leading:const Icon(Icons.label_outline),title:const Text('Statuts'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingStatusPage()));}),
ListTile(leading:const Icon(Icons.linear_scale),title:const Text('Progression'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingProgressPage()));}),
ListTile(leading:const Icon(Icons.flag_outlined),title:const Text('Objectifs'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingGoalsPage()));}),
ListTile(leading:const Icon(Icons.history),title:const Text('Historique'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingHistoryPage()));}),
ListTile(leading:const Icon(Icons.bar_chart_outlined),title:const Text('Stats'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingStatsPage()));})]),
ListTile(leading:const Icon(Icons.key),title:const Text('Clés API'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ApiKeyPage()));}),
ListTile(leading:const Icon(Icons.settings),title:const Text('Paramètres scan'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ScanSettingsPage()));}),
Consumer<AppLockStore>(builder:(_,st,__)=>SwitchListTile(secondary:const Icon(Icons.lock_outline),title:const Text('Verrou bio'),value:st.enabled,onChanged:(v)=>st.setEnabled(v))),
const Divider(),
ListTile(leading:const Icon(Icons.list_alt),title:const Text('Logs'),onTap:(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const LogsPage()));})
]));
}
