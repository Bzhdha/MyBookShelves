import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../db/app_db.dart';
import '../books/domain/book_service.dart';
import '../books/ui/book_detail_page.dart';
import '../books/ui/isbn_scanner_page.dart';
import '../reading/data/reading_repository.dart';
import '../reading/domain/reading_session_store.dart';
import '../reading/ui/reading_active_banner.dart';
import '../reading/ui/start_reading_session_page.dart';
import '../reading/ui/resume_reading_session_page.dart';
import '../reading/ui/reading_status_page.dart';
import '../reading/ui/reading_stats_page.dart';
import '../reading/ui/reading_badges_page.dart';
import 'book_carousel.dart';
import 'series_alerts_section.dart';
import 'series_completion_suggestions.dart';
import 'series_page.dart';
import 'marketplace_search.dart';
import '../../core/speech_dictation.dart';
import '../import_export/data/library_transfer_service.dart';
import '../import_export/ui/import_review_page.dart';
import '../import_export/ui/imported_libraries_list_page.dart';
import '../users/ui/users_page.dart';
import '../books/ui/add_book_page.dart';
import '../shelves/domain/shelf_service.dart';
import '../shelves/ui/shelves_page.dart';
import '../reading/ui/reading_progress_page.dart';
import '../reading/ui/reading_goals_page.dart';
import '../reading/ui/reading_history_page.dart';
import '../reading/domain/reading_badge_evaluator.dart';
import '../settings/data/app_lock_store.dart';
import '../settings/ui/api_key_page.dart';
import '../settings/ui/scan_settings_page.dart';
import '../logs/ui/logs_page.dart';

class _ShelfGroup{final Shelf parent;final List<Book> directBooks;final List<(Shelf,List<Book>)> children;_ShelfGroup({required this.parent,required this.directBooks,required this.children});}

class NewHomePage extends StatefulWidget{const NewHomePage({super.key});@override State<NewHomePage> createState()=>_NHPState();}
class _NHPState extends State<NewHomePage> with WidgetsBindingObserver{
final _sc=TextEditingController();String _sq='';final _sp=SpeechDictation();bool _sl=false;
Book? _lastRead;List<(Book,ReadingProgressRow)> _inProg=[];List<(SeriesData,List<int>)> _missing=[];List<({SeriesData series,int owned,List<int> missing})> _suggestions=[];
List<_ShelfGroup> _shelfGroups=[];List<Book> _allBooks=[];List<Book> _unclassified=[];
Timer? _debounce;

@override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);
_sc.addListener(_onSearch);_sp.initialize();
WidgetsBinding.instance.addPostFrameCallback((_){if(mounted){context.read<ReadingSessionStore>().load();_load();}});}
void _onSearch(){_debounce?.cancel();_debounce=Timer(const Duration(milliseconds:400),(){if(mounted)setState((){_sq=_sc.text.trim();});});}
@override void dispose(){_debounce?.cancel();WidgetsBinding.instance.removeObserver(this);_sc.dispose();super.dispose();}
@override void didChangeAppLifecycleState(AppLifecycleState s){if(s==AppLifecycleState.resumed&&mounted){context.read<ReadingSessionStore>().load();_load();}}

Future<void> _load()async{
if(!mounted)return;
final rr=context.read<ReadingRepository>();final db=context.read<AppDb>();
await ReadingBadgeEvaluator(db).syncMilestoneBadgesFromProgress();
if(!mounted)return;
final ss=context.read<ShelfService>();
final lr=await rr.lastFinishedBook();final ip=await rr.booksInProgress();final ms=await rr.seriesWithMissingVolumes();final sg=await rr.seriesCompletionSuggestions();
final roots=await ss.getRootShelves();
final groups=<_ShelfGroup>[];
for(final root in roots){
final direct=await ss.getBooksByShelf(root.id);final children=await ss.getChildShelves(root.id);
final childData=<(Shelf,List<Book>)>[];
for(final child in children){childData.add((child,await ss.getBooksByShelf(child.id)));}
groups.add(_ShelfGroup(parent:root,directBooks:direct,children:childData));}
final ab=await db.getAllBooks();final uc=await db.getUnclassifiedBooks();
if(mounted)setState((){_lastRead=lr;_inProg=ip;_missing=ms;_suggestions=sg;_shelfGroups=groups;_allBooks=ab;_unclassified=uc;});}

