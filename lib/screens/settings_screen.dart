import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/localization.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final loc = AppLocalizations.of(settings.languageCode);

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.ivory50,
      appBar: AppBar(
        title: Text(
          loc.translate('settings'),
          style: TextStyle(
            fontFamily: settings.languageCode == 'te' ? 'NotoSansTelugu' : null,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section: Language Selector
          _buildSectionHeader(theme, isDark, loc.translate('language'), settings.languageCode),
          _buildCardContainer(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.translate('selectLanguage'),
                  style: TextStyle(
                    fontFamily: settings.languageCode == 'te' ? 'NotoSansTelugu' : null,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment<String>(
                      value: 'te',
                      icon: const Icon(Icons.language_rounded),
                      label: Text(
                        loc.translate('telugu'),
                        style: TextStyle(
                          fontFamily: settings.languageCode == 'te' ? 'NotoSansTelugu' : null,
                        ),
                      ),
                    ),
                    ButtonSegment<String>(
                      value: 'en',
                      icon: const Icon(Icons.translate_rounded),
                      label: Text(
                        loc.translate('english'),
                        style: TextStyle(
                          fontFamily: settings.languageCode == 'te' ? 'NotoSansTelugu' : null,
                        ),
                      ),
                    ),
                  ],
                  selected: {settings.languageCode},
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.gold500,
                    selectedForegroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  onSelectionChanged: (Set<String> newSelection) {
                    ref.read(settingsProvider.notifier).setLanguageCode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Appearance & Theme
          _buildSectionHeader(theme, isDark, loc.translate('theme'), settings.languageCode),
          _buildCardContainer(
            isDark: isDark,
            child: Column(
              children: [
                _buildThemeSelector(theme, isDark, settings.themeMode, loc),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Typography & Text Settings
          _buildSectionHeader(theme, isDark, loc.translate('fontSize'), settings.languageCode),
          _buildCardContainer(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.translate('fontSize'),
                      style: TextStyle(
                        fontFamily: settings.languageCode == 'te' ? 'NotoSansTelugu' : null,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${settings.fontSize.toInt()} px',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: settings.fontSize,
                  min: AppConstants.minFontSize,
                  max: AppConstants.maxFontSize,
                  divisions: ((AppConstants.maxFontSize - AppConstants.minFontSize) * 2).toInt(),
                  activeColor: AppColors.gold500,
                  inactiveColor: isDark ? Colors.white12 : Colors.black12,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setFontSize(val);
                  },
                ),
                const SizedBox(height: 12),
                // Live Preview Container
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.navy900 : AppColors.ivory200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.languageCode == 'te' ? 'లైవ్ ప్రివ్యూ (Live Preview):' : 'Live Preview:',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: settings.languageCode == 'te' ? 'NotoSansTelugu' : null,
                          color: isDark ? Colors.white38 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        settings.languageCode == 'te'
                            ? 'ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.'
                            : 'In the beginning God created the heaven and the earth.',
                        style: TextStyle(
                          fontFamily: settings.languageCode == 'te' ? 'NotoSansTelugu' : null,
                          fontSize: settings.fontSize,
                          height: 1.6,
                          color: isDark ? Colors.white : AppColors.navy950,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),



          // Section: About App
          _buildSectionHeader(theme, isDark, loc.translate('aboutApp'), settings.languageCode),
          _buildCardContainer(
            isDark: isDark,
            child: Column(
              children: [
                _buildAboutRow(
                  settings.languageCode == 'te' ? 'యాప్ పేరు' : 'App Name',
                  loc.translate('appName'),
                  settings.languageCode,
                ),
                const Divider(),
                _buildAboutRow(
                  settings.languageCode == 'te' ? 'వెర్షన్' : 'Version',
                  '1.0.0',
                  settings.languageCode,
                ),
                const Divider(),
                _buildAboutRow(
                  loc.translate('developedBy'),
                  loc.translate('developerName'),
                  settings.languageCode,
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    loc.translate('aboutText'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: settings.languageCode == 'te' ? 'NotoSansTelugu' : null,
                      color: isDark ? Colors.white38 : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, bool isDark, String title, String languageCode) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontFamily: languageCode == 'te' ? 'NotoSansTelugu' : null,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.gold300 : AppColors.navy800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCardContainer({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy850 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.12 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildThemeSelector(ThemeData theme, bool isDark, ThemeMode currentMode, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.languageCode == 'te' ? 'యాప్ థీమ్ ఎంచుకోండి:' : 'Select App Theme:',
          style: TextStyle(
            fontFamily: loc.languageCode == 'te' ? 'NotoSansTelugu' : null,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode_rounded),
              label: Text(
                loc.translate('lightMode'),
                style: TextStyle(
                  fontFamily: loc.languageCode == 'te' ? 'NotoSansTelugu' : null,
                ),
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode_rounded),
              label: Text(
                loc.translate('darkMode'),
                style: TextStyle(
                  fontFamily: loc.languageCode == 'te' ? 'NotoSansTelugu' : null,
                ),
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              icon: const Icon(Icons.settings_suggest_rounded),
              label: Text(
                loc.translate('systemTheme'),
                style: TextStyle(
                  fontFamily: loc.languageCode == 'te' ? 'NotoSansTelugu' : null,
                ),
              ),
            ),
          ],
          selected: {currentMode},
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.gold500,
            selectedForegroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 13),
          ),
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            ref.read(settingsProvider.notifier).setThemeMode(newSelection.first);
          },
        ),
      ],
    );
  }


  Widget _buildAboutRow(String title, String val, String languageCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: languageCode == 'te' ? 'NotoSansTelugu' : null,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontFamily: languageCode == 'te' ? 'NotoSansTelugu' : null,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
