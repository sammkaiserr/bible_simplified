import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/localization.dart';
import '../models/book.dart';
import '../providers/app_settings_provider.dart';
import '../providers/bible_reading_provider.dart';
import '../theme/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final readingState = ref.watch(bibleReadingProvider);
    final settings = ref.watch(settingsProvider);
    final loc = AppLocalizations.of(settings.languageCode);
    final isTelugu = settings.languageCode == 'te';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.navy950, AppColors.navy900]
                : [AppColors.ivory50, AppColors.ivory100],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // Trigger reload in provider if needed
            },
            color: AppColors.gold500,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Custom App Bar
                // Custom App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.translate('appName'),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.gold300 : AppColors.navy900,
                          ),
                        ),
                        // Quick Settings Button
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          color: isDark ? Colors.white70 : AppColors.navy800,
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Navigation Library Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            theme: theme,
                            isDark: isDark,
                            title: loc.translate('search'),
                            subtitle: isTelugu ? 'FTS5 వేగవంతమైన శోధన' : 'FTS5 Fast Search',
                            icon: Icons.search_rounded,
                            color: Colors.teal,
                            languageCode: settings.languageCode,
                            onTap: () => context.push('/search'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            theme: theme,
                            isDark: isDark,
                            title: loc.translate('library'),
                            subtitle: isTelugu ? 'బుక్‌మార్క్‌లు & నోట్స్' : 'Bookmarks & Notes',
                            icon: Icons.bookmarks_rounded,
                            color: Colors.deepPurple,
                            languageCode: settings.languageCode,
                            onTap: () => context.push('/library'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Continue Reading Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: _buildContinueReadingCard(theme, isDark, readingState, isTelugu),
                  ),
                ),

                // Recently Opened Section
                if (readingState.recentlyOpened.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 8.0),
                      child: Text(
                        isTelugu ? 'ఇటీవల చదివినవి' : 'Recently Read',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white.withOpacity(0.80) : AppColors.navy900,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: readingState.recentlyOpened.length,
                        itemBuilder: (context, index) {
                          final book = readingState.recentlyOpened[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _buildRecentBookCard(theme, isDark, book, isTelugu),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Browse Bible Books Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 24.0, right: 20.0, bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isTelugu ? 'గ్రంథములు (Books)' : 'Books of the Bible',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white.withOpacity(0.80) : AppColors.navy900,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/books'),
                          child: Row(
                            children: [
                              Text(
                                isTelugu ? 'అన్నీ చూడండి' : 'See All',
                                style: TextStyle(
                                  fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Seeded/Popular Books Quick Navigation Grid
                SliverPadding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 32.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Quick access to preloaded Books: Genesis (1), Psalms (19), Matthew (40), John (43)
                        final popularBookIds = [1, 19, 40, 43];
                        if (readingState.books.isEmpty) return const SizedBox();
                        final bookId = popularBookIds[index];
                        final book = readingState.books.firstWhere(
                          (b) => b.id == bookId,
                          orElse: () => readingState.books.first,
                        );

                        return _buildBookQuickTile(theme, isDark, book, isTelugu);
                      },
                      childCount: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildContinueReadingCard(ThemeData theme, bool isDark, BibleReadingState state, bool isTelugu) {
    final book = state.currentBook;
    if (book == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.gold500, AppColors.amber700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold500.withOpacity(isDark ? 0.15 : 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/read'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTelugu ? 'చదవడం కొనసాగించండి' : 'Continue Reading',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isTelugu 
                              ? '${book.name} - అధ్యాయం ${state.currentChapter}'
                              : '${book.nameEnglish} - Chapter ${state.currentChapter}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String languageCode,
    required VoidCallback onTap,
  }) {
    final isTelugu = languageCode == 'te';
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy850 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.navy900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBookCard(ThemeData theme, bool isDark, Book book, bool isTelugu) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy850 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(bibleReadingProvider.notifier).navigateToChapter(book, 1);
            context.push('/read');
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_rounded, size: 16, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  isTelugu ? book.name : book.nameEnglish,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.navy900,
                  ),
                ),
                Text(
                  isTelugu ? book.nameEnglish : book.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
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

  Widget _buildBookQuickTile(ThemeData theme, bool isDark, Book book, bool isTelugu) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy850 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(bibleReadingProvider.notifier).navigateToChapter(book, 1);
            context.push('/read');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (book.testament == 'OT' ? Colors.deepPurple : Colors.teal).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      book.testament,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: book.testament == 'OT' ? Colors.deepPurple : Colors.teal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isTelugu ? book.name : book.nameEnglish,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.navy900,
                        ),
                      ),
                      Text(
                        isTelugu ? book.nameEnglish : book.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
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