Future<void> _voice()async{
if(_sl){await _sp.stop();if(mounted)setState((){_sl=false;});return;}
final ok=await _sp.initialize();if(!ok){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Micro indisponible')));return;}
if(mounted)setState((){_sl=true;});
await _sp.startListening(baseText:'',onText:(t){_sc.text=t;_sc.selection=TextSelection.collapsed(offset:_sc.text.length);});
if(mounted)setState((){_sl=false;});}

@override Widget build(BuildContext c){
return Scaffold(
backgroundColor:kInk,
drawer:_buildDrawer(c),
body:Column(children:[
SafeArea(bottom:false,child:_buildHeader(c)),
const ReadingActiveBanner(),
Expanded(child:_sq.isEmpty?_buildHome(c):_buildSearch(c)),
]),
bottomNavigationBar:_buildBottomNav(c),
floatingActionButton:_buildFab(c),
);}

// ── HEADER ────────────────────────────────────────────────────────────────────
Widget _buildHeader(BuildContext c){
return Container(
color:kYellow,
padding:const EdgeInsets.fromLTRB(20,16,20,16),
child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Row(children:[
Builder(builder:(ctx)=>GestureDetector(behavior:HitTestBehavior.opaque,onTap:()=>Scaffold.of(ctx).openDrawer(),child:Padding(padding:const EdgeInsets.fromLTRB(0,8,12,8),child:Column(mainAxisSize:MainAxisSize.min,children:[_ln(),const SizedBox(height:5),_ln(),const SizedBox(height:5),_ln()])))),
const SizedBox(width:12),
Text('Bibliothèque BD',style:tBebas(32,c:kInk)),
]),
const SizedBox(height:12),
Container(
padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),
decoration:const BoxDecoration(color:kInk,boxShadow:[BoxShadow(color:Color(0x4D000000),offset:Offset(4,4))]),
child:Row(children:[
const Icon(Icons.search,color:kYellow,size:18),
const SizedBox(width:10),
Expanded(child:TextField(
controller:_sc,
style:tMono(13,c:kPaper,ls:0.5),
decoration:InputDecoration(
hintText:'Titre, auteur, ISBN…',
hintStyle:tMono(13,c:const Color(0xFF666666)),
isDense:true,contentPadding:EdgeInsets.zero,
suffixIcon:Row(mainAxisSize:MainAxisSize.min,children:[
IconButton(icon:Icon(_sl?Icons.mic:Icons.mic_none,color:_sl?kYellow:const Color(0xFF888888),size:18),onPressed:_voice,padding:EdgeInsets.zero,constraints:const BoxConstraints(minWidth:30,minHeight:30)),
if(_sq.isNotEmpty)IconButton(icon:const Icon(Icons.clear,color:Color(0xFF888888),size:16),onPressed:()=>_sc.clear(),padding:EdgeInsets.zero,constraints:const BoxConstraints(minWidth:30,minHeight:30)),
])))),
]),
),
]),
);}
Widget _ln()=>Container(width:28,height:3,color:kInk);

// ── HOME CONTENT ──────────────────────────────────────────────────────────────
Widget _buildHome(BuildContext c){
return RefreshIndicator(color:kYellow,backgroundColor:kInk,onRefresh:_load,
child:SingleChildScrollView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.only(bottom:20),
child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
if(_inProg.isNotEmpty)...[
_secLabel('Reprendre la lecture'),
Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:_ContinuePanel(books:_inProg.map((e)=>e.$1).toList(),onTap:(b)=>Navigator.push(c,MaterialPageRoute(builder:(_)=>ResumeReadingSessionPage(bookId:b.id))))),
],
if(_lastRead!=null)...[
_secLabel('Dernier livre lu'),
Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:_LastReadCard(book:_lastRead!,onTap:()=>_goBook(c,_lastRead!))),
],
if(_unclassified.isNotEmpty)...[
Padding(padding:const EdgeInsets.fromLTRB(16,24,16,12),child:Row(children:[
Text('Livres à classer'.toUpperCase(),style:tBebas(11,c:kMuted,ls:4)),
const Spacer(),
Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:2),color:kRed,
child:Text('${_unclassified.length} ●',style:tBebas(12,c:kPaper,ls:1))),
])),
Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:_ClassifyGrid(books:_unclassified,onTap:(b)=>_goBook(c,b))),
],
..._shelfGroups.expand((g)=>_shelfWidgets(c,g)),
SeriesCompletionSuggestions(data:_suggestions),
SeriesAlertsSection(data:_missing),
MarketplaceSearch(books:_allBooks),
const SizedBox(height:20),
])));}

