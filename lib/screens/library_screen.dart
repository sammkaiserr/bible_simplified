import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/bookmark_provider.dart';
import '../providers/highlight_provider.dart';
import '../providers/note_provider.dart';
import '../providers/bible_reading_provider.dart';
import '../models/bookmark.dart';
import '../models/note.dart';
import '../models/highlight.dart';
import '../theme/app_colors.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return AppColors.gold500;
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bookmarks = ref.watch(bookmarkProvider);
    final highlights = ref.watch(highlightProvider);
    final notes = ref.watch(noteProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.ivory50,
      appBar: AppBar(
        title: const Text(
          'నా లైబ్రరీ (My Library)',
          style: TextStyle(
            fontFamily: 'NotoSansTelugu',
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold500,
          labelColor: AppColors.gold500,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: const TextStyle(
            fontFamily: 'NotoSansTelugu',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'NotoSansTelugu',
            fontSize: 13,
          ),
          tabs: [
            Tab(
              text: 'బుక్‌మార్క్‌లు (${bookmarks.length})',
              icon: const Icon(Icons.bookmark_rounded, size: 20),
            ),
            Tab(
              text: 'నోట్స్ (${notes.length})',
              icon: const Icon(Icons.note_alt_rounded, size: 20),
            ),
            Tab(
              text: 'హైలైట్స్ (${highlights.length})',
              icon: const Icon(Icons.palette_rounded, size: 20),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildBookmarksTab(context, theme, isDark, bookmarks),
          _buildNotesTab(context, theme, isDark, notes),
          _buildHighlightsTab(context, theme, isDark, highlights),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, IconData icon, String message, String subMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: isDark ? Colors.white24 : Colors.black12,
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'NotoSansTelugu',
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : AppColors.navy800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'NotoSansTelugu',
                color: isDark ? Colors.white30 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksTab(BuildContext context, ThemeData theme, bool isDark, List<Bookmark> list) {
    if (list.isEmpty) {
      return _buildEmptyState(
        theme,
        isDark,
        Icons.bookmark_border_rounded,
        'బుక్‌మార్క్‌లు లేవు',
        'మనం చదువుతున్నప్పుడు నచ్చిన వాక్యాన్ని లాంగ్-ప్రెస్ చేసి బుక్‌మార్క్ చేసుకోవచ్చు.',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final book = ref.read(bibleReadingProvider).books.firstWhere(
              (b) => b.id == item.bookId,
              orElse: () => ref.read(bibleReadingProvider).books.first,
            );

        return Dismissible(
          key: Key('bookmark_${item.verseId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
          ),
          onDismissed: (_) {
            ref.read(bookmarkProvider.notifier).deleteBookmark(item.verseId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('బుక్‌మార్క్ తొలగించబడింది')),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.12),
              ),
            ),
            color: isDark ? AppColors.navy850 : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                ref.read(bibleReadingProvider.notifier).navigateToChapter(book, item.chapterNumber);
                context.push('/read');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold500.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.bookName ?? book.name} ${item.chapterNumber}:${item.verseNumber}',
                            style: const TextStyle(
                              fontFamily: 'NotoSansTelugu',
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(item.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? Colors.white30 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.verseText ?? '',
                      style: TextStyle(
                        fontFamily: 'NotoSansTelugu',
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? Colors.white.withOpacity(0.87) : AppColors.navy900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildNotesTab(BuildContext context, ThemeData theme, bool isDark, List<Note> list) {
    if (list.isEmpty) {
      return _buildEmptyState(
        theme,
        isDark,
        Icons.note_alt_outlined,
        'నోట్స్ లేవు',
        'వాక్యాన్ని సెలెక్ట్ చేసి "నోట్ రాయండి" క్లిక్ చేయడం ద్వారా నోట్స్ రాసుకోవచ్చు.',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final book = ref.read(bibleReadingProvider).books.firstWhere(
              (b) => b.id == item.bookId,
              orElse: () => ref.read(bibleReadingProvider).books.first,
            );

        return Dismissible(
          key: Key('note_${item.verseId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
          ),
          onDismissed: (_) {
            ref.read(noteProvider.notifier).deleteNote(item.verseId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('నోట్ తొలగించబడింది')),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.12),
              ),
            ),
            color: isDark ? AppColors.navy850 : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                ref.read(bibleReadingProvider.notifier).navigateToChapter(book, item.chapterNumber);
                context.push('/read');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.bookName ?? book.name} ${item.chapterNumber}:${item.verseNumber}',
                            style: const TextStyle(
                              fontFamily: 'NotoSansTelugu',
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(item.updatedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? Colors.white30 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.verseText ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'NotoSansTelugu',
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sticky_note_2_rounded, color: AppColors.gold500, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.content,
                            style: TextStyle(
                              fontFamily: 'NotoSansTelugu',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: isDark ? Colors.white : AppColors.navy950,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildHighlightsTab(BuildContext context, ThemeData theme, bool isDark, List<Highlight> list) {
    if (list.isEmpty) {
      return _buildEmptyState(
        theme,
        isDark,
        Icons.palette_outlined,
        'హైలైట్స్ లేవు',
        'మనం చదువుతున్నప్పుడు నచ్చిన వాక్యాన్ని క్లిక్ చేసి రంగులతో హైలైట్ చేసుకోవచ్చు.',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final book = ref.read(bibleReadingProvider).books.firstWhere(
              (b) => b.id == item.bookId,
              orElse: () => ref.read(bibleReadingProvider).books.first,
            );

        return Dismissible(
          key: Key('highlight_${item.verseId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
          ),
          onDismissed: (_) {
            ref.read(highlightProvider.notifier).removeHighlight(item.verseId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('హైలైట్ తొలగించబడింది')),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.12),
              ),
            ),
            color: isDark ? AppColors.navy850 : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                ref.read(bibleReadingProvider.notifier).navigateToChapter(book, item.chapterNumber);
                context.push('/read');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _parseColor(item.colorHex).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.bookName ?? book.name} ${item.chapterNumber}:${item.verseNumber}',
                            style: TextStyle(
                              fontFamily: 'NotoSansTelugu',
                              fontWeight: FontWeight.bold,
                              color: _parseColor(item.colorHex),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(item.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? Colors.white30 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _parseColor(item.colorHex).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          left: BorderSide(color: _parseColor(item.colorHex), width: 4),
                        ),
                      ),
                      child: Text(
                        item.verseText ?? '',
                        style: TextStyle(
                          fontFamily: 'NotoSansTelugu',
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? Colors.white : AppColors.navy950,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
