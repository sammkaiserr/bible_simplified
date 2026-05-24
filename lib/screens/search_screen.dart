import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/search_provider.dart';
import '../providers/bible_reading_provider.dart';
import '../theme/app_colors.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.ivory50,
      appBar: AppBar(
        title: const Text(
          'వాక్య శోధన (Search)',
          style: TextStyle(
            fontFamily: 'NotoSansTelugu',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Input Container
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'పుస్తకం లేదా వాక్యం శోధించండి (e.g. ప్రేమా, దేవుడు)',
                  hintStyle: const TextStyle(fontFamily: 'NotoSansTelugu', fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchProvider.notifier).clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.navy850 : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: _buildResultsBody(theme, isDark, searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBody(ThemeData theme, bool isDark, SearchState searchState) {
    if (searchState.isLoading) {
      return _buildLoadingShimmer(isDark);
    }

    if (searchState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                searchState.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'NotoSansTelugu',
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (searchState.query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 72,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'బైబిల్ గ్రంథం నుండి శోధించండి',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'NotoSansTelugu',
                color: isDark ? Colors.white30 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'పదాలు, వాక్యాలు లేదా పుస్తకాలను సులభంగా శోధించవచ్చు',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'NotoSansTelugu',
                color: isDark ? Colors.white24 : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '"${searchState.query}" కి సరిపోలిన వాక్యాలు లేవు',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'NotoSansTelugu',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'మరొక పదాన్ని ప్రయత్నించండి',
              style: TextStyle(fontFamily: 'NotoSansTelugu', color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final result = searchState.results[index];
        return _buildResultCard(context, theme, isDark, result, searchState.query)
            .animate(delay: (index * 30).ms)
            .fade(duration: 200.ms)
            .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    VerseSearchResult result,
    String query,
  ) {
    final book = result.book;
    final verse = result.verse;

    return Card(
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
          // Navigate to chapter first
          ref.read(bibleReadingProvider.notifier).navigateToChapter(book, verse.chapterNumber);
          // Route to reading screen
          context.push('/read');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result Citation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.navy900 : AppColors.gold500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${book.name} ${verse.chapterNumber}:${verse.verseNumber}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: 'NotoSansTelugu',
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold500,
                      ),
                    ),
                  ),
                  Text(
                    book.nameEnglish,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.white30 : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Match snippet (Original traditional)
              Text(
                'సులభమైన వివరణ (Simple):',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'NotoSansTelugu',
                  color: isDark ? Colors.white38 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              _buildHighlightedText(verse.originalText, query, theme, isDark, false),
              
              if (verse.simpleText != null) ...[
                const SizedBox(height: 10),
                // Match snippet (Original traditional)
                Text(
                  'అసలు వాక్యం (Original):',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'NotoSansTelugu',
                    color: AppColors.gold500.withOpacity(isDark ? 0.6 : 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                _buildHighlightedText(verse.simpleText!, query, theme, isDark, true),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    ThemeData theme,
    bool isDark,
    bool isSimple,
  ) {
    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontFamily: 'NotoSansTelugu',
          fontSize: 14,
          height: 1.5,
          color: isDark ? Colors.white70 : AppColors.navy800,
        ),
      );
    }

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();

    final List<TextSpan> spans = [];
    int start = 0;
    int index = textLower.indexOf(queryLower, start);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.navy800,
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: AppColors.gold500.withOpacity(0.35),
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.navy950,
        ),
      ));

      start = index + query.length;
      index = textLower.indexOf(queryLower, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(
          color: isDark ? Colors.white70 : AppColors.navy800,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'NotoSansTelugu',
          fontSize: 14,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildLoadingShimmer(bool isDark) {
    final shimmerBase = isDark ? AppColors.navy850 : Colors.grey[300]!;
    final shimmerHighlight = isDark ? AppColors.navy800 : Colors.grey[100]!;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: shimmerBase,
          highlightColor: shimmerHighlight,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 16, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(width: double.infinity, height: 12, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 12, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 12, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