List<Widget> _shelfWidgets(BuildContext c,_ShelfGroup g){
if(g.children.isEmpty){
if(g.directBooks.isEmpty)return[];
return[BookCarousel(title:g.parent.name,books:g.directBooks,onTap:(b)=>_goBook(c,b),trailing:_dot(g.parent.color))];}
final ws=<Widget>[];
ws.add(Padding(padding:const EdgeInsets.fromLTRB(16,16,16,0),child:Row(children:[
_dot(g.parent.color),const SizedBox(width:8),
Text(g.parent.name.toUpperCase(),style:tBebas(18))])));
if(g.directBooks.isNotEmpty)ws.add(BookCarousel(title:'Divers',books:g.directBooks,onTap:(b)=>_goBook(c,b),trailing:_dot(g.parent.color,small:true)));
for(final(child,books) in g.children){if(books.isEmpty)continue;ws.add(BookCarousel(title:child.name,books:books,onTap:(b)=>_goBook(c,b),trailing:_dot(child.color,small:true)));}
return ws;}

// ── SEARCH ────────────────────────────────────────────────────────────────────
Widget _buildSearch(BuildContext c){
final bs=context.read<BookService>();
return FutureBuilder<List<(Book,String?)>>(
future:bs.searchBooksWithSeriesNames(_sq),
builder:(c,s){
if(!s.hasData)return const Center(child:CircularProgressIndicator(color:kYellow));
final items=s.data!;
if(items.isEmpty)return Center(child:Text('Aucun résultat',style:tBebas(18,c:kMuted)));
return ListView(children:items.map((e)=>_searchTile(e.$1,e.$2,c)).toList());});}

Widget _searchTile(Book b,String? sub,BuildContext c){
return InkWell(onTap:()=>_goBook(c,b),child:Container(
padding:const EdgeInsets.symmetric(horizontal:16,vertical:12),
decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:kBorder))),
child:Row(children:[
_cov(b),const SizedBox(width:14),
Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Text(b.title.isEmpty?'Sans titre':b.title,style:tBebas(18),maxLines:2,overflow:TextOverflow.ellipsis),
if(sub!=null)Text(sub,style:tSerif(13,c:kMuted,italic:true)),
])),
const Icon(Icons.chevron_right,color:kMuted,size:20),
])));}

// ── BOTTOM NAV ────────────────────────────────────────────────────────────────
Widget _buildBottomNav(BuildContext c){
return Container(
decoration:const BoxDecoration(color:kPaper,border:Border(top:BorderSide(color:kInk,width:4))),
child:SafeArea(top:false,child:Row(children:[
_navItem(Icons.menu_book,'Biblio',true,(){}),
_navItem(Icons.collections_bookmark,'Séries',false,()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const SeriesPage()))),
_navItem(Icons.book,'Lecture',false,()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingStatusPage()))),
_navItem(Icons.bar_chart,'Stats',false,()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingStatsPage()))),
_navItem(Icons.emoji_events,'Badges',false,()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingBadgesPage()))),
])));}

Widget _navItem(IconData icon,String label,bool active,VoidCallback onTap){
return Expanded(child:InkWell(onTap:onTap,child:Container(
padding:const EdgeInsets.symmetric(vertical:12),
decoration:BoxDecoration(color:active?kInk:kPaper,border:const Border(right:BorderSide(color:Color(0xFFE0D8C8),width:2))),
child:Column(mainAxisSize:MainAxisSize.min,children:[
Icon(icon,size:20,color:active?kYellow:kInk),
const SizedBox(height:4),
Text(label.toUpperCase(),style:tBebas(9,c:active?kYellow:kInk,ls:2)),
]))));}

