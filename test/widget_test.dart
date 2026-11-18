import 'package:budget_audit/core/context.dart';
import 'package:budget_audit/core/data/database.dart';
import 'package:budget_audit/core/services/budget_service.dart';
import 'package:budget_audit/core/services/document_service.dart';
import 'package:budget_audit/core/services/participant_service.dart';
import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/core/theme/theme_provider.dart';
import 'package:budget_audit/features/home/home_view.dart';
import 'package:budget_audit/features/home/home_viewmodel.dart';
import 'package:budget_audit/features/menu/menu_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _UnusedAppDatabase implements AppDatabase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHomeViewModel extends HomeViewModel {
  _TestHomeViewModel(AppContext appContext, AppDatabase database)
      : super(
          documentService: DocumentService(),
          participantService: ParticipantService(database),
          budgetService: BudgetService(database),
          appContext: appContext,
        );

  @override
  Future<void> loadParticipants() async {}

  @override
  Future<void> loadTemplateHistory() async {}

  @override
  Future<void> refreshHistory() async {}
}

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets('home screen fits a ${width.toInt()}px mobile viewport',
        (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      dotenv.testLoad(fileInput: 'ENV=TEST\n');

      final appContext = AppContext();
      final homeViewModel =
          _TestHomeViewModel(appContext, _UnusedAppDatabase());
      final menuViewModel = MenuViewModel(appContext);
      addTearDown(homeViewModel.dispose);
      addTearDown(menuViewModel.dispose);
      addTearDown(appContext.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppContext>.value(value: appContext),
            ChangeNotifierProvider<HomeViewModel>.value(
              value: homeViewModel,
            ),
            ChangeNotifierProvider<MenuViewModel>.value(
              value: menuViewModel,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: ThemeProvider(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Document Password'), findsOneWidget);
      expect(find.text('Document Owner'), findsOneWidget);
    });
  }
}
