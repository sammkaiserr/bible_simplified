import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/localization.dart';
import '../models/book.dart';
import '../providers/app_settings_provider.dart';
import '../providers/bible_reading_provider.dart';
import '../theme/app_colors.dart';

class ChapterSelectionScreen extends ConsumerWidget {
  final Book book;

  const ChapterSelectionScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final isTelugu = settings.languageCode == 'te';
    final loc = AppLocalizations.of(settings.languageCode);

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.ivory50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? book.name : book.nameEnglish,
              style: TextStyle(
                fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isTelugu
                  ? '${book.nameEnglish} • అధ్యాయమును ఎంచుకోండి'
                  : '${book.name} • ${loc.translate('chooseChapter')}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: isTelugu ? 'NotoSansTelugu' : null,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: book.totalChapters,
        itemBuilder: (context, index) {
          final chapterNum = index + 1;
          return _buildChapterButton(context, ref, theme, isDark, chapterNum);
        },
      ),
    );
  }

  Widget _buildChapterButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    bool isDark,
    int chapterNum,
  ) {
    // Check if this is the currently selected chapter in state to highlight it
    final readingState = ref.watch(bibleReadingProvider);
    final isCurrent = readingState.currentBook?.id == book.id &&
        readingState.currentChapter == chapterNum;

    return Container(
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.gold500
            : (isDark ? AppColors.navy850 : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.gold500
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? AppColors.gold500.withOpacity(isDark ? 0.25 : 0.35)
                : Colors.black.withOpacity(isDark ? 0.1 : 0.01),
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
            ref.read(bibleReadingProvider.notifier).navigateToChapter(book, chapterNum);
            // Route to reading page
            context.push('/read');
          },
          child: Center(
            child: Text(
              '$chapterNum',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isCurrent 
                    ? Colors.white 
                    : (isDark ? Colors.white : AppColors.navy950),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
