import 'package:flutter/material.dart';
import 'package:intl/intl.dart';                        // ← ADICIONADO
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/providers/note_provider.dart';
import 'services/service_locator.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR', null);

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NoteProvider(
            getNotesUseCase: di.sl(),
            searchNotesUseCase: di.sl(),
            addNoteUseCase: di.sl(),
            updateNoteUseCase: di.sl(),
            deleteNoteUseCase: di.sl(),
            getProjectsUseCase: di.sl(),
            addProjectUseCase: di.sl(),
            updateProjectUseCase: di.sl(),
            deleteProjectUseCase: di.sl(),
            reviewNoteUseCase: di.sl(),
            knowledgeRepository: di.sl(),
            intelligenceService: di.sl(),
            notificationService: di.sl(),
          )..loadInitialData(),
        ),
      ],
      child: MaterialApp(
        title: 'Pingu Notes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashPage(),
      ),
    );
  }
}