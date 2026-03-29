import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:basalmetabolism/parse_locale_tag.dart';
import 'package:basalmetabolism/setting_page.dart';
import 'package:basalmetabolism/theme_color.dart';
import 'package:basalmetabolism/ad_manager.dart';
import 'package:basalmetabolism/theme_mode_number.dart';
import 'package:basalmetabolism/ad_banner_widget.dart';
import 'package:basalmetabolism/l10n/app_localizations.dart';
import 'package:basalmetabolism/loading_screen.dart';
import 'package:basalmetabolism/main.dart';
import 'package:basalmetabolism/model.dart';
import 'package:basalmetabolism/bmr_calculator.dart';
import 'package:basalmetabolism/bmr_result_set.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  late AdManager _adManager;
  late ThemeColor _themeColor;
  bool _isReady = false;
  bool _isFirst = true;
  //
  final TextEditingController _humanHeightController = TextEditingController();
  final TextEditingController _humanWeightController = TextEditingController();
  final TextEditingController _humanAgeController = TextEditingController();
  int _humanGender = 2; //1:male 2:female
  //
  BmrResultSet _resultSetA = BmrResultSet.zero;
  BmrResultSet _resultSetB = BmrResultSet.zero;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    _adManager = AdManager();
    _humanHeightController.text = Model.humanHeight.toString();
    _humanWeightController.text = Model.humanWeight.toString();
    _humanAgeController.text = Model.humanAge.toString();
    _humanGender = Model.humanGender;
    _humanHeightController.addListener(_updateResults);
    _humanWeightController.addListener(_updateResults);
    _humanAgeController.addListener(_updateResults);
    _updateResults();
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  void _updateResults() {
    final humanHeight = int.tryParse(_humanHeightController.text) ?? 0;
    final humanWeight = int.tryParse(_humanWeightController.text) ?? 0;
    final humanAge = int.tryParse(_humanAgeController.text) ?? 0;
    final humanGender = _humanGender;

    final setA = BmrCalculator.calculateSetA(
      height: humanHeight,
      weight: humanWeight,
      age: humanAge,
      gender: humanGender,
    );
    final setB = BmrCalculator.calculateSetB(
      height: humanHeight,
      weight: humanWeight,
      age: humanAge,
      gender: humanGender,
    );
    setState(() {
      _resultSetA = setA;
      _resultSetB = setB;
    });
    Model.setHumanHeight(humanHeight);
    Model.setHumanWeight(humanWeight);
    Model.setHumanAge(humanAge);
    Model.setHumanGender(humanGender);
  }

  @override
  void dispose() {
    _humanHeightController.dispose();
    _humanWeightController.dispose();
    _humanAgeController.dispose();
    super.dispose();
  }

  Future<void> _openSetting() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingPage()),
    );
    if (!mounted) {
      return;
    }
    if (updated == true) {
      final mainState = context.findAncestorStateOfType<MainAppState>();
      if (mainState != null) {
        mainState
          ..themeMode = ThemeModeNumber.numberToThemeMode(Model.themeNumber)
          ..locale = parseLocaleTag(Model.languageCode)
          ..setState(() {});
      }
      _isFirst = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady == false) {
      return const LoadingScreen();
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(context: context);
    }
    final l = AppLocalizations.of(context)!;
    final levelDescriptions = <String>[
      l.basalDefinition,
      l.calorieLevelADescription,
      l.calorieLevelBDescription,
      l.calorieLevelCDescription,
    ];
    final TextTheme t = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(children:[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_themeColor.mainBack2Color, _themeColor.mainBackColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            image: DecorationImage(
              image: AssetImage('assets/image/tile.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.1,
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 36,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(l.appTitle, style: t.titleSmall?.copyWith(color: _themeColor.mainForeColor)),
                    const Spacer(),
                    IconButton(
                      onPressed: _openSetting,
                      icon: Icon(Icons.settings,color: _themeColor.mainForeColor.withValues(alpha: 0.6)),
                    ),
                  ]
                )
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNumberField(
                          controller: _humanHeightController,
                          label: l.heightLabel,
                          unit: l.heightUnit,
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          controller: _humanWeightController,
                          label: l.weightLabel,
                          unit: l.weightUnit,
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          controller: _humanAgeController,
                          label: l.ageLabel,
                          unit: l.ageUnit,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                l.genderLabel,
                                textAlign: TextAlign.right,
                                style: t.bodyLarge,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SegmentedButton<int>(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return _themeColor.mainButtonBackColor;
                                    }
                                    return null;
                                  }),
                                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return _themeColor.mainButtonForeColor;
                                    }
                                    return null;
                                  }),
                                  overlayColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return _themeColor.mainButtonBackColor.withValues(alpha: 0.2);
                                    }
                                    return _themeColor.mainButtonBackColor.withValues(alpha: 0.12);
                                  }),
                                  side: WidgetStateProperty.resolveWith((states) {
                                    final color = states.contains(WidgetState.selected)
                                        ? _themeColor.mainButtonBackColor
                                        : _themeColor.mainButtonBackColor.withValues(alpha: 0.12);
                                    return BorderSide(color: color);
                                  }),
                                ),
                                segments: [
                                  ButtonSegment(value: 1, label: Text(l.male)),
                                  ButtonSegment(value: 2, label: Text(l.female)),
                                ],
                                selected: <int>{_humanGender},
                                onSelectionChanged: (selection) {
                                  if (selection.isEmpty) {
                                    return;
                                  }
                                  setState(() {
                                    _humanGender = selection.first;
                                  });
                                  _updateResults();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildResultCard(
                          intro: l.setAIntro,
                          result: _resultSetA,
                          localization: l,
                          descriptions: levelDescriptions,
                          formulaNote: l.setAFormulaNote,
                        ),
                        const SizedBox(height: 16),
                        _buildResultCard(
                          intro: l.setBIntro,
                          result: _resultSetB,
                          localization: l,
                          descriptions: levelDescriptions,
                          formulaNote: l.setBFormulaNote,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                )
              )
            ]
          )
        )
      ]),
      bottomNavigationBar: AdBannerWidget(adManager: _adManager),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String unit,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: textTheme.bodyLarge,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              suffixText: unit,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String intro,
    required BmrResultSet result,
    required AppLocalizations localization,
    required List<String> descriptions,
    required String formulaNote,
  }) {
    String descriptionAt(int index) =>
        index < descriptions.length ? descriptions[index] : '';

    final entries = <_ResultEntry>[
      _ResultEntry(
        label: localization.basalLabel,
        value: result.basal,
        description: descriptionAt(0),
      ),
      _ResultEntry(
        label: localization.level15Label,
        value: result.level15,
        description: descriptionAt(1),
      ),
      _ResultEntry(
        label: localization.level175Label,
        value: result.level175,
        description: descriptionAt(2),
      ),
      _ResultEntry(
        label: localization.level20Label,
        value: result.level20,
        description: descriptionAt(3),
      ),
    ];

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cardColor = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.8);

    return Card(
      color: cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(intro, style: textTheme.titleMedium),
            const SizedBox(height: 16),
            for (var i = 0; i < entries.length; i++) ...[
              _buildResultRow(
                entries[i].label,
                entries[i].value,
                localization,
                description: entries[i].description,
              ),
              if (i != entries.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Text(
              formulaNote,
              style: textTheme.bodySmall ?? textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
      String label,
      int value,
      AppLocalizations localization, {
        String? description,
      }) {
    final textTheme = Theme.of(context).textTheme;
    final descriptionStyle = textTheme.bodySmall ?? textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: textTheme.titleMedium)),
            Text('$value ${localization.kcalSuffix}',
                style: textTheme.titleMedium),
          ],
        ),
        if (description != null && description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(description, style: descriptionStyle),
          ),
      ],
    );
  }

}

class _ResultEntry {
  const _ResultEntry({
    required this.label,
    required this.value,
    required this.description,
  });

  final String label;
  final int value;
  final String description;
}
