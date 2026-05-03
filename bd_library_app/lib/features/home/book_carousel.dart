import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../db/app_db.dart';

/// Ressort plus ferme : le carrousel se cale plus vite sur chaque livre après un swipe.
class _SnappyPageScrollPhysics extends PageScrollPhysics {
  const _SnappyPageScrollPhysics({super.parent});

  @override
  _SnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _SnappyPageScrollPhysics(parent: buildParent(ancestor));

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.26,
        stiffness: 380,
        damping: 26,
      );
}

class BookCarousel extends StatefulWidget {
  final String title;
  final List<Book> books;
  final void Function(Book) onTap;
  final Widget? trailing;

  const BookCarousel({
    super.key,
    required this.title,
    required this.books,
    required this.onTap,
    this.trailing,
  });

  static Widget _ph() => Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.menu_book, size: 32)),
      );

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  static const int _infinitePagesPerBook = 10000;

  late final PageController _pageController;

  int get _n => widget.books.length;

  int get _virtualCount {
    if (_n <= 1) return _n;
    return _n * _infinitePagesPerBook;
  }

  int get _initialVirtualPage {
    if (_n <= 1) return 0;
    return _n * (_infinitePagesPerBook ~/ 2);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.34,
      initialPage: _initialVirtualPage,
    );
  }

  @override
  void didUpdateWidget(BookCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.books.length != widget.books.length && _pageController.hasClients) {
      final target = _initialVirtualPage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) return;
        _pageController.jumpToPage(target);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _bookIndexForVirtualPage(int page) {
    if (_n == 0) return 0;
    if (_n == 1) return 0;
    return ((page % _n) + _n) % _n;
  }

  int _displayIndex1Based(double page) => _bookIndexForVirtualPage(page.round()) + 1;

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const _SnappyPageScrollPhysics(),
                padEnds: false,
                itemCount: _virtualCount,
                itemBuilder: (context, i) {
                  final b = widget.books[_bookIndexForVirtualPage(i)];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      final pos = _pageController.position;
                      final double page = !pos.hasContentDimensions
                          ? _pageController.initialPage.toDouble()
                          : (_pageController.page ??
                              _pageController.initialPage.toDouble());
                      final delta = i - page;
                      final rot = -delta * 0.55;
                      final scale = math.max(0.72, 1 - delta.abs() * 0.18);
                      final opacity = 0.38 +
                          (1 - delta.abs().clamp(0.0, 1.0)) * 0.62;
                      final matrix = Matrix4.identity()
                        ..setEntry(3, 2, 0.0022)
                        ..rotateY(rot);
                      return Transform(
                        alignment: Alignment.center,
                        transform: matrix,
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () => widget.onTap(b),
                      child: _bookTile(b),
                    ),
                  );
                },
              ),
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, _) {
                    final pos = _pageController.position;
                    final double page = !pos.hasContentDimensions
                        ? _pageController.initialPage.toDouble()
                        : (_pageController.page ??
                            _pageController.initialPage.toDouble());
                    final cur = _displayIndex1Based(page);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          '$cur / $_n',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookTile(Book b) {
    final cp = b.coverLocalPath;
    final hasC = cp != null && cp.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 140,
              width: 100,
              child: hasC
                  ? Image.file(
                      File(cp),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => BookCarousel._ph(),
                    )
                  : BookCarousel._ph(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            b.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final String? subtitle;
  final void Function() onTap;

  const BookCard({
    super.key,
    required this.book,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext c) {
    final cp = book.coverLocalPath;
    final hasC = cp != null && cp.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 100,
                  width: 70,
                  child: hasC
                      ? Image.file(
                          File(cp),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => BookCarousel._ph(),
                        )
                      : BookCarousel._ph(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