// ── FAB ───────────────────────────────────────────────────────────────────────
Widget _buildFab(BuildContext c){
return Container(
width:52,height:52,
decoration:const BoxDecoration(color:kBlue,border:Border.fromBorderSide(BorderSide(color:kPaper,width:3)),boxShadow:[BoxShadow(color:kInk,offset:Offset(4,4))]),
child:Material(color:Colors.transparent,child:InkWell(
onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const IsbnScannerPage())),
child:const Icon(Icons.qr_code_scanner,color:kPaper,size:22))));}

// ── HELPERS ───────────────────────────────────────────────────────────────────
Widget _secLabel(String label){
return Padding(padding:const EdgeInsets.fromLTRB(16,24,16,12),child:Row(children:[
Text(label.toUpperCase(),style:tBebas(11,c:kMuted,ls:4)),
const SizedBox(width:10),
Expanded(child:Container(height:1,color:kBorder)),
]));}
Widget _dot(String hex,{bool small=false}){final s=small?10.0:12.0;return Container(width:s,height:s,decoration:BoxDecoration(color:_col(hex),shape:BoxShape.circle));}
Widget _cov(Book b){final p=b.coverLocalPath;final h=p!=null&&p.isNotEmpty;return Container(width:40,height:56,decoration:const BoxDecoration(border:Border.fromBorderSide(BorderSide(color:kBorder,width:2))),child:h?Image.file(File(p),fit:BoxFit.cover,errorBuilder:(_,__,___)=>_ph()):_ph());}
static Widget _ph()=>Container(color:kPanelBg,child:const Icon(Icons.menu_book,size:20,color:kMuted));
Color _col(String hex){try{return Color(int.parse(hex.replaceFirst('#','0xff')));}catch(_){return kBlue;}}
Future<void> _goBook(BuildContext c,Book b)async{await Navigator.push<void>(c,MaterialPageRoute(builder:(_)=>BookDetailPage(bookId:b.id)));if(mounted)await _load();}

