import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app_shell.dart';
import 'app/mobile_frame.dart';
import 'service_locator.dart';
import 'settings/domain/usecase/load_settings_usecase.dart';
import 'settings/domain/usecase/set_blur_pending_usecase.dart';
import 'settings/presenter/bloc/settings_bloc.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const GowAlbumApp());
}

class GowAlbumApp extends StatelessWidget {
  const GowAlbumApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsBloc is provided above MaterialApp so it sits above the Navigator
    // and is shared by every route (album, search, favor album).
    return BlocProvider(
      create: (_) => SettingsBloc(
        loadSettings: locator<LoadSettingsUsecase>(),
        setBlurPending: locator<SetBlurPendingUsecase>(),
      )..add(const SettingsStarted()),
      child: MaterialApp(
        title: 'GoW Album',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.gold,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        builder: (context, child) => MobileFrame(child: child!),
        home: const AppShell(),
      ),
    );
  }
}
