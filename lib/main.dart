import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'core/app_theme.dart';
import 'core/roble_constants.dart';
import 'core/roble_service.dart';
import 'features/auth/auth_dependencies.dart';
import 'features/auth/ui/views/splash_page.dart';
import 'features/create/create_dependencies.dart';
import 'features/explore/explore_dependencies.dart';
import 'features/home/home_dependencies.dart';
import 'features/profile/profile_dependencies.dart';
import 'features/project/project_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  // Inicializar Roble Service
  RobleService().init(
    baseUrl: RobleConstants.baseUrl,
    contractId: RobleConstants.contractId,
  );

  registerAuth();
  registerHome();
  registerExplore();
  registerProject();
  registerCreate();
  registerProfile();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashPage(),
    );
  }
}
