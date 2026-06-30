import 'package:flutter/material.dart';
import 'app/mobile_frame.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GowAlbumApp());
}

class GowAlbumApp extends StatelessWidget {
  const GowAlbumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const Scaffold(
        body: Center(child: Text('GoW Album', style: AppText.title)),
      ),
    );
  }
}
