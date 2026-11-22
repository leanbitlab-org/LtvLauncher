import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/models/watch_next_program.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/continue_watching_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

Widget _buildTestWidget({
  required Widget child,
  required SettingsService settingsService,
  required WatchNextService watchNextService,
  required AppsService appsService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsService>.value(value: settingsService),
      ChangeNotifierProvider<WatchNextService>.value(value: watchNextService),
      ChangeNotifierProvider<AppsService>.value(value: appsService),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

WatchNextProgram _fakeProgram({
  required int id,
  required String packageName,
  required String title,
  int playbackPosition = 100,
  int duration = 200,
}) {
  return WatchNextProgram(
    id: id,
    packageName: packageName,
    title: title,
    description: 'Description for $title',
    watchNextType: 0,
    lastEngagementTime: 0,
    playbackPosition: playbackPosition,
    duration: duration,
    intentUri: 'intent://$packageName',
    posterArtUri: '',
  );
}

void main() {
  late MockSettingsService settingsService;
  late MockWatchNextService watchNextService;
  late MockAppsService appsService;

  setUp(() {
    settingsService = MockSettingsService();
    watchNextService = MockWatchNextService();
    appsService = MockAppsService();

    when(settingsService.showContinueWatching).thenReturn(true);
    when(settingsService.hiddenWatchNextProgramIds).thenReturn([]);
    when(settingsService.hiddenWatchNextPackages).thenReturn([]);
    when(settingsService.continueWatchingMaxItems).thenReturn(10);
    when(settingsService.continueWatchingHideThreshold).thenReturn(0);
    when(settingsService.continueWatchingCardSize).thenReturn('normal');
    when(settingsService.continueWatchingShowProgress).thenReturn(true);
    when(settingsService.continueWatchingShowPercentage).thenReturn(true);
    when(settingsService.continueWatchingShowDescription).thenReturn(true);
    when(settingsService.showCategoryTitles).thenReturn(true);
    when(settingsService.showCategoryAppCount).thenReturn(false);
    when(settingsService.themes).thenReturn('modern');
    when(settingsService.accentColorHex).thenReturn('00ff00');
    when(settingsService.appHighlightAnimationEnabled).thenReturn(true);
    when(settingsService.hideHighlightOutlineOnHomescreen).thenReturn(false);
    when(settingsService.appSelectorTransitionAnimationEnabled).thenReturn(true);

    when(watchNextService.hasPermission).thenReturn(true);
    when(watchNextService.launch(any)).thenAnswer((_) async => true);
    when(appsService.applications).thenReturn([]);
    when(appsService.getAppIcon(any)).thenAnswer((_) async => Uint8List(0));
  });

  group('ContinueWatchingRow header', () {
    testWidgets('respects showCategoryTitles and showCategoryAppCount', (tester) async {
      final programs = [
        _fakeProgram(id: 1, packageName: 'app.one', title: 'Video 1'),
        _fakeProgram(id: 2, packageName: 'app.two', title: 'Video 2'),
      ];
      when(watchNextService.programs).thenReturn(programs);
      when(settingsService.showCategoryTitles).thenReturn(true);
      when(settingsService.showCategoryAppCount).thenReturn(false);

      await tester.pumpWidget(
        _buildTestWidget(
          child: const ContinueWatchingRow(),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue Watching'), findsOneWidget);
      expect(find.text('•  2'), findsNothing);

      // Now toggle showCategoryAppCount to true
      when(settingsService.showCategoryAppCount).thenReturn(true);
      await tester.pumpWidget(
        _buildTestWidget(
          child: const ContinueWatchingRow(),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('•  2'), findsOneWidget);
    });

    testWidgets('passes isFirstInRow and isLastInRow to items', (tester) async {
      final programs = [
        _fakeProgram(id: 1, packageName: 'app.one', title: 'Video 1'),
        _fakeProgram(id: 2, packageName: 'app.two', title: 'Video 2'),
      ];
      when(watchNextService.programs).thenReturn(programs);

      await tester.pumpWidget(
        _buildTestWidget(
          child: const ContinueWatchingRow(),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pumpAndSettle();

      final cards = tester.widgetList<WatchNextCard>(find.byType(WatchNextCard)).toList();
      expect(cards.length, equals(2));
      expect(cards[0].isFirstInRow, isTrue);
      expect(cards[0].isLastInRow, isFalse);
      expect(cards[1].isFirstInRow, isFalse);
      expect(cards[1].isLastInRow, isTrue);
    });
  });

  group('WatchNextCard animations', () {
    testWidgets('edge bump animation triggers on left boundary', (tester) async {
      final program = _fakeProgram(id: 1, packageName: 'app.one', title: 'Video 1');

      await tester.pumpWidget(
        _buildTestWidget(
          child: WatchNextCard(
            program: program,
            appsService: appsService,
            watchNextService: watchNextService,
            isFirstInRow: true,
            isLastInRow: false,
            autofocus: true,
          ),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pump();

      // Verify initial translate offset is 0
      final transformsBefore = tester.widgetList<Transform>(find.byType(Transform));
      expect(transformsBefore.any((t) => t.transform.getTranslation().x != 0), isFalse);

      // Press Left arrow to trigger bump
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Bump animation should translate with negative x offset
      final transformsDuring = tester.widgetList<Transform>(find.byType(Transform));
      expect(transformsDuring.any((t) => t.transform.getTranslation().x < 0), isTrue);

      // Advance animation back to rest
      await tester.pump(const Duration(milliseconds: 200));
      final transformsAfter = tester.widgetList<Transform>(find.byType(Transform));
      expect(transformsAfter.any((t) => t.transform.getTranslation().x != 0), isFalse);
    });

    testWidgets('edge bump animation triggers on right boundary', (tester) async {
      final program = _fakeProgram(id: 2, packageName: 'app.two', title: 'Video 2');

      await tester.pumpWidget(
        _buildTestWidget(
          child: WatchNextCard(
            program: program,
            appsService: appsService,
            watchNextService: watchNextService,
            isFirstInRow: false,
            isLastInRow: true,
            autofocus: true,
          ),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pump();

      // Press Right arrow to trigger bump
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Bump animation should translate with positive x offset
      final transformsDuring = tester.widgetList<Transform>(find.byType(Transform));
      expect(transformsDuring.any((t) => t.transform.getTranslation().x > 0), isTrue);

      // Advance animation back to rest
      await tester.pump(const Duration(milliseconds: 200));
      final transformsAfter = tester.widgetList<Transform>(find.byType(Transform));
      expect(transformsAfter.any((t) => t.transform.getTranslation().x != 0), isFalse);
    });

    testWidgets('unfocused card has 10% black dimming layer and illuminates when focused', (tester) async {
      final program = _fakeProgram(id: 1, packageName: 'app.one', title: 'Video 1');

      await tester.pumpWidget(
        _buildTestWidget(
          child: WatchNextCard(
            program: program,
            appsService: appsService,
            watchNextService: watchNextService,
            autofocus: false,
          ),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pump();

      // The dimming layer is a black AnimatedContainer at 10% when unfocused, clear when focused.
      Color? dimColor() => tester
          .widgetList<AnimatedContainer>(find.descendant(
              of: find.byType(IgnorePointer), matching: find.byType(AnimatedContainer)))
          .map((c) => (c.decoration as BoxDecoration?)?.color)
          .whereType<Color>()
          .single;
      expect(dimColor(), Colors.black.withOpacity(0.10));

      // Focus the card using traditional keyboard navigation
      final inkWell = find.byType(InkWell);
      tester.widget<InkWell>(inkWell).focusNode?.requestFocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // When focused with traditional highlight mode, the dimming layer is clear.
      expect(dimColor(), Colors.black.withOpacity(0));
    });

    testWidgets('tapping or pressing select launches the program', (tester) async {
      final program = _fakeProgram(id: 1, packageName: 'app.one', title: 'Video 1');

      await tester.pumpWidget(
        _buildTestWidget(
          child: WatchNextCard(
            program: program,
            appsService: appsService,
            watchNextService: watchNextService,
            autofocus: true,
          ),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pump(const Duration(milliseconds: 200));

      verify(watchNextService.launch(program)).called(1);
      await tester.pump(const Duration(milliseconds: 600));
    });
  });

  group('ContinueWatchingRow progress threshold filtering', () {
    testWidgets('shows all programs when continueWatchingHideThreshold is 0 (Off)', (tester) async {
      when(settingsService.continueWatchingHideThreshold).thenReturn(0);
      final programs = [
        _fakeProgram(id: 1, packageName: 'app.one', title: 'Video 50%', playbackPosition: 100, duration: 200),
        _fakeProgram(id: 2, packageName: 'app.two', title: 'Video 95%', playbackPosition: 190, duration: 200),
        _fakeProgram(id: 3, packageName: 'app.three', title: 'Video 99%', playbackPosition: 198, duration: 200),
      ];
      when(watchNextService.programs).thenReturn(programs);

      await tester.pumpWidget(
        _buildTestWidget(
          child: const ContinueWatchingRow(),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pump();

      expect(find.text('Video 50%'), findsOneWidget);
      expect(find.text('Video 95%'), findsOneWidget);
      expect(find.text('Video 99%'), findsOneWidget);
    });

    testWidgets('filters out programs with progress >= threshold while keeping lower progress', (tester) async {
      when(settingsService.continueWatchingHideThreshold).thenReturn(90);
      final programs = [
        _fakeProgram(id: 1, packageName: 'app.one', title: 'Video 50%', playbackPosition: 100, duration: 200),
        _fakeProgram(id: 2, packageName: 'app.two', title: 'Video 95%', playbackPosition: 190, duration: 200),
        _fakeProgram(id: 3, packageName: 'app.three', title: 'Video Unknown Duration', playbackPosition: 100, duration: 0),
      ];
      when(watchNextService.programs).thenReturn(programs);

      await tester.pumpWidget(
        _buildTestWidget(
          child: const ContinueWatchingRow(),
          settingsService: settingsService,
          watchNextService: watchNextService,
          appsService: appsService,
        ),
      );
      await tester.pump();

      expect(find.text('Video 50%'), findsOneWidget);
      expect(find.text('Video 95%'), findsNothing);
      expect(find.text('Video Unknown Duration'), findsOneWidget);
    });
  });
}
