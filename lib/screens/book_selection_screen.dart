import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/localization.dart';
import '../models/book.dart';
import '../providers/app_settings_provider.dart';
import '../providers/bible_reading_provider.dart';
import '../theme/app_colors.dart';

class BookSelectionScreen extends ConsumerStatefulWidget {
  const BookSelectionScreen({super.key});

  @override
  ConsumerState<BookSelectionScreen> createState() => _BookSelectionScreenState();
}

class _BookSelectionScreenState extends ConsumerState<BookSelectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final readingState = ref.watch(bibleReadingProvider);
    final settings = ref.watch(settingsProvider);
    final loc = AppLocalizations.of(settings.languageCode);
    final isTelugu = settings.languageCode == 'te';

    List<Book> filteredBooks = readingState.books.where((book) {
      final nameLower = book.name.toLowerCase();
      final englishLower = book.nameEnglish.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return nameLower.contains(queryLower) || englishLower.contains(queryLower);
    }).toList();

    List<Book> otBooks = filteredBooks.where((b) => b.testament == 'OT').toList();
    List<Book> ntBooks = filteredBooks.where((b) => b.testament == 'NT').toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.ivory50,
      appBar: AppBar(
        title: Text(
          loc.translate('chooseBook'),
          style: TextStyle(
            fontFamily: isTelugu ? 'NotoSansTelugu' : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110.0),
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: isTelugu
                        ? 'పుస్తకం పేరు శోధించండి (e.g., ఆదికాండము, John)'
                        : 'Search book name (e.g., Genesis, John)',
                    hintStyle: TextStyle(
                      fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.navy850 : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.gold500,
                labelColor: isDark ? AppColors.gold300 : AppColors.navy900,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                ),
                tabs: [
                  Tab(text: loc.translate('oldTestament')),
                  Tab(text: loc.translate('newTestament')),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookGrid(theme, isDark, otBooks, isTelugu),
          _buildBookGrid(theme, isDark, ntBooks, isTelugu),
        ],
      ),
    );
  }

  Widget _buildBookGrid(ThemeData theme, bool isDark, List<Book> books, bool isTelugu) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isTelugu ? 'పుస్తకములేవీ కనుగొనబడలేదు' : 'No books found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(theme, isDark, book, isTelugu);
      },
    );
  }

  Widget _buildBookCard(ThemeData theme, bool isDark, Book book, bool isTelugu) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy850 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {

            context.push('/chapters', extra: book);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: book.testament == 'OT' ? Colors.deepPurple : Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isTelugu ? book.name : book.nameEnglish,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.navy900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isTelugu ? book.nameEnglish : book.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isTelugu
                      ? '${book.totalChapters} అధ్యాయాలు'
                      : '${book.totalChapters} Chapters',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                    color: AppColors.gold500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
