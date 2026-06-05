import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/note_provider.dart';
import 'services/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          )..loadNotes(),
        ),
      ],
      child: MaterialApp(
        title: 'Pingu Notes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}
