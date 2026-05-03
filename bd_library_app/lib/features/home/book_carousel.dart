import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../db/app_db.dart';

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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.42);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: widget.books.length,
            itemBuilder: (context, i) {
              final b = widget.books[i];
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
        ),
      ],
    );
  }

  Widget _bookTile(Book b) {
    final cp = b.coverLocalPath;
    final hasC = cp != null && cp.isNotEmpty;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
