import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../models/book.dart';
import '../models/chapter_key.dart';
import '../models/verse.dart';
import '../models/note.dart';
import '../providers/app_settings_provider.dart';
import '../providers/bible_reading_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/highlight_provider.dart';
import '../providers/note_provider.dart';
import '../services/share_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  final ShareService _shareService = ShareService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final readingState = ref.watch(bibleReadingProvider);
    final settings = ref.watch(settingsProvider);

    if (readingState.isLoading || readingState.currentBook == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold500),
        ),
      );
    }

    final book = readingState.currentBook!;
    final chapter = readingState.currentChapter;

    // Fetch chapter Highlights and Notes asynchronously
    final highlightsAsync = ref.watch(chapterHighlightsProvider(ChapterKey(book.id, chapter)));
    final notesAsync = ref.watch(chapterNotesProvider(ChapterKey(book.id, chapter)));

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.ivory50,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.push('/books'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${book.name} $chapter',
                style: const TextStyle(
                  fontFamily: 'NotoSansTelugu',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_drop_down_rounded, size: 28),
            ],
          ),
        ),
        actions: [
          // Reading Mode Selector Icon Button
          IconButton(
            icon: const Icon(Icons.translate_rounded),
            tooltip: 'రీడింగ్ మోడ్',
            onPressed: () => _showReadingModeSelector(context, ref, settings),
          ),
          // Font Settings Button
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'అక్షరాల పరిమాణం',
            onPressed: () => _showFontSizeSelector(context, ref, settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < 0) {
                  // Swipe Left -> Next Chapter
                  ref.read(bibleReadingProvider.notifier).nextChapter();
                } else if (details.primaryVelocity! > 0) {
                  // Swipe Right -> Previous Chapter
                  ref.read(bibleReadingProvider.notifier).previousChapter();
                }
              },
              child: highlightsAsync.when(
                data: (highlightsMap) => notesAsync.when(
                  data: (notesMap) => _buildVersesList(
                    context,
                    theme,
                    isDark,
                    book,
                    readingState.verses,
                    settings,
                    highlightsMap,
                    notesMap,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error loading notes: $e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading highlights: $e')),
              ),
            ),
          ),

          // Bottom Chapter Navigation Bar
          _buildBottomNavBar(context, isDark, book, chapter),
        ],
      ),
    );
  }

  Widget _buildVersesList(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Book book,
    List<Verse> verses,
    AppSettings settings,
    Map<int, String> highlightsMap,
    Map<int, Note> notesMap,
  ) {
    if (verses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'ఈ అధ్యాయానికి సంబంధించిన వచనాలు ఇంకా అందుబాటులో లేవు.\nత్వరలోనే అప్‌డేట్ చేయబడుతుంది!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'NotoSansTelugu',
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        final highlightColorHex = highlightsMap[verse.id];
        final note = notesMap[verse.id];

        Color? highlightColor;
        if (highlightColorHex != null) {
          final intColor = int.tryParse(highlightColorHex.replaceFirst('#', '0xFF'));
          if (intColor != null) {
            highlightColor = Color(intColor).withOpacity(isDark ? 0.35 : 0.45);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showVerseActionsSheet(context, ref, verse, note != null),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: highlightColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: highlightColor != null
                      ? highlightColor.withOpacity(0.5)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verse header: number & optional annotation indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.navy800 : AppColors.gold500.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'వచనం ${verse.verseNumber}',
                          style: TextStyle(
                            fontFamily: 'NotoSansTelugu',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.gold300 : AppColors.amber800,
                          ),
                        ),
                      ),
                      if (note != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.sticky_note_2_rounded, size: 16, color: AppColors.gold500),
                      ]
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Display according to Reading Mode
                  if (settings.readingMode == AppConstants.readingModeOriginal)
                    Text(
                      verse.originalText,
                      style: AppTypography.teluguOriginal(
                        fontSize: settings.fontSize,
                        isDark: isDark,
                      ),
                    ),

                  if (settings.readingMode == AppConstants.readingModeSimple)
                    Text(
                      verse.simpleText ?? verse.originalText,
                      style: verse.simpleText != null
                          ? AppTypography.teluguSimple(
                              fontSize: settings.fontSize - 1.0,
                              isDark: isDark,
                            )
                          : AppTypography.teluguOriginal(
                              fontSize: settings.fontSize,
                              isDark: isDark,
                            ),
                    ),

                  if (settings.readingMode == AppConstants.readingModeBoth) ...[
                    Text(
                      verse.originalText,
                      style: AppTypography.teluguOriginal(
                        fontSize: settings.fontSize,
                        isDark: isDark,
                      ),
                    ),
                    if (verse.simpleText != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0, right: 6.0),
                            child: Icon(Icons.wb_sunny_rounded, size: 14, color: AppColors.gold500),
                          ),
                          Expanded(
                            child: Text(
                              verse.simpleText!,
                              style: AppTypography.teluguSimple(
                                fontSize: settings.fontSize - 1.0,
                                isDark: isDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  // Display note preview if available
                  if (note != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.navy900.withOpacity(0.6) : Colors.amber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.amber.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'నా నోట్: ${note.content}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontFamily: 'NotoSansTelugu',
                          color: isDark ? Colors.white70 : AppColors.navy700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildBottomNavBar(
    BuildContext context,
    bool isDark,
    Book book,
    int chapter,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Chapter
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                ref.read(bibleReadingProvider.notifier).previousChapter();
                _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
            ),

            // Chapter indicator button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold500.withOpacity(0.15),
                foregroundColor: isDark ? AppColors.gold300 : AppColors.amber800,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => context.push('/chapters', extra: book),
              child: Text(
                'అధ్యాయాలు (Chapters)',
                style: const TextStyle(
                  fontFamily: 'NotoSansTelugu',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Next Chapter
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () {
                ref.read(bibleReadingProvider.notifier).nextChapter();
                _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Settings Bottom Sheets ────────────────────────────────────

  void _showReadingModeSelector(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'రీడింగ్ మోడ్ ఎంచుకోండి',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'NotoSansTelugu',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('రెండు రకాల వచనాలు (Both Texts)', style: TextStyle(fontFamily: 'NotoSansTelugu')),
                subtitle: const Text('మూల వాక్యం మరియు సాధారణ వివరణ రెండు చూపిస్తుంది.'),
                leading: Radio<String>(
                  value: AppConstants.readingModeBoth,
                  groupValue: settings.readingMode,
                  activeColor: AppColors.gold500,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setReadingMode(val!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('సాధారణ తెలుగు మాత్రమే (Simple Telugu)', style: TextStyle(fontFamily: 'NotoSansTelugu')),
                subtitle: const Text('అర్థం చేసుకోవడానికి సులభమైన తెలుగు వాక్యం మాత్రమే చూపిస్తుంది.'),
                leading: Radio<String>(
                  value: AppConstants.readingModeSimple,
                  groupValue: settings.readingMode,
                  activeColor: AppColors.gold500,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setReadingMode(val!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('మూల గ్రంథం మాత్రమే (Original Telugu)', style: TextStyle(fontFamily: 'NotoSansTelugu')),
                subtitle: const Text('సాంప్రదాయ పూర్వ తెలుగు వాక్యం మాత్రమే చూపిస్తుంది.'),
                leading: Radio<String>(
                  value: AppConstants.readingModeOriginal,
                  groupValue: settings.readingMode,
                  activeColor: AppColors.gold500,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setReadingMode(val!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeSelector(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'అక్షరాల పరిమాణం (Font Size)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'NotoSansTelugu',
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'చదవడానికి వీలుగా ఫాంట్ సైజు మార్చుకోండి.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.format_size_rounded, size: 16),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: AppConstants.minFontSize,
                          max: AppConstants.maxFontSize,
                          divisions: 9,
                          activeColor: AppColors.gold500,
                          label: settings.fontSize.round().toString(),
                          onChanged: (val) {
                            ref.read(settingsProvider.notifier).setFontSize(val);
                            setModalState(() {});
                          },
                        ),
                      ),
                      const Icon(Icons.format_size_rounded, size: 28),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'నమూనా అక్షరం (Sample Text)',
                      style: TextStyle(
                        fontFamily: 'NotoSansTelugu',
                        fontSize: settings.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Verse Long-Press Action Bottom Sheet ──────────────────────

  void _showVerseActionsSheet(
    BuildContext context,
    WidgetRef ref,
    Verse verse,
    bool hasNote,
  ) async {
    final readingState = ref.read(bibleReadingProvider);
    final bookName = readingState.currentBook?.name ?? '';
    final isBookmarked = await ref.read(bookmarkProvider.notifier).isBookmarked(verse.id);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet Header
              Text(
                '$bookName ${verse.chapterNumber}:${verse.verseNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'NotoSansTelugu',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Horizontal Highlight Color Options
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Clear Highlight Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () {
                          ref.read(highlightProvider.notifier).removeHighlight(verse.id);
                          ref.invalidate(chapterHighlightsProvider(ChapterKey(verse.bookId, verse.chapterNumber)));
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                          child: const Icon(Icons.format_color_reset_rounded, size: 18),
                        ),
                      ),
                    ),
                    ...AppColors.highlightColors.map((color) {
                      final hexString = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            ref.read(highlightProvider.notifier).setHighlight(
                                  verseId: verse.id,
                                  bookId: verse.bookId,
                                  chapterNumber: verse.chapterNumber,
                                  verseNumber: verse.verseNumber,
                                  colorHex: hexString,
                                );
                            ref.invalidate(chapterHighlightsProvider(ChapterKey(verse.bookId, verse.chapterNumber)));
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 18,
                            child: const SizedBox(),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),

              // Primary Verse Actions List
              ListTile(
                leading: Icon(
                  isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                  color: isBookmarked ? AppColors.gold500 : null,
                ),
                title: Text(
                  isBookmarked ? 'బుక్‌మార్క్ తీసివేయి' : 'బుక్‌మార్క్ చేయండి',
                  style: const TextStyle(fontFamily: 'NotoSansTelugu'),
                ),
                onTap: () async {
                  await ref.read(bookmarkProvider.notifier).toggleBookmark(
                        verseId: verse.id,
                        bookId: verse.bookId,
                        chapterNumber: verse.chapterNumber,
                        verseNumber: verse.verseNumber,
                      );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_rounded),
                title: Text(
                  hasNote ? 'నోట్ సవరించండి' : 'నోట్ రాయండి',
                  style: const TextStyle(fontFamily: 'NotoSansTelugu'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showNoteEditorSheet(context, ref, verse);
                },
              ),

              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('కాపీ చేయండి', style: TextStyle(fontFamily: 'NotoSansTelugu')),
                onTap: () {
                  Clipboard.setData(ClipboardData(
                    text: '📖 $bookName ${verse.chapterNumber}:${verse.verseNumber}\n\n'
                        '${verse.simpleText ?? ""}\n\n'
                        '(${verse.originalText})',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('వచనం కాపీ చేయబడింది!', style: TextStyle(fontFamily: 'NotoSansTelugu')),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: const Text('వాక్యాన్ని పంచుకోండి (Share text)', style: TextStyle(fontFamily: 'NotoSansTelugu')),
                onTap: () {
                  _shareService.shareText(verse: verse, bookName: bookName);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoteEditorSheet(BuildContext context, WidgetRef ref, Verse verse) async {
    final note = await ref.read(noteProvider.notifier).getNoteForVerse(verse.id);
    final controller = TextEditingController(text: note?.content ?? '');

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'నోట్ రాయండి (Add Note)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'NotoSansTelugu',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'ఈ వచనం గురించి మీ ఆలోచనలను ఇక్కడ రాయండి...',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.navy850 : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (note != null)
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () {
                        ref.read(noteProvider.notifier).deleteNote(verse.id);
                        ref.invalidate(chapterNotesProvider(ChapterKey(verse.bookId, verse.chapterNumber)));
                        Navigator.pop(context);
                      },
                      child: const Text('తొలగించు', style: TextStyle(fontFamily: 'NotoSansTelugu')),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        ref.read(noteProvider.notifier).saveNote(
                              verseId: verse.id,
                              bookId: verse.bookId,
                              chapterNumber: verse.chapterNumber,
                              verseNumber: verse.verseNumber,
                              content: controller.text.trim(),
                            );
                        ref.invalidate(chapterNotesProvider(ChapterKey(verse.bookId, verse.chapterNumber)));
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('భద్రపరచు', style: TextStyle(fontFamily: 'NotoSansTelugu', fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


}
