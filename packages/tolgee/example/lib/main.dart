import 'package:flutter/material.dart';
import 'package:tolgee/tolgee.dart';
import 'package:tolgee_in_context/tolgee_in_context.dart';

Future<void> main() async {
  // Run with `--dart-define-from-file=tolgee.env` to load from Tolgee and edit
  // in context. Without it, texts come from the files in `lib/tolgee/`.
  TolgeeInContext.install();
  await Tolgee.init();
  runApp(const WhatToPackApp());
}

class WhatToPackApp extends StatefulWidget {
  const WhatToPackApp({super.key});

  @override
  State<WhatToPackApp> createState() => _WhatToPackAppState();
}

class _WhatToPackAppState extends State<WhatToPackApp> {
  Future<void> _changeLocale(Locale locale) async {
    await Tolgee.setCurrentLocale(locale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      localizationsDelegates: Tolgee.localizationDelegates,
      supportedLocales: Tolgee.supportedLocales,
      locale: Tolgee.currentLocale ?? Tolgee.baseLocale,
      home: PackingListPage(onLocaleChanged: _changeLocale),
    );
  }
}

const _tolgeePink = Color(0xFFEC407A);
const _background = Color(0xFFF6F6F8);
const _outline = Color(0xFFE6E6EB);

ThemeData _theme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _tolgeePink,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  ).copyWith(primary: _tolgeePink, surface: _background);
  final rounded =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: _background,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _tolgeePink, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: rounded,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: rounded,
        side: const BorderSide(color: _outline),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    ),
    dividerTheme: const DividerThemeData(color: _outline, space: 1),
  );
}

class PackingListPage extends StatefulWidget {
  final ValueChanged<Locale> onLocaleChanged;

  const PackingListPage({super.key, required this.onLocaleChanged});

  @override
  State<PackingListPage> createState() => _PackingListPageState();
}

class _PackingListPageState extends State<PackingListPage> {
  final _items = ['Passport', 'Phone charger', 'Sunscreen'];
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _addItem() {
    final item = _input.text.trim();
    if (item.isEmpty) return;
    setState(() => _items.add(item));
    _input.clear();
  }

  void _showNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(Tolgee.translate(key: 'action-not-available')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TranslationWidget(
                        builder: (context, tr) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('app-title'),
                              style: textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr('items-count', {'count': _items.length}),
                              style: textTheme.bodyLarge
                                  ?.copyWith(color: textTheme.bodySmall?.color),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _LanguageMenu(onSelected: widget.onLocaleChanged),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TranslationWidget(
                        builder: (context, tr) => TextField(
                          controller: _input,
                          onEditingComplete: _addItem,
                          decoration: InputDecoration(
                            hintText: tr('add-item-input-placeholder'),
                            prefixIcon: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TranslationWidget(
                      builder: (context, tr) => FilledButton(
                        onPressed: _addItem,
                        child: Text(tr('add-item-add-button')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: TranslationWidget(
                      builder: (context, tr) => Text(
                        tr('empty-list'),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final (index, item) in _items.indexed) ...[
                          if (index > 0) const Divider(indent: 56),
                          ListTile(
                            leading: const Icon(
                              Icons.check_circle_outline,
                              color: _tolgeePink,
                            ),
                            title: Text(item),
                            trailing: TranslationWidget(
                              builder: (context, tr) => IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: tr('delete-item-button'),
                                onPressed: () =>
                                    setState(() => _items.remove(item)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    TranslationWidget(
                      builder: (context, tr) => OutlinedButton.icon(
                        onPressed: _showNotAvailable,
                        icon: const Icon(Icons.share_outlined),
                        label: Text(tr('share-button')),
                      ),
                    ),
                    TranslationWidget(
                      builder: (context, tr) => FilledButton.icon(
                        onPressed: _showNotAvailable,
                        icon: const Icon(Icons.email_outlined),
                        label: Text(tr('send-via-email')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  final ValueChanged<Locale> onSelected;

  const _LanguageMenu({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final current = Tolgee.currentLocale?.toLanguageTag();

    return TranslationWidget(
      builder: (context, tr) => PopupMenuButton<Locale>(
        tooltip: tr('language-menu-tooltip'),
        icon: const Icon(Icons.language),
        onSelected: onSelected,
        itemBuilder: (context) => [
          for (final language in Tolgee.languages)
            CheckedPopupMenuItem(
              value: language.locale,
              checked: language.tag == current,
              child: Text(
                '${language.flagEmoji ?? ''} ${language.originalName ?? language.name}'
                    .trim(),
              ),
            ),
        ],
      ),
    );
  }
}