// ── DRAWER ────────────────────────────────────────────────────────────────────
Widget _buildDrawer(BuildContext c)=>Drawer(backgroundColor:kPaper,child:ListView(padding:EdgeInsets.zero,children:[
DrawerHeader(decoration:const BoxDecoration(color:kBlue),child:Text('Bibliothèque BD',style:tBebas(32,c:kPaper,ls:3))),
_dSec('Bibliothèque'),
_dExp(Icons.upload,'Importer',[
_dSub(Icons.archive,'ZIP complet',()async{Navigator.pop(c);final db=c.read<AppDb>();final t=LibraryTransferService(db);try{final f=await t.pickZipFile();if(f==null||!c.mounted)return;final p=await t.buildImportPlanFromZip(f);if(!c.mounted)return;await Navigator.push<void>(c,MaterialPageRoute(builder:(_)=>ImportReviewPage(plan:p,onApply:(p)async{await t.applyImportPlanFromZip(zipFile:f,plan:p);})));_load();}catch(e){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('Erreur: $e')));}}),
_dSub(Icons.description,'JSON',()async{Navigator.pop(c);final db=c.read<AppDb>();final t=LibraryTransferService(db);try{final f=await t.pickJsonFile();if(f==null||!c.mounted)return;final p=await t.buildImportPlanFromJson(f);if(!c.mounted)return;await Navigator.push<void>(c,MaterialPageRoute(builder:(_)=>ImportReviewPage(plan:p,onApply:(p)async{await t.applyImportPlanFromJson(p);})));_load();}catch(e){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('Erreur: $e')));}})]),
_dExp(Icons.download,'Exporter',[
_dSub(Icons.archive,'ZIP complet',()async{Navigator.pop(c);final db=c.read<AppDb>();final t=LibraryTransferService(db);try{await t.shareExportZip();}catch(e){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('Erreur: $e')));}}),
_dSub(Icons.description,'JSON',()async{Navigator.pop(c);final db=c.read<AppDb>();final t=LibraryTransferService(db);try{await t.shareExportJson();}catch(e){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('Erreur: $e')));}})]),
_dItem(Icons.people_outline,'Bibliothèques importées',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ImportedLibrariesListPage()));}),
_dItem(Icons.collections_bookmark,'Séries',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const SeriesPage()));}),
_dItem(Icons.group,'Membres',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const UsersPage()));}),
_dItem(Icons.add,'Ajouter un livre',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const AddBookPage()));}),
_dItem(Icons.menu_book,'Étagères',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ShelvesPage()));}),
_dSec('Suivi de lecture'),
_dItem(Icons.play_circle_outline,'Séance',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const StartReadingSessionPage()));}),
_dItem(Icons.label_outline,'Statuts',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingStatusPage()));}),
_dItem(Icons.linear_scale,'Progression',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingProgressPage()));}),
_dItem(Icons.flag_outlined,'Objectifs',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingGoalsPage()));}),
_dItem(Icons.history,'Historique',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingHistoryPage()));}),
_dItem(Icons.bar_chart_outlined,'Stats',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingStatsPage()));}),
_dItem(Icons.emoji_events_outlined,'Badges',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ReadingBadgesPage()));}),
_dSec('Paramètres'),
_dItem(Icons.key,'Clés API',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ApiKeyPage()));}),
_dItem(Icons.settings,'Paramètres scan',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const ScanSettingsPage()));}),
Consumer<AppLockStore>(builder:(_,st,__)=>SwitchListTile(
secondary:const Icon(Icons.lock_outline,color:kBlue),
title:Text('Verrou bio',style:tBebas(18,c:kInk,ls:1)),
value:st.enabled,onChanged:(v)=>st.setEnabled(v),activeColor:kBlue)),
const Divider(color:Color(0xFFE0D8C8)),
_dItem(Icons.list_alt,'Logs',(){Navigator.pop(c);Navigator.push(c,MaterialPageRoute(builder:(_)=>const LogsPage()));}),
]));

Widget _dSec(String t)=>Padding(padding:const EdgeInsets.fromLTRB(20,16,20,4),child:Text(t.toUpperCase(),style:tMono(9,c:kMuted,ls:3)));
Widget _dItem(IconData icon,String label,VoidCallback onTap)=>ListTile(leading:Icon(icon,color:kBlue,size:18),title:Text(label,style:tBebas(18,c:kInk,ls:1)),onTap:onTap,tileColor:kPaper,dense:true,visualDensity:const VisualDensity(vertical:-1));
Widget _dExp(IconData icon,String label,List<Widget> ch)=>ExpansionTile(leading:Icon(icon,color:kBlue,size:18),title:Text(label,style:tBebas(18,c:kInk,ls:1)),iconColor:kBlue,collapsedIconColor:kBlue,backgroundColor:kPaper,collapsedBackgroundColor:kPaper,children:ch);
Widget _dSub(IconData icon,String label,VoidCallback onTap)=>ListTile(contentPadding:const EdgeInsets.only(left:56,right:16),leading:Icon(icon,color:kBlue,size:16),title:Text(label,style:tBebas(16,c:kInk,ls:1)),onTap:onTap,tileColor:kPaper,dense:true);
}

// ── SUBWIDGETS ────────────────────────────────────────────────────────────────

class _ContinuePanel extends StatelessWidget{
final List<Book> books;final void Function(Book) onTap;
const _ContinuePanel({required this.books,required this.onTap});
@override Widget build(BuildContext c){
final b=books.first;final cp=b.coverLocalPath;final hasCover=cp!=null&&cp.isNotEmpty;
return GestureDetector(onTap:()=>onTap(b),child:Container(
decoration:const BoxDecoration(border:Border.fromBorderSide(BorderSide(color:kBorder,width:3))),
child:Stack(children:[
SizedBox(width:double.infinity,height:200,child:hasCover
?Image.file(File(cp),fit:BoxFit.cover,errorBuilder:(_,__,___)=>const _GradCover())
:const _GradCover()),
Positioned.fill(child:Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Color(0xF2000000)],stops:[0.3,1.0])))),
Positioned(top:12,right:12,child:Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),decoration:BoxDecoration(color:kYellow,border:Border.all(color:kInk,width:2)),child:Text('1 / ${books.length}',style:tBebas(14,c:kInk,ls:1)))),
Positioned(bottom:0,left:0,right:0,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Text(b.title.toUpperCase(),style:tBebas(28),maxLines:2,overflow:TextOverflow.ellipsis),
const SizedBox(height:4),
Text('▶ Continuer la lecture',style:tMono(10,c:kYellow,ls:2)),
]))),
])));}
}

class _GradCover extends StatelessWidget{
const _GradCover();
@override Widget build(BuildContext c)=>Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF1a1a2e),Color(0xFF0f3460),Color(0xFF533483)])));}

class _LastReadCard extends StatelessWidget{
final Book book;final VoidCallback onTap;
const _LastReadCard({required this.book,required this.onTap});
@override Widget build(BuildContext c){
final cp=book.coverLocalPath;final h=cp!=null&&cp.isNotEmpty;
return GestureDetector(onTap:onTap,child:Container(
padding:const EdgeInsets.all(14),
decoration:const BoxDecoration(color:kPanelBg,border:Border(top:BorderSide(color:kBorder,width:3),right:BorderSide(color:kBorder,width:3),bottom:BorderSide(color:kBorder,width:3),left:BorderSide(color:kRed,width:4))),
child:Row(children:[
Container(width:60,height:85,decoration:const BoxDecoration(border:Border.fromBorderSide(BorderSide(color:Color(0xFF3A3530),width:2))),child:h?Image.file(File(cp),fit:BoxFit.cover,errorBuilder:(_,__,___)=>_ph()):_ph()),
const SizedBox(width:14),
Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
Text('Dernière lecture',style:tMono(9,c:kRed,ls:3)),
const SizedBox(height:4),
Text(book.title.isEmpty?'Sans titre':book.title.toUpperCase(),style:tBebas(26),maxLines:2,overflow:TextOverflow.ellipsis),
const SizedBox(height:4),
Row(children:[
Container(width:6,height:6,decoration:BoxDecoration(color:Colors.green,shape:BoxShape.circle,boxShadow:[BoxShadow(color:Colors.green.withValues(alpha:0.6),blurRadius:4)])),
const SizedBox(width:6),
Text('Terminé récemment',style:tMono(10)),
]),
])),
])));}
static Widget _ph()=>Container(color:kPanelBg,child:const Icon(Icons.menu_book,color:kMuted,size:24));}

class _ClassifyGrid extends StatelessWidget{
final List<Book> books;final void Function(Book) onTap;
const _ClassifyGrid({required this.books,required this.onTap});
@override Widget build(BuildContext c){
final shown=books.take(6).toList();
return GridView.builder(
shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,childAspectRatio:2/3,crossAxisSpacing:10,mainAxisSpacing:10),
itemCount:shown.length,
itemBuilder:(c,i){
final b=shown[i];final cp=b.coverLocalPath;final h=cp!=null&&cp.isNotEmpty;
return GestureDetector(onTap:()=>onTap(b),child:Container(
decoration:const BoxDecoration(border:Border.fromBorderSide(BorderSide(color:kBorder,width:3)),color:kPanelBg),
child:Stack(children:[
if(h)Positioned.fill(child:Image.file(File(cp),fit:BoxFit.cover,errorBuilder:(_,__,___)=>_ph())),
if(!h)_ph(),
if(b.isbn!=null&&b.isbn!.isNotEmpty)Positioned(bottom:0,left:0,right:0,child:Container(
padding:const EdgeInsets.symmetric(horizontal:6,vertical:3),color:Colors.black87,
child:Text('ISBN ${b.isbn}',style:tMono(7,ls:0.5),overflow:TextOverflow.ellipsis))),
])));});}
static Widget _ph()=>Center(child:Icon(Icons.menu_book,color:kMuted.withValues(alpha:0.3),size:28));}
